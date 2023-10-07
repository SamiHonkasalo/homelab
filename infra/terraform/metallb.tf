resource "kubernetes_namespace" "metallb" {
  depends_on = [null_resource.ansible_playbook_nodes]
  metadata {
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  depends_on = [kubernetes_namespace.metallb]
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.13.11"
  namespace  = kubernetes_namespace.metallb.metadata[0].name
}

resource "null_resource" "apply_metallb_crds" {
  depends_on = [helm_release.metallb]
  triggers = {
    file_sha = filesha1("${path.module}/metallb-manifests.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/metallb-manifests.yaml"
  }
}
