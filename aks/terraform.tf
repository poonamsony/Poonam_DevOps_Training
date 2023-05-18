terraform {
  backend "azurerm" {
    resource_group_name = "thinknyxlabs"
    storage_account_name = "thinknyxlabs"
    container_name = "thinknyxlabs"
    key = "jishnu.terraform.tfstate"
  }
}
