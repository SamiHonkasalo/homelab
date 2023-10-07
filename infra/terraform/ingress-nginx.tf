resource "helm_release" "ingress-nginx" {
  depends_on       = [null_resource.ansible_playbook_nodes]
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.8.0"
  namespace        = "ingress-nginx"
  create_namespace = true
}
