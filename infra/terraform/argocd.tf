resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.46.7"
  namespace        = "argocd"
  create_namespace = true

  values = [
    "${file("${path.module}/argocd-values.yaml")}"
  ]
}


resource "null_resource" "deploy_argo_apps" {
  depends_on = [helm_release.argocd]
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/argocd-applications.yaml"
  }
}
