#locals {
#  ha = var.ha == null ? false : var.ha
#}

resource "kubernetes_namespace" "argocd" {
  count = var.enabled ? 1 : 0
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  count      = var.enabled ? 1 : 0
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd[0].id
  chart      = var.chart == null ? "${path.module}/../../charts/argocd" : var.chart
  timeout    = "240"

  values = try([file("${var.values}")], [])
}

#resource "kubernetes_secret_v1" "gitconfig" {
#  count = var.enabled ? 1 : 0
#  metadata {
#    name      = "gitconfig"
#    namespace = kubernetes_namespace.argocd[0].id
#  }
#
#  data = {
#    gitconfig = <<-EOF
#[filter "lfs"]
#    clean = git-lfs clean -- %f
#    smudge = git-lfs smudge -- %f
#    process = git-lfs filter-process
#    required = true
#
## Name them as different hosts so that we can use ssh Host entries
#[url "https://${var.gh_user}:${var.gh_pat}@github.com/${var.gh_org}/"]
#    insteadOf = git@github.com:${var.gh_org}/
#EOF
#  }
#}

#resource "helm_release" "argocd" {
#  count      = var.enabled ? 1 : 0
#  name       = "argocd"
#  namespace  = kubernetes_namespace.argocd[0].id
#  chart      = var.chart == null ? "${path.module}/../../charts/argocd" : var.chart
#  timeout    = "600"
#
#  #values = try([file("${var.values}")], [])
#  values = [<<EOF
#global:
#  podLabels:
#    apiserver/egress: enabled
#    apiserver/ingress: enabled
#
#  networkPolicy:
#    create: true
#
#server:
#  replicas: ${local.ha ? 3 : 1}
#  config:
#    kustomize.buildOptions: "--load-restrictor LoadRestrictionsNone --enable-helm"
#    resource.customizations.ignoreDifferences.all: |
#      jqPathExpressions:
#      - '.spec.containers[]?.imagePullPolicy'
#      - '.spec.template.spec.containers[]?.imagePullPolicy'
#      - '.metadata.annotations."kyverno.io/created-by"'
#
#redis-ha:
#  enabled: ${local.ha}
#
#controller:
#  replicas: 1
#
#repoServer:
#  replicas: ${local.ha ? 3 : 1}
#
#  # Needed for an SSH Hack to allow private remote bases
#  containerSecurityContext:
#    readOnlyRootFilesystem: false
#
#  podAnnotations:
#    secret.reloader.stakater.com/reload: gitconfig
#
#  volumes:
#  - name: gitconfig
#    secret:
#      secretName: gitconfig
#
#  volumeMounts:
#  - name: gitconfig
#    mountPath: /etc/gitconfig
#    subPath: gitconfig
#
#applicationSet:
#  replicas: 1
#EOF
#  ]
#}
