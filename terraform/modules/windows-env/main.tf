/* Provisioning required NIC */
resource "azurerm_network_interface" "nic" {
  name                    = "${var.vm_name}-nic"
  location                = var.location
  resource_group_name     = var.resource_group_name
  internal_dns_name_label = var.vm_name

  ip_configuration {
    name                          = "${var.vm_name}-nic-conf"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vm_ip
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }

  tags = {
    "role" = var.vm_name
  }
}

/* Provisioning public IP */
resource "azurerm_public_ip" "publicip" {
  name                = "${var.vm_name}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"

  tags = {
    "role" = var.vm_name
  }
}

/* Provisioning VM */
resource "azurerm_virtual_machine" "provision-vm" {
  name = var.vm_name
  location = var.location
  resource_group_name = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size = var.vm_size

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.vm_details["publisher"]
    offer     = var.vm_details["offer"]
    sku       = var.vm_details["sku"]
    version   = var.vm_details["version"]
  }

  storage_os_disk {
    name              = "${var.vm_name}-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.vm_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = false
    winrm {
      protocol = "HTTP"
    }
  }
  
  tags = {
    role = var.vm_name
  }
}