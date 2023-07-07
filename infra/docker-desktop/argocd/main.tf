resource "kubernetes_namespace" "datereporter_dev" {
  metadata {
    name = "datereporter-dev"
    labels = {
      istio-injection = var.istio_sidecar
    }
  }
}

resource "kubernetes_namespace" "platform" {
  metadata {
    name = "platform"
    labels = {
      istio-injection = var.istio_sidecar
    }
  }
}

module "argocd" {
  source  = "../../modules/argocd"
  enabled = var.argocd_enabled
  values  = var.argocd_values
  chart   = var.argocd_chart
}

# Service Mesh
resource "kubernetes_namespace" "istio_ns" {
  count = var.istio_enabled ? 1 : 0
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio" {
  count      = var.istio_enabled ? 1 : 0
  name       = "istio"
  namespace  = kubernetes_namespace.istio_ns[0].metadata[0].name
  chart      = "./charts/istio"
  timeout    = 600
  depends_on = [module.argocd]
}

resource "time_sleep" "wait_istio" {
  depends_on      = [helm_release.istio]
  create_duration = "60s"
}

resource "kubernetes_namespace" "istio_ingress_ns" {
  count = var.istio_gw_enabled ? 1 : 0
  metadata {
    name = "istio-ingress"

    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "helm_release" "istio_gateway" {
  count      = var.istio_gw_enabled ? 1 : 0
  name       = "istio-gateway"
  namespace  = kubernetes_namespace.istio_ingress_ns[0].metadata[0].name
  chart      = "./charts/istio-gateway"
  timeout    = 600
  depends_on = [time_sleep.wait_istio]
}

resource "time_sleep" "wait_gateway" {
  depends_on      = [helm_release.istio_gateway]
  create_duration = "30s"
}

resource "helm_release" "argocd_vs" {
  count      = var.istio_gw_enabled ? 1 : 0
  name       = "argocd-vs"
  namespace  = "argocd"
  chart      = "./charts/argocd-vs"
  timeout    = 600
  depends_on = [module.argocd, time_sleep.wait_gateway]
}

# cluster services

resource "helm_release" "platform" {
  name       = "platform"
  namespace  = kubernetes_namespace.platform.metadata[0].name
  chart      = "${path.module}/../../charts/platform"
  timeout    = 600
  depends_on = [module.argocd, time_sleep.wait_gateway]
}
