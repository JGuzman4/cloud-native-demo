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

resource "kubernetes_namespace" "datereporter_dev" {
  metadata {
    name = "datereporter-dev"
    labels = {
      istio-injection = var.istio_sidecar
    }
  }
}
