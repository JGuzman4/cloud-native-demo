resource "helm_release" "kiali" {
  count      = var.enabled ? 1 : 0
  name       = "kiali-server"
  namespace  = var.namespace
  chart      = var.chart == null ? "${path.module}/../../charts/kiali" : var.chart
  timeout    = 240

  values = try([file("${var.values}")], [])
}
