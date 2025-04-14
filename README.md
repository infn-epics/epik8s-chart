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




