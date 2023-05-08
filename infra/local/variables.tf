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
