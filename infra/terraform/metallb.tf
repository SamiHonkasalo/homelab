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

resource "kubectl_manifest" "metallb-addresspool" {
  depends_on = [null_resource.ansible_playbook_control_planes]
  apply_only = true
  yaml_body  = <<YAML
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: ${kubernetes_namespace.metallb.metadata[0].name}
spec:
  addresses:
  - 192.168.0.240-192.168.0.245
YAML
}

resource "kubectl_manifest" "metallb-l2-advertisement" {
  depends_on = [null_resource.ansible_playbook_control_planes]
  apply_only = true
  yaml_body  = <<YAML
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: first-advertisement
  namespace: ${kubernetes_namespace.metallb.metadata[0].name}
YAML
}

resource "helm_release" "metallb" {
  depends_on = [kubectl_manifest.metallb-addresspool, kubectl_manifest.metallb-l2-advertisement]
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.13.11"
  namespace  = kubernetes_namespace.metallb.metadata[0].name

  # values = [
  #   "${file("${path.module}/values.yaml")}"
  # ]
}
