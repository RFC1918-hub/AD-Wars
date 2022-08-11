# AD-Wars
Scalable Active Directory domain Azure sandbox equipped with security logging for blue and red teamers   

![AD Wars](./images/AD%20Wars.jpg)

# Getting started
## Prerequisites
- [Install Terraform](https://www.terraform.io/downloads)
- [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
  > You can use the Ubuntu WSL subsystem on windows to install ansible as well
- Have a [Azure subscription](https://azure.microsoft.com/en-us/free/)

# Installation steps
## Building the VMs using Terraform
1. Configure the `terraform.tfvars` file
  - Copy the file `terraform/terraform.tfvars.template` to `terraform/terraform.tfvars`
  - In the newly copied terraform.tfvars file, provide the values for each variable
2. Authenticate to Azure using `az`
  - Run `az login`. This should bring up a browser that asks you to sign into your Azure account
  - TO confirm you've been authenticated successfully, run `az account show`
3. Bring up the VM's using Terraform
  - `cd` to `terraform` and run `terraform init` to initialize the working directory
  - Run `terraform apply` to check the Terraform plan or `terraform apply --auto-approve` to bypass the check
4. Wait for Terraform to finish running. Once finished you should see the Terraform output with the VM's public IP's that you will need for the next step. 

**Output example:**
```
Outputs:

azure-region = "East US"
linux-vm-publicip = {
  "logger" = "52.149.130.72"
}
windows-vm-publicip = {
  "dooku-win10" = "13.72.82.109"
  "jedi-archives" = "52.149.130.37"
  "republic-dc" = "52.149.128.99"
  "security-dc" = "52.149.128.126"
}
```

## Configuring the sandbox environment using Ansible playbooks. 
1. Configure the `hosts` file
  - Copy the file `ansible/hosts.template` to `ansible/hosts`
  - In the newly copied hosts file, provide the values for each variable (this will be the public IP's from the previous step)
2. You can either run `ansible-playbook main.yml` to run all playbooks, or for troubleshooting you can run them one for one by running: 

```
ansible-playbook install-utilities.yml      # Installing necessary utilities
ansible-playbook configure-domain.yml       # Configuring AD domain
ansible-playbook configure-logger.yml       # Configuring logger host
ansible-playbook configure-servers.yml      # Configuring servers
ansible-playbook import-domain-objects.yml  # Import domain objects
ansible-playbook vulnerabilities.yml        # Configure vulnerabilities
ansible-playbook security-tools.yml         # Configuring logging and splunk forwarders
```

## Destroying the lab

```
terraform destroy
```

## Managing the VM's
You can use the `manage_azure_vms.ps1` to shutdown and boot the VM's in Azure for cost saving

```
./manage_azure_vms.ps1 # list VM's
./manage_azure_vms.ps1 -shutdown
./manage_azure_vms.ps1 -boot
```

# Lab details

## Terraform config
The Terraform modules where designed to be scalable in linux and windows VMs. 
This can be done by simply adding to the windows_env or linux_env locals within windows-env.tf and linux-env.tf

**Template for adding new host:**
```
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
```

## Ansible config
All domain config and deployment will be managed from the ansible/config/data/config.json file. 
When adding new hosts simple add the hosts configuration within the ansible/config/data/config.json file and update the hosts file accordingly.
Within the hosts file you will find the children groups. (Add the new hosts accordingly)

# Links 
- https://github.com/clong/DetectionLab
- https://github.com/Orange-Cyberdefense/GOAD
