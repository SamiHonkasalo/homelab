resource "kubernetes_namespace" "metallb" {
  depends_on = [null_resource.ansible_playbook_control_planes]
  metadata {
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
    name = "metallb-system"
  }
}

resource "null_resource" "apply_metallb_crds" {
  depends_on = [null_resource.ansible_playbook_control_planes]
  triggers = {
    file_sha = filesha1("${path.module}/metallb-manifests.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/metallb-manifests.yaml"
  }
}

resource "helm_release" "metallb" {
  depends_on = [null_resource.apply_metallb_crds]
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.13.11"
  namespace  = kubernetes_namespace.metallb.metadata[0].name
}
