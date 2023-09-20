resource "kubernetes_namespace" "jenkins" {
  count = var.enabled ? 1 : 0
  metadata {
    name = "jenkins"
  }
}

resource "helm_release" "jenkins" {
  count      = var.enabled ? 1 : 0
  name       = "jenkins"
  namespace  = kubernetes_namespace.jenkins[0].id
  chart      = var.chart == null ? "${path.module}/../../charts/jenkins" : var.chart
  timeout    = 600

  values = try([file("${var.values}")], [])
}
