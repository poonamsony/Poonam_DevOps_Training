terraform {
  backend "azurerm" {
    resource_group_name  = "thinknyxlabs"
    storage_account_name = "thinknyxlabs"
    container_name       = "thinknyxlabs"
    key                  = "poonam-kubernetes.terraform.tfstate"
  }
}
variable "kubeconfig" {}
variable "name" {}
provider "kubernetes" {
  config_path = var.kubeconfig
}
locals {
  name = "thinknyx-${var.name}"
}
data "kubernetes_all_namespaces" "namespaces" {
  depends_on = [
    kubernetes_namespace.thinknyx
  ]
}
resource "kubernetes_namespace" "thinknyx" {
  metadata {
    name = local.name
  }
}
resource "kubernetes_deployment" "tomcat" {
  metadata {
    name      = "tomcat"
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
          name  = "tomcat"
        }
      }
    }
  }
}
resource "kubernetes_service" "tomcat" {
  metadata {
    name      = kubernetes_deployment.tomcat.metadata.0.name
    namespace = kubernetes_namespace.thinknyx.id
  }
  spec {
    selector = {
      app = kubernetes_deployment.tomcat.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 8080
      node_port   = 30000
    }
  }
}
resource "kubernetes_role" "pod_readonly" {
  metadata {
    name      = "pod-readonly"
    namespace = kubernetes_namespace.thinknyx.id
  }
  rule {
    api_groups     = [""]
    resources      = ["pods"]
    resource_names = [""]
    verbs = [
      "get",
      "list",
      "watch"
    ]
  }
  rule {
    api_groups     = ["apps"]
    resources      = ["deployments"]
    resource_names = ["tomcat"]
    verbs = [
      "get",
      "list"
    ]
  }
}
