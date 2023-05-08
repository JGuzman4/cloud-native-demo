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

module "istio" {
  source          = "../modules/istio"
  enabled         = var.istio_enabled
  gateway_enabled = var.istio_gateway_enabled
  gateway_values  = var.istio_gateway_values
  base_values     = var.istio_base_values
  base_chart      = var.istio_base_chart
  istiod_values   = var.istio_istiod_values
  istiod_chart    = var.istio_istiod_chart
  gateway_chart   = var.istio_gateway_chart
}

module "prometheus" {
  source     = "../modules/prometheus"
  enabled    = var.prometheus_enabled
  values     = var.prometheus_values
  chart      = var.prometheus_chart
  namespace  = kubernetes_namespace.platform.metadata[0].name
  depends_on = [module.istio]
}

module "flagger" {
  source     = "../modules/flagger"
  enabled    = var.flagger_enabled
  values     = var.flagger_values
  chart      = var.flagger_chart
  depends_on = [module.prometheus]
}

module "grafana" {
  source     = "../modules/grafana"
  enabled    = var.grafana_enabled
  values     = var.grafana_values
  chart      = var.grafana_chart
  namespace  = kubernetes_namespace.platform.metadata[0].name
  depends_on = [module.prometheus]
}

module "kiali" {
  source     = "../modules/kiali"
  enabled    = var.kiali_enabled
  values     = var.kiali_values
  chart      = var.kiali_chart
  namespace  = kubernetes_namespace.platform.metadata[0].name
  depends_on = [module.istio]
}
