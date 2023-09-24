resource "helm_release" "consul" {
  count      = var.enabled ? 1 : 0
  name       = "consul"
  namespace  = var.namespace
  chart      = var.chart == null ? "${path.module}/../../charts/consul" : var.chart
  timeout    = 600

  values = try([file("${var.values}")], [])
}
