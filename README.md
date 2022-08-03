# AD-Wars
Scalable Active Directory domain Azure sandbox equipped with security logging for blue and red teamers   

![AD Wars](./images/AD%20Wars.jpg)

# Getting started
## Requirements
To deploy AD-Wars sandbox you will need to have the following installed
* Terraform
* Ansible
* Azure subscription

## Installing requirements
Installing Terraform on windows using chocolatey:
https://learn.hashicorp.com/tutorials/terraform/install-cli

```powershell
choco install terraform
```


Installing Ansible on windows using Ubuntu sub-system: 
https://docs.microsoft.com/en-us/windows/wsl/install

```bash
python3 -m pip install --user ansible
```

## Building the VMs in Azure subscription using Terraform
> This has been tested running Terraform from windows.

```powershell
git clone [[repo]]
cd Terraform/
```

Before you can deploy to Azure you will need to update your terraform.tfvars file. You can do this by using the template file: **terraform.tfvars.template** 
This wil contain all your configuration variables. 

```
mv terraform.tfvars.template terraform.tfvars

# edit the variables according to your config
```

You will also need to authenticate against your Azure tenent. You can do so using the Az module.

https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-8.1.0

Once installed simply run 

```
az login

# confirm subscription by running 
az show account
```

Now you can deploy using Terraform: 
```
terraform init
terraform plan
terraform apply
```

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

## Configuring the sandbox using Ansible playbooks
Once your VMs are up and running using Terraform, replace the x.x.x.x IP address is the ansible hosts file with the public IP addresses from the output of the terraform deployment, as well as the ansible_username and ansible_password variables with what you set in the terraform.tfvars file. 

> Testing has been done using Ubuntu on WSL
> You might incounter the following error message
> [WARNING]: Ansible is being run in a world writable directory (/GitHub/AD-Wars/ansible), ignoring it as an ansible.cfg source. For more information see
> https://docs.ansible.com/ansible/devel/reference_appendices/config.html#cfg-in-world-writable-dir
> Using /etc/ansible/ansible.cfg as config file
> To fix this mv the ansible folder to the Ubuntu WSL sub-system.  

You can either just run main.yml to deploy all:

```
ansible-playbook main.yml
```

or run each task individual for troubleshooting

```
# -----------------------------------------
# Installing necessary utilities
ansible-playbook install-utilities.yml

# -----------------------------------------
# Configuring AD domain
ansible-playbook configure-domain.yml

# -----------------------------------------
# Configuring logger host 
ansible-playbook configure-logger.yml 

# -----------------------------------------
# Configuring servers
ansible-playbook configure-servers.yml

# -----------------------------------------
# Import domain objects
ansible-playbook import-domain-objects.yml 

# -----------------------------------------
# Configure vulnerabilities
ansible-playbook vulnerabilities.yml

# -----------------------------------------
# Configuring logging and splunk forwarders
ansible-playbook security-tools.yml
```

## Destroying the lab

```
terraform destroy
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
All domain config and deployment will be managed from the config/data/config.json file. 

When adding new hosts simple add the hosts configuration within the config/data/config.json file and update the hosts file accordingly.

Within the hosts file you will find the children groups. (Add the new hosts accordingly)

# TODO
- Fix GPO policies for advanced audit logging

# Links 
- https://github.com/clong/DetectionLab
- https://github.com/Orange-Cyberdefense/GOAD