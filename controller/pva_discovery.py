#!/usr/bin/env python3
"""epik8s PVA Discovery Controller

Watches Pods labelled epics-pva=true and maintains a ConfigMap key
EPICS_PVA_NAME_SERVERS with the corresponding Service DNS names.

Environment variables
---------------------
NAMESPACE            k8s namespace to watch           (default: from service account)
CONFIGMAP_NAME       target ConfigMap name             (default: epics-configuration)
CONFIGMAP_KEY        key inside the ConfigMap           (default: EPICS_PVA_NAME_SERVERS)
LABEL_SELECTOR       pod label selector                (default: epics-pva=true)
EXTRA_NAME_SERVERS   static entries to always include  (default: "")
TRIGGER_ROLLOUT      restart consumers on change       (default: false)
ROLLOUT_LABELS       selector for Deployments/STS      (default: epics-pva-consumer=true)
LOG_LEVEL            logging verbosity                 (default: INFO)
"""

import logging
import os
import signal
import sys
import time
from datetime import datetime, timezone

from kubernetes import client, config, watch

logging.basicConfig(
    level=os.environ.get("LOG_LEVEL", "INFO").upper(),
    format="%(asctime)s %(levelname)s %(message)s",
)
log = logging.getLogger("pva-discovery")

# ── Configuration ────────────────────────────────────────────────────────────
NAMESPACE = os.environ.get("NAMESPACE", "")
CONFIGMAP_NAME = os.environ.get("CONFIGMAP_NAME", "epics-configuration")
CONFIGMAP_KEY = os.environ.get("CONFIGMAP_KEY", "EPICS_PVA_NAME_SERVERS")
LABEL_SELECTOR = os.environ.get("LABEL_SELECTOR", "epics-pva=true")
EXTRA_NAME_SERVERS = os.environ.get("EXTRA_NAME_SERVERS", "")
TRIGGER_ROLLOUT = os.environ.get("TRIGGER_ROLLOUT", "").lower() in ("true", "1", "yes")
ROLLOUT_LABELS = os.environ.get("ROLLOUT_LABELS", "epics-pva-consumer=true")

# ── Graceful shutdown ────────────────────────────────────────────────────────
_running = True


def _signal_handler(signum, _frame):
    global _running
    log.info("Received signal %d, shutting down", signum)
    _running = False


signal.signal(signal.SIGTERM, _signal_handler)
signal.signal(signal.SIGINT, _signal_handler)


# ── Helpers ──────────────────────────────────────────────────────────────────
def _resolve_namespace() -> str:
    """Return the namespace from env or the in-cluster service-account."""
    if NAMESPACE:
        return NAMESPACE
    sa_ns = "/var/run/secrets/kubernetes.io/serviceaccount/namespace"
    if os.path.isfile(sa_ns):
        with open(sa_ns) as f:
            return f.read().strip()
    return "default"


def _build_name_servers(pods: dict, namespace: str) -> str:
    """Build space-separated EPICS_PVA_NAME_SERVERS from tracked pods."""
    servers = set()
    for info in pods.values():
        svc = info.get("service")
        if svc:
            servers.add(f"{svc}.{namespace}.svc")
    if EXTRA_NAME_SERVERS:
        for extra in EXTRA_NAME_SERVERS.split():
            extra = extra.strip()
            if extra:
                servers.add(extra)
    return " ".join(sorted(servers))


def _update_configmap(v1: client.CoreV1Api, namespace: str, name_servers: str) -> bool:
    """Patch the ConfigMap. Returns True if the value actually changed."""
    try:
        cm = v1.read_namespaced_config_map(CONFIGMAP_NAME, namespace)
    except client.ApiException as exc:
        if exc.status == 404:
            log.info("ConfigMap %s/%s not found — creating", namespace, CONFIGMAP_NAME)
            body = client.V1ConfigMap(
                metadata=client.V1ObjectMeta(name=CONFIGMAP_NAME, namespace=namespace),
                data={CONFIGMAP_KEY: name_servers},
            )
            v1.create_namespaced_config_map(namespace, body)
            return True
        raise

    old = (cm.data or {}).get(CONFIGMAP_KEY, "")
    if old == name_servers:
        return False

    v1.patch_namespaced_config_map(
        CONFIGMAP_NAME, namespace, {"data": {CONFIGMAP_KEY: name_servers}}
    )
    log.info("ConfigMap %s updated: %s", CONFIGMAP_NAME, name_servers)
    return True


