variable "resource_group_name" {
  description = "The name of the Resource Group where the Domain Controllers resources will be created"
}

variable "location" {
  description = "The Azure Region in which the Resource Group exists"
}

variable "subnet_id" {
  description = "The Subnet ID which the Domain Controller's NIC should be created in"
}

variable "vm_name" {
  description = "The name of the virtual machine"
}

variable "vm_ip" {
  description = "The private IP address associated to the virtual machine"
}

variable "vm_details" {
  description = "Azure storage image reference details"
}

variable "vm_size" {
    description = "The Azure vm size used for the virtual machine"
}

variable "admin_username" {
  description = "The username associated with the local administrator account on the virtual machine"
}

variable "admin_password" {
  description = "The password associated with the local administrator account on the virtual machine"
}