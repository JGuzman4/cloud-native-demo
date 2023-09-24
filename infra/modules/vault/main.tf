resource "helm_release" "vault" {
  count      = var.enabled ? 1 : 0
  name       = "vault"
  namespace  = var.namespace
  chart      = var.chart == null ? "${path.module}/../../charts/vault" : var.chart
  timeout    = 600

  values = try([file("${var.values}")], [])
}
