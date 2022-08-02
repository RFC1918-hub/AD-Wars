locals {
  linux_env = {
    logger = {
      vm_name = "logger"
      ip      = "192.168.56.100"
      vm_details = {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
      }
      vm_size = var.default_vm_size
    }
  }
}

module "linux-env" {
  source   = "./modules/linux-env"
  for_each = local.linux_env

  resource_group_name = azurerm_resource_group.sandbox-rg.name
  location            = azurerm_resource_group.sandbox-rg.location
  subnet_id           = azurerm_virtual_network.sandbox-vnet.subnet.*.id[0]
  vm_name             = each.value.vm_name
  vm_ip               = each.value.ip
  vm_details          = each.value.vm_details
  vm_size             = each.value.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
}