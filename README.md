# Epik8 Chart

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
    repoURL: 'https://baltig.infn.it/epics-containers/epik8-chart.git'
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
    namespace: sparc
  syncPolicy:
    automated:
      prune: true  # Optional: Automatically remove resources not specified in Helm chart
      selfHeal: true

```




