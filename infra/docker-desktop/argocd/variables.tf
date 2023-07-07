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

### Istio ###
variable "istio_enabled" {
  default = "false"
}
variable "istio_gw_enabled" {
  default = "false"
}
variable "istio_sidecar" {
  default = "disabled"
}
