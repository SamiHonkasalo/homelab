resource "helm_release" "ingress-nginx" {
  depends_on       = [ansible_host.control_planes]
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "1.9.0"
  namespace        = "ingress-nginx"
  create_namespace = true

  # values = [
  #   "${file("${path.module}/values.yaml")}"
  # ]
}
