/* Provisioning sandbox network */

locals {
  firewall_rules = {
    SSH = {
      priority  = 1000
      protocol = "Tcp"
      access =  "Allow"
      direction = "Inbound"
      source_port_range = "*"
      destination_port_range = "22"
      source_address_prefixes = var.ip_whitelist
      destination_address_prefix = "*"
    },
    HTTP = {
      priority  = 1001
      protocol = "Tcp"
      access =  "Allow"
      direction = "Inbound"
      source_port_range = "*"
      destination_port_range = "80"
      source_address_prefixes = var.ip_whitelist
      destination_address_prefix = "*"
    },
    HTTPs = {
      priority  = 1002
      protocol = "Tcp"
      access =  "Allow"
      direction = "Inbound"
      source_port_range = "*"
      destination_port_range = "443"
      source_address_prefixes = var.ip_whitelist
      destination_address_prefix = "*"
    },
    RDP = {
      priority  = 1003
      protocol = "Tcp"
      access =  "Allow"
      direction = "Inbound"
      source_port_range = "*"
      destination_port_range = "3389"
      source_address_prefixes = var.ip_whitelist
      destination_address_prefix = "*"
    },
    WinRM = {
      priority  = 1004
      protocol = "Tcp"
      access =  "Allow"
      direction = "Inbound"
      source_port_range = "*"
      destination_port_range = "5985-5986"
      source_address_prefixes = var.ip_whitelist
      destination_address_prefix = "*"
    },
    Splunk = {
      priority  = 1005
      protocol = "Tcp"
      access =  "Allow"
      direction = "Inbound"
      source_port_range = "*"
      destination_port_range = "8000"
      source_address_prefixes = var.ip_whitelist
      destination_address_prefix = "*"
    },
    IIS = {
      priority  = 1006
      protocol = "Tcp"
      access =  "Allow"
      direction = "Inbound"
      source_port_range = "*"
      destination_port_range = "8080"
      source_address_prefixes = var.ip_whitelist
      destination_address_prefix = "*"
    },
    PrivateSubnet_TCP = {
      priority  = 1007
      protocol = "Tcp"
      access =  "Allow"
      direction = "Inbound"
      source_port_range = "*"
      destination_port_range = "*"
      source_address_prefixes = "192.168.56.0/24"
      destination_address_prefix = "*"
    },
    PrivateSubnet_UDP = {
      priority  = 1008
      protocol = "Udp"
      access =  "Allow"
      direction = "Inbound"
      source_port_range = "*"
      destination_port_range = "*"
      source_address_prefixes = "192.168.56.0/24"
      destination_address_prefix = "*"
    }    
  }
}

/* sandbox network security group */
resource "azurerm_network_security_group" "sandbox-nsg" {
  name                = "${local.prefix}-nsg"
  location            = azurerm_resource_group.sandbox-rg.location
  resource_group_name = azurerm_resource_group.sandbox-rg.name
}

resource "azurerm_network_security_rule" "sandbox-nsg-securityrules" {
  for_each = local.firewall_rules

  resource_group_name = azurerm_resource_group.sandbox-rg.name
  network_security_group_name = azurerm_network_security_group.sandbox-nsg.name

  name      = each.key
  priority  = each.value.priority
  protocol  = each.value.protocol
  access    = each.value.access
  direction = each.value.direction

  source_port_range          = each.value.source_port_range
  destination_port_range     = each.value.destination_port_range
  # source_address_prefix      = "*"
  source_address_prefixes    = each.value.source_address_prefixes
  destination_address_prefix = each.value.destination_address_prefix
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