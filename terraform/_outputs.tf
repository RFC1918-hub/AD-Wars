output "azure-region" {
  value = var.azure_region
}

output "windows-vm-publicip" {
  value = {
    for k, v in module.windows-env : k => v.vm-publicip
  }
}

output "linux-vm-publicip" {
  value = {
    for k, v in module.linux-env : k => v.vm-publicip
  }
}