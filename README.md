#Deployment

## Provision

Before you use Azure Storage as a backend, you must create a storage account.

Run the following commands or configuration to create an Azure storage account and container:

```
#!/bin/bash

RESOURCE_GROUP_NAME=tfstate
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location eastus

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
```

---

**Key points:**

* Public access is allowed to Azure storage account for storing Terraform state.
* Azure storage accounts require a globally unique name. To learn more about troubleshooting storage account names, see [Resolve errors for storage account names](https://github.com/MicrosoftDocs/azure-dev-docs/blob/main/azure/azure-resource-manager/templates/error-storage-account-name).


#### Azure Service Principal

Next we create a service principal that will be used by Terraform to authenticate to Azure **(Note down password)**

`# Create Service Principal`

```
az ad sp create-for-rbac --name atadjantf2
```

Assign role assignment to this newly created service principal (RBAC) to the required subscription. Further details on RBAC roles is documented [here](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)

## 3. Configure terraform backend state

To configure the backend state, you need the following Azure storage information:

* **storage_account_name** : The name of the Azure Storage account.
* **container_name** : The name of the blob container.
* **key** : The name of the state store file to be created.
* **access_key** : The storage access key.

Each of these values can be specified in the Terraform configuration file or on the command line. We recommend that you use an environment variable for the `access_key` value. Using an environment variable prevents the key from being written to disk.

Run the following commands to get the storage access key and store it as an environment variable:

# [Azure CLI](https://github.com/MicrosoftDocs/azure-dev-docs/blob/main/articles/terraform/store-state-in-azure-storage.md#tab/azure-cli)

```
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
export ARM_ACCESS_KEY=$ACCOUNT_KEY
```

Run the command `terraform init`, then `terraform apply` to configure the Azure storage account and container.

https://github.com/MicrosoftDocs/azure-dev-docs/blob/main/articles/terraform/store-state-in-azure-storage.md

https://thomasthornton.cloud/2021/03/19/deploy-terraform-using-github-actions-into-azure/
