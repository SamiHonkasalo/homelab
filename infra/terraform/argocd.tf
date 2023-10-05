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
  triggers = {
    dir_sha1  = sha1(join("", [for f in fileset("${path.module}/../applications", "*") : filesha1(f)]))
    main_sha1 = filesha1("${path.module}/argocd-applications.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/argocd-applications.yaml"
  }
}
