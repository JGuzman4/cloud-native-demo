resource "helm_release" "flagger" {
  count      = var.enabled ? 1 : 0
  name       = "flagger"
  namespace  = "istio-system"
  chart      = var.chart == null ? "${path.module}/../../charts/flagger" : var.chart
  timeout    = 240

  values = try([file("${var.values}")], [])
}
