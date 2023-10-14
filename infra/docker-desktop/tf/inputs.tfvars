argocd_enabled        = false
consul_enabled        = false
istio_enabled         = true
istio_gateway_enabled = true
flagger_enabled       = false
grafana_enabled       = false
jenkins_enabled       = true
kiali_enabled         = false
prometheus_enabled    = false
vault_enabled         = false

argocd_values        = "./values/argocd.yaml"
consul_values        = "./values/consul.yaml"
flagger_values       = "./values/flagger.yaml"
grafana_values       = "./values/grafana.yaml"
istio_base_values    = "./values/istio-base.yaml"
istio_gateway_values = "./values/istio-gateway.yaml"
istio_istiod_values  = "./values/istio-istiod.yaml"
jenkins_values       = "./values/jenkins.yaml"
kiali_values         = "./values/kiali.yaml"
prometheus_values    = "./values/prometheus.yaml"
vault_values         = "./values/vault.yaml"

# Istio
istio_sidecar = "enabled"
