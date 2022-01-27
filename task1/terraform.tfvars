####################
# Common Variables #
####################
company     = "saipem.lab"
prefix      = "saipem"
environment = "dev"
location    = "northeurope"
description = "Deploy a Windows VM Scale Set"
owner       = "Me"
app_name    = "testing_task"

###########
# Network #
###########
network-vnet-cidr = "10.10.0.0/16"
vm-subnet-cidr    = "10.10.1.0/24"

##############
# Windows VM #
##############
windows-vm-hostname    = "winsrv-ad01" // Limited to 15 characters
windows-vm-size        = "Standard_B2s"
windows-vm-counter     = 1
windows-admin-username = "srvadmin"
windows-admin-password = "S3cr3ts24"

##################
# Authentication #
##################
azure-subscription-id = "complete-this"
azure-client-id       = "complete-this"
azure-client-secret   = "complete-this"
azure-tenant-id       = "complete-this"
