resource "helm_release" "argocd" {
  name             = "longhorn"
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  version          = "1.5.1"
  namespace        = "longhorn-system"
  create_namespace = true

  values = [
    "${file("${path.module}/longhorn-values.yaml")}"
  ]
}
