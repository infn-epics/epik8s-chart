# Epik8s Chart

Deploy Epics stack through argoCD.

write a deploy.yaml as:

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mytestbeam
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/infn-epics/epik8s-chart.git'
    path: deploy
    targetRevision: HEAD
    helm:
      parameters:
        - name: beamline
          value: mytestbeam
        - name: namespace
          value: mytestbeam
        ## other values from values.yaml
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: mytestbeam
  syncPolicy:
    automated:
      prune: true  # Optional: Automatically remove resources not specified in Helm chart
      selfHeal: true

```

## Private Git repositories

Set in the beamline values, passed to every generated IOC, soft IOC, service,
cronjob and application:

```yaml
epik8s_secrets: epik8s-secret                   # key git_token: one token per host
git_credentials_secret: epik8s-git-credentials  # one token per URL prefix (opt-in)
```

`git_credentials_secret` can also be set on a single `iocs`/`softiocs`/
`services`/`cronjobs`/`applications` entry (or in `iocDefaults`); an entry
value wins over the global one, and `git_credentials_secret: ""` on an entry
disables it there. Enabling it changes the pod template, so the affected IOCs
restart on sync.

Secret format, creation script and rollout: [epik8s-platform docs/git-credentials.md](https://github.com/infn-epics/epik8s-platform/blob/main/docs/git-credentials.md).
