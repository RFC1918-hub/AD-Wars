variable "azure_region" {
}

variable "default_vm_size" {
  description = "Default azure vm size"
}

variable "admin_username" {
  description = "The username of the local administrator account on Azure VM's"
}

variable "admin_password" {
  description = "The password of the local administrator account on Azure VM's"
}

variable "ip_whitelist" {
  description = "A list of CIDRs that will be allowed to access the instance"
  type        = list(string)
}