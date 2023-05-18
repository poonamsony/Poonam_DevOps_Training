variable "name" {
  description = "Enter your name to be used with name arguments & tags"
}
variable "client_id" {
  description = "Enter Service Principal Client ID"
}
variable "client_secret" {
  description = "Enter the Service Principal Client Secret"
}
locals {
  tags = {
    client = "sony"
    user   = var.name
  }
  name = "thinknyx-${var.name}"
}
variable "kubeconfig" {
}
