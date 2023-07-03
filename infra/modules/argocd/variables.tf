variable "enabled" {
  default = true
}
variable "values" {
  type = list
}
variable "chart" {
  type = string
}
#variable "ha" {
#  default = false
#}
#variable "gh_user" {
#  description = "The username of the PAT for Kustomize remote bases"
#  type        = string
#}
#variable "gh_pat" {
#  description = "The token of the PAT for Kustomize remote bases"
#  sensitive   = true
#  type        = string
#}
#variable "gh_org" {
#  description = "GH org"
#  type        = string
#}
