resource "helm_release" "grafana" {
  count      = var.enabled ? 1 : 0
  name       = "grafana"
  namespace  = var.namespace
  chart      = var.chart == null ? "${path.module}/../../charts/grafana" : var.chart
  timeout    = 240

  values = try([file("${var.values}")], [])
}
