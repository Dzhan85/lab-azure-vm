#Deployment

## Provision script with GithubAction pipeline

## Before you use Azure Storage as a backend, you must create a storage account.

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

```

```

#### Azure Service Principal

Next we create a service principal that will be used by Terraform to authenticate to Azure **(Note down password)**

`Create Service Principal`

```
az ad sp create-for-rbac --name "atadjan" --role Contributor --scopes /subscriptions/id_subscription --sdk-auth
```

Note down these data and you will add these data into GithubAction secret section later

```
  "clientId": "cb7dff",
  "clientSecret": "JFpr9LG",
  "subscriptionId": "590",
  "tenantId": "",
```

You can additionally check and assign role assignment to this newly created service principal (RBAC) to the required subscription. Further details on RBAC roles is documented [here](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)

##### INFO:

https://docs.microsoft.com/en-us/azure/storage/common/storage-auth-aad-app?tabs=dotnet

#### Saving Service Principal credentials within GitHub Repository as secrets

Within the GitHub repository to where you are going to be running the terraform from, select settings -> secrets

Add 4 secrets

* AZURE_AD_CLIENT_ID – Will be the service principal ID from above
* AZURE_AD_CLIENT_SECRET – The secret that was created as part of the Azure Service Principal
* AZURE_AD_TENANT_ID – The Azure AD tenant ID to where the service principal was created
* AZURE_SUBSCRIPTION_ID – Subscription ID of where you want to deploy the Terraform


To add this GitHub Action to your repository, within your **GitHub Repo – select Actions -> Workflows -> New workflow  - terraform**

```
name: 'Terraform'
 
on:
  push:
    branches:
    - main
  pull_request:
 
jobs:
  terraform:
    name: 'Terraform'
    env:
      ARM_CLIENT_ID: ${{ secrets.AZURE_AD_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_AD_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_AD_TENANT_ID }}
    runs-on: ubuntu-latest
    environment: production
 
    # Use the Bash shell regardless whether the GitHub Actions runner is ubuntu-latest, macos-latest, or windows-latest
    defaults:
      run:
        shell: bash
 
    steps:
    # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v2
 
    - name: 'Terraform Format'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.8
        tf_actions_subcommand: 'fmt'
        tf_actions_working_dir: "./terraform"
     
    - name: 'Terraform Init'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.8
        tf_actions_subcommand: 'init'
        tf_actions_working_dir: "./terraform"
 
    - name: 'Terraform Validate'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.8
        tf_actions_subcommand: 'validate'
        tf_actions_working_dir: "./terraform"
     
    - name: 'Terraform Plan'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.8
        tf_actions_subcommand: 'plan'
        tf_actions_working_dir: "./terraform"
 
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main'
      #run: terraform apply -auto-approve
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.8
        tf_actions_subcommand: 'apply'
        tf_actions_working_dir: "./terraform"

    - name: Terraform Destroy
      if: github.ref == 'refs/heads/main'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: 0.14.8
        tf_actions_subcommand: 'destroy'
        tf_actions_working_dir: "./terraform"
  

```

## 2. Configure terraform backend state

To configure the backend state, you need the following Azure storage information:

* **storage_account_name** : The name of the Azure Storage account.
* **container_name** : The name of the blob container.
* **key** : The name of the state store file to be created.
* **resource_group_name** :

Each of these values can be specified in the Terraform configuration file or on the command line. We recommend that you use an environment variable for the  value. Using an environment variable prevents the key from being written to disk.

```

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate9903"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

}
```
