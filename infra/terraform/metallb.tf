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

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.13.11"
  namespace  = kubernetes_namespace.metallb.metadata[0].name

  # values = [
  #   "${file("${path.module}/values.yaml")}"
  # ]
}

resource "kubectl_manifest" "metallb-addresspool" {
  yaml_body = <<YAML
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: ${helm_release.metallb.namespace}
spec:
  addresses:
  - 192.168.0.240
YAML
}

resource "kubectl_manifest" "metallb-l2-advertisement" {
  yaml_body = <<YAML
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: first-advertisement
  namespace: ${helm_release.metallb.namespace}
YAML
}
