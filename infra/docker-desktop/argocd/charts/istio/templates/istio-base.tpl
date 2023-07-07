apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: istio-base
  namespace: {{ .Values.argoNamespace }}
spec:
  destination:
    name: ""
    namespace: istio-system
    server: {{ .Values.spec.destination.server }}
  source:
    path: infra/charts/istio-base
    repoURL: "https://github.com/JGuzman4/cloud-native-demo"
    targetRevision: HEAD
  sources: []
  project: default
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
