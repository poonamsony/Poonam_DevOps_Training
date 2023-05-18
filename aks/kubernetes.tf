provider "kubernetes" {
  config_path = "./kubeconfig"
}
data "kubernetes_all_namespaces" "namespaces" {
  depends_on = [
    azurerm_kubernetes_cluster.thinknyx,
    kubernetes_namespace.thinknyx
  ]
}
resource "kubernetes_namespace" "thinknyx" {
 depends_on = [local_file.kubeconfig] 
  metadata {
    name = local.name
  }
}
resource "kubernetes_deployment" "tomcat" {
  metadata {
    name = "tomcat"
    namespace = kubernetes_namespace.thinknyx.id
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "tomcat"
      }
    }
    template {
      metadata {
        labels = {
          app = "tomcat"
        }
      }
      spec {
        container {
          image = "kulbhushanmayer/tomcat:java-app-2"
          name = "tomcat"
        }
      }
    }
  }
}
resource "kubernetes_service" "tomcat" {
  metadata {
    name = kubernetes_deployment.tomcat.metadata.0.name
    namespace = kubernetes_namespace.thinknyx.id
  }
  spec {
    selector = {
      app = kubernetes_deployment.tomcat.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port = 80
      target_port = 8080
      node_port = 30000
    }
  }
}