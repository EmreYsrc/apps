resource "kubernetes_horizontal_pod_autoscaler_v1" "keycloak_hpa" {
  metadata {
    name      = "keycloak-hpa"
    namespace = "argocd"
  }
  spec {
    max_replicas = 5
    min_replicas = 1
    scale_target_ref {
      kind        = "StatefulSet"
      name        = "keycloak"
      api_version = "apps/v1"
    }
    target_cpu_utilization_percentage = 30
  }
  
  depends_on = [helm_release.argocd]
}

resource "kubernetes_horizontal_pod_autoscaler_v1" "jenkins_hpa" {
  metadata {
    name      = "jenkins-hpa"
    namespace = "argocd"
  }
  spec {
    max_replicas = 3
    min_replicas = 1
    scale_target_ref {
      kind        = "StatefulSet"
      name        = "jenkins"
      api_version = "apps/v1"
    }
    target_cpu_utilization_percentage = 30
  }
    depends_on = [helm_release.argocd]
}

