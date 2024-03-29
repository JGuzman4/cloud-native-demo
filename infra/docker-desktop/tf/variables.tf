### Argocd ###
variable "argocd_enabled" {
  default = false
}

variable "argocd_values" {
  default = null
}

variable "argocd_chart" {
  default = null
}

### Consul ###
variable "consul_enabled" {
  default = false
}

variable "consul_values" {
  default = null
}

variable "consul_chart" {
  default = null
}

### Istio ###
variable "istio_enabled" {
  default = false
}
variable "istio_gateway_enabled" {
  default = false
}
variable "istio_gateway_values" {
  default = null
}
variable "istio_base_values" {
  default = null
}
variable "istio_base_chart" {
  default = null
}
variable "istio_istiod_values" {
  default = null
}
variable "istio_istiod_chart" {
  default = null
}
variable "istio_gateway_chart" {
  default = null
}
variable "istio_sidecar" {
  default = "disabled"
}

### Flagger ###
variable "flagger_enabled" {
  default = false
}

variable "flagger_values" {
  default = null
}

variable "flagger_chart" {
  default = null
}

### Grafana ###
variable "grafana_enabled" {
  default = false
}

variable "grafana_values" {
  default = null
}

variable "grafana_chart" {
  default = null
}

### Harbor ###
variable "harbor_enabled" {
  default = false
}

variable "harbor_values" {
  default = null
}

variable "harbor_chart" {
  default = null
}

### Jenkins ###
variable "jenkins_enabled" {
  default = false
}

variable "jenkins_values" {
  default = null
}

variable "jenkins_chart" {
  default = null
}

### Kiali ###
variable "kiali_enabled" {
  default = false
}

variable "kiali_values" {
  default = null
}

variable "kiali_chart" {
  default = null
}

### Prometheus ###
variable "prometheus_enabled" {
  default = false
}

variable "prometheus_values" {
  default = null
}

variable "prometheus_chart" {
  default = null
}

### Vault ###
variable "vault_enabled" {
  default = false
}

variable "vault_values" {
  default = null
}

variable "vault_chart" {
  default = null
}
