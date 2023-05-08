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
