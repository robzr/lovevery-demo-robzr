resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "ingress" {
  count = var.ingress.enabled ? 1 : 0

  chart      = "ingress-nginx"
  name       = "nginx"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/ingress-nginx"
}

resource "helm_release" "this" {
  depends_on = [helm_release.ingress]

  chart     = "${path.root}/${var.app_chart.path}"
  lint      = true
  name      = var.app_chart.name
  namespace = kubernetes_namespace.this.metadata[0].name
  values = [
    "${file("${path.root}/${var.app_chart.values_file}")}",
  ]
  version = var.app_chart.version
}
