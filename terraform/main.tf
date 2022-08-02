locals {
  prefix = "sandbox"
}

/* Deploying azure resource group */
resource "azurerm_resource_group" "sandbox-rg" {
  name     = "${local.prefix}-terraform"
  location = var.azure_region
}