provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "thinknyx" {
  name     = local.name
  location = "eastus"
  tags     = local.tags
}
resource "azurerm_kubernetes_cluster" "thinknyx" {
  resource_group_name = azurerm_resource_group.thinknyx.name
  name                = local.name
  location            = azurerm_resource_group.thinknyx.location
  kubernetes_version  = "1.25.6"
  default_node_pool {
    name                = "default"
    node_count          = 2
    vm_size             = "Standard_B2s"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = false
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
  dns_prefix = local.name
  service_principal {
    client_id = var.client_id
    client_secret = var.client_secret
  }
}
  resource "local_file" "kubeconfig" {
  filename = var.kubeconfig
  content  = azurerm_kubernetes_cluster.thinknyx1.kube_config_raw
}
