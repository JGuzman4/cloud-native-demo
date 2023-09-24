resource "helm_release" "jenkins" {
  count      = var.enabled ? 1 : 0
  name       = "jenkins"
  namespace  = var.namespace
  chart      = var.chart == null ? "${path.module}/../../charts/jenkins" : var.chart
  timeout    = 600

  values = try([file("${var.values}")], [])
}
