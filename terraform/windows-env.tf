locals {
  windows_env = {
    republic-dc = {
      vm_name = "republic-dc"
      ip      = "192.168.56.10"
      vm_details = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
      }
      vm_size = var.default_vm_size
    }
    security-dc = {
      vm_name = "security-dc"
      ip      = "192.168.56.11"
      vm_details = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
      }
      vm_size = var.default_vm_size
    }
    jedi-archives = {
      vm_name = "jedi-archives"
      ip      = "192.168.56.22"
      vm_details = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
      }
      vm_size = var.default_vm_size
    }
    dooku-win10 = {
      vm_name = "dooku-win10"
      ip      = "192.168.56.32"
      vm_details = {
        publisher = "MicrosoftWindowsDesktop"
        offer     = "Windows-10"
        sku       = "21h1-pro"
        version   = "latest"
      }
      vm_size = var.default_vm_size
    }
  }
}

module "windows-env" {
  source   = "./modules/windows-env"
  for_each = local.windows_env

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