locals {
  gateway_enabled = (var.enabled && var.gateway_enabled)
}

resource "kubernetes_namespace" "istio_ns" {
  count = var.enabled ? 1 : 0
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "istio_base" {
  count      = var.enabled ? 1 : 0
  name       = "istio-base"
  namespace  = kubernetes_namespace.istio_ns[0].metadata[0].name
  chart      = var.base_chart == null ? "${path.module}/../../charts/istio-base" : var.base_chart
  timeout    = 600

  values = try([file("${var.base_values}")], [])
}

resource "helm_release" "istiod" {
  count      = var.enabled ? 1 : 0
  name       = "istiod"
  namespace  = kubernetes_namespace.istio_ns[0].metadata[0].name
  chart      = var.istiod_chart == null ? "${path.module}/../../charts/istio-istiod" : var.istiod_chart
  timeout    = 600

  values = try([file("${var.istiod_values}")], [])

  depends_on = [helm_release.istio_base]
}

# Istio Gateway resources

resource "kubernetes_namespace" "istio_ingress_ns" {
  count = local.gateway_enabled ? 1 : 0
  metadata {
    name = "istio-ingress"

    labels = {
      "istio-injection" = "enabled"
    }
  }

}


resource "helm_release" "istio_gateway" {
  count      = local.gateway_enabled ? 1 : 0
  name       = "istio-gateway"
  namespace  = kubernetes_namespace.istio_ingress_ns[0].metadata[0].name
  chart      = var.gateway_chart == null ? "${path.module}/../../charts/istio-gateway" : var.gateway_chart
  timeout    = 600

  values = try([file("${var.gateway_values}")], [])

  depends_on = [helm_release.istiod]
}
