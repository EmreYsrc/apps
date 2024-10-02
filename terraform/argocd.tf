provider "kubernetes" {
  config_path = "~/.kube/config"
  alias       = "argocd"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
  depends_on = [aws_eks_cluster.eks_cluster,aws_eks_node_group.eks_ng_private]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.5.2"

  values = [file("${path.module}/app-of-apps.yaml")]

  depends_on = [aws_eks_cluster.eks_cluster, helm_release.loadbalancer_controller]
}


data "kubernetes_secret" "argocd_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  depends_on = [helm_release.argocd]
}

resource "null_resource" "deploy_app-of-apps" {

    provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/app-of-apps.yaml"
  }
  
  depends_on = [helm_release.argocd]

}