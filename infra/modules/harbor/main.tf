resource "helm_release" "harbor" {
  count      = var.enabled ? 1 : 0
  name       = "harbor"
  namespace  = var.namespace
  chart      = var.chart == null ? "${path.module}/../../charts/harbor" : var.chart
  timeout    = 240

  values = try([file("${var.values}")], [])
}
