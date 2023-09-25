resource "helm_release" "prometheus" {
  count      = var.enabled ? 1 : 0
  name       = "prometheus"
  namespace  = var.namespace
  chart      = var.chart == null ? "${path.module}/../../charts/prometheus" : var.chart
  timeout    = 240

  values = try([file("${var.values}")], [])
}
