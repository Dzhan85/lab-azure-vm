# Terraform Azure Windows Virtual Machine Scale Set

```
# Create Resource Group
az group create -n tamopstfstates -l eastus2
 
# Create Storage Account
az storage account create -n atadjantf -g tamopstfstates -l eastus2 --sku Standard_LRS
 
# Create Storage Account Container
az storage container create --account-name atadjantf --name atadjantfstatedevops --auth-mode login
```



```
# Create Service Principal 
az ad sp create-for-rbac --name atadjantf2
```




Within the GitHub repository to where you are going to be running the terraform from, select settings -> secrets

Add 4 secrets

* AZURE_AD_CLIENT_ID – Will be the service principal ID from above
* AZURE_AD_CLIENT_SECRET – The secret that was created as part of the Azure Service Principal
* AZURE_AD_TENANT_ID – The Azure AD tenant ID to where the service principal was created
* AZURE_SUBSCRIPTION_ID – Subscription ID of where you want to deploy the Terraform

Deploy a Windows Virtual Machine Scale Set in Azure using Terraform

Update the **sku** on this section of the **windows-vm-ss-main.tf** file, to configure the version of Windows Server.

```
source_image_reference {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = var.windows-2019-sku
  version   = "latest"
}
```

OS variables are located on the file **windows-vm-ss-variables.tf**

```
# Windows Server 2019 SKU used to build VMs
variable "windows-2019-sku" {
  type        = string
  description = "Windows Server 2019 SKU used to build VMs"
  default     = "2019-Datacenter"
}

# Windows Server 2016 SKU used to build VMs
variable "windows-2016-sku" {
  type        = string
  description = "Windows Server 2016 SKU used to build VMs"
  default     = "2016-Datacenter"
}

# Windows Server 2012 R2 SKU used to build VMs
variable "windows-2012-sku" {
  type        = string
  description = "Windows Server 2012 R2 SKU used to build VMs"
  default     = "2012-R2-Datacenter"
}
```
