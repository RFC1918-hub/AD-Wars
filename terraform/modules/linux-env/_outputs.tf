output "vm-publicip" {
  value = azurerm_public_ip.publicip.ip_address
}