def _trigger_rollouts(apps_v1: client.AppsV1Api, namespace: str):
    """Annotate matching Deployments / StatefulSets to force a rollout."""
    ts = datetime.now(timezone.utc).isoformat()
    patch = {
        "spec": {
            "template": {
                "metadata": {
                    "annotations": {"epik8s.infn.it/pva-restart": ts}
                }
            }
        }
    }
    for label_sel in ROLLOUT_LABELS.split(","):
        label_sel = label_sel.strip()
        if not label_sel:
            continue
        for dep in apps_v1.list_namespaced_deployment(namespace, label_selector=label_sel).items:
            apps_v1.patch_namespaced_deployment(dep.metadata.name, namespace, patch)
            log.info("Triggered rollout: Deployment/%s", dep.metadata.name)
        for sts in apps_v1.list_namespaced_stateful_set(namespace, label_selector=label_sel).items:
            apps_v1.patch_namespaced_stateful_set(sts.metadata.name, namespace, patch)
            log.info("Triggered rollout: StatefulSet/%s", sts.metadata.name)


def _pod_service_name(pod) -> str:
    """Derive the Service DNS name from pod labels."""
    labels = pod.metadata.labels or {}
    return labels.get("app.kubernetes.io/instance", pod.metadata.name)


# ── Main loop ────────────────────────────────────────────────────────────────
def run():
    try:
        config.load_incluster_config()
        log.info("Using in-cluster config")
    except config.ConfigException:
        config.load_kube_config()
        log.info("Using kubeconfig")

    namespace = _resolve_namespace()
    v1 = client.CoreV1Api()
    apps_v1 = client.AppsV1Api()
    tracked: dict[str, dict] = {}

    log.info(
        "Starting: namespace=%s configmap=%s key=%s selector=%s",
        namespace, CONFIGMAP_NAME, CONFIGMAP_KEY, LABEL_SELECTOR,
    )

    while _running:
        try:
            # ── Full list (seed state) ──
            pod_list = v1.list_namespaced_pod(namespace, label_selector=LABEL_SELECTOR)
            rv = pod_list.metadata.resource_version
            tracked.clear()
            for pod in pod_list.items:
                if pod.status and pod.status.phase == "Running":
                    tracked[pod.metadata.name] = {
                        "service": _pod_service_name(pod),
                        "phase": "Running",
                    }

            ns_str = _build_name_servers(tracked, namespace)
            changed = _update_configmap(v1, namespace, ns_str)
            if changed and TRIGGER_ROLLOUT:
                _trigger_rollouts(apps_v1, namespace)

            log.info(
                "Watching %d pods (rv=%s), %d name-servers",
                len(tracked), rv, len(ns_str.split()) if ns_str else 0,
            )

            # ── Watch for incremental changes ──
            w = watch.Watch()
            for event in w.stream(
                v1.list_namespaced_pod,
                namespace,
                label_selector=LABEL_SELECTOR,
                resource_version=rv,
                timeout_seconds=300,
            ):
                if not _running:
                    w.stop()
                    break

                etype = event["type"]
                pod = event["object"]
                name = pod.metadata.name
                phase = pod.status.phase if pod.status else "Unknown"
                svc = _pod_service_name(pod)

                if etype in ("ADDED", "MODIFIED") and phase == "Running":
                    tracked[name] = {"service": svc, "phase": phase}
                elif etype == "DELETED" or phase in ("Failed", "Succeeded"):
                    tracked.pop(name, None)

                log.debug("event=%s pod=%s phase=%s svc=%s", etype, name, phase, svc)

                ns_str = _build_name_servers(tracked, namespace)
                changed = _update_configmap(v1, namespace, ns_str)
                if changed and TRIGGER_ROLLOUT:
                    _trigger_rollouts(apps_v1, namespace)

        except client.ApiException as exc:
            if exc.status == 410:
                log.warning("Watch expired (410 Gone), re-listing")
            else:
                log.exception("API error, retrying in 5s")
                time.sleep(5)
        except Exception:
            log.exception("Unexpected error, retrying in 5s")
            time.sleep(5)

    log.info("Shutdown complete")


if __name__ == "__main__":
    run()
