variable "enabled" {
  default = true
}

variable "gateway_enabled" {
  default = false
}

variable "gateway_values" {
  type = string
}

variable "base_values" {
  type = string
}
variable "base_chart" {
  type    = string
  default = null
}
variable "istiod_values" {
  type = string
}
variable "istiod_chart" {
  type    = string
  default = null
}
variable "gateway_chart" {
  type    = string
  default = null
}

variable "namespace" {
  default = "istio-system"
  type = string
}
