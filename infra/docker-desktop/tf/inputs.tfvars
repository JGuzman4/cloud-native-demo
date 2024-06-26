argocd_enabled        = false
consul_enabled        = false
istio_enabled         = true
istio_gateway_enabled = true
flagger_enabled       = true
grafana_enabled       = false
harbor_enabled        = false
jenkins_enabled       = false
kiali_enabled         = true
prometheus_enabled    = true
vault_enabled         = false

argocd_values        = "./values/argocd.yaml"
consul_values        = "./values/consul.yaml"
flagger_values       = "./values/flagger.yaml"
grafana_values       = "./values/grafana.yaml"
harbor_values        = "./values/harbor.yaml"
istio_base_values    = "./values/istio-base.yaml"
istio_gateway_values = "./values/istio-gateway.yaml"
istio_istiod_values  = "./values/istio-istiod.yaml"
jenkins_values       = "./values/jenkins.yaml"
kiali_values         = "./values/kiali.yaml"
prometheus_values    = "./values/prometheus.yaml"
vault_values         = "./values/vault.yaml"

# Istio
istio_sidecar = "enabled"
