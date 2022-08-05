/* Provisioning sandbox network */
/* sandbox network security group */
resource "azurerm_network_security_group" "sandbox-nsg" {
  name                = "${local.prefix}-nsg"
  location            = azurerm_resource_group.sandbox-rg.location
  resource_group_name = azurerm_resource_group.sandbox-rg.name

  # SSH access
  security_rule {
    name      = "SSH"
    priority  = 1003
    protocol  = "Tcp"
    access    = "Allow"
    direction = "Inbound"

    source_port_range          = "*"
    destination_port_range     = "22"
    # source_address_prefix      = "*"
    source_address_prefixes    = var.ip_whitelist
    destination_address_prefix = "*"
  }

  # HTTP access
  security_rule {
    name      = "HTTP"
    priority  = 1004
    protocol  = "Tcp"
    access    = "Allow"
    direction = "Inbound"

    source_port_range          = "*"
    destination_port_range     = "80"
    # source_address_prefix      = "*"
    source_address_prefixes    = var.ip_whitelist
    destination_address_prefix = "*"
  }

  # HTTPs access
  security_rule {
    name      = "HTTPs"
    priority  = 1005
    protocol  = "Tcp"
    access    = "Allow"
    direction = "Inbound"

    source_port_range          = "*"
    destination_port_range     = "443"
    # source_address_prefix      = "*"
    source_address_prefixes    = var.ip_whitelist
    destination_address_prefix = "*"
  }

  # RDP access
  security_rule {
    name      = "RDP"
    priority  = 1006
    protocol  = "Tcp"
    access    = "Allow"
    direction = "Inbound"

    source_port_range          = "*"
    destination_port_range     = "3389"
    # source_address_prefix      = "*"
    source_address_prefixes    = var.ip_whitelist
    destination_address_prefix = "*"
  }

  # WinRM access
  security_rule {
    name      = "WinRM"
    priority  = 1007
    protocol  = "Tcp"
    access    = "Allow"
    direction = "Inbound"

    source_port_range          = "*"
    destination_port_range     = "5985-5986"
    # source_address_prefix      = "*"
    source_address_prefixes    = var.ip_whitelist
    destination_address_prefix = "*"
  }

  # Splunk access
  security_rule {
    name      = "SplunkWeb"
    priority  = 1008
    protocol  = "Tcp"
    access    = "Allow"
    direction = "Inbound"

    source_port_range          = "*"
    destination_port_range     = "8000"
    # source_address_prefix      = "*"
    source_address_prefixes    = var.ip_whitelist
    destination_address_prefix = "*"
  }

  # Allow all traffic from the private subnet
  security_rule {
    name      = "PrivateSubnet-TCP"
    priority  = 1009
    protocol  = "Tcp"
    access    = "Allow"
    direction = "Inbound"

    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "192.168.56.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name      = "PrivateSubnet-UDP"
    priority  = 1010
    protocol  = "Udp"
    access    = "Allow"
    direction = "Inbound"

    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "192.168.56.0/24"
    destination_address_prefix = "*"
  }
}

/* sandbox virtual network */
resource "azurerm_virtual_network" "sandbox-vnet" {
  name                = "${local.prefix}-vnet"
  location            = azurerm_resource_group.sandbox-rg.location
  resource_group_name = azurerm_resource_group.sandbox-rg.name
  address_space       = ["192.168.0.0/16"]

  subnet {
    name           = "${local.prefix}-subnet"
    address_prefix = "192.168.56.0/24"
    security_group = azurerm_network_security_group.sandbox-nsg.id
  }
}