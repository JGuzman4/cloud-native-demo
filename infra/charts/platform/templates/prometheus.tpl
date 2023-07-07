{{- if .Values.prometheus.enabled }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: prometheus
  namespace: {{ .Values.argoNamespace }}
spec:
  destination:
    name: ''
    namespace: platform
    server: {{ .Values.spec.destination.server }}
  source:
    path: infra/charts/prometheus
    repoURL: 'https://github.com/JGuzman4/cloud-native-demo'
    targetRevision: HEAD
  sources: []
  project: default
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
{{- end }}
