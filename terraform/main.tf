resource "kubernetes_namespace" "app" {
  metadata { name = var.app_namespace }
}

resource "kubernetes_namespace" "argocd" {
  metadata { name = var.argocd_namespace }
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata { name = "ingress-nginx" }
}

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "4.12.1"

  set {
    name  = "controller.hostPort.enabled"
    value = "true"
  }

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  depends_on = [kubernetes_namespace.ingress_nginx]
}
