## <https://www.terraform.io/docs/providers/azurerm/index.html>
# provider "azurerm" {
#   version = "=2.5.0"
#   features {}
# }

# Bootstrapping Script
# data "template_file" "tf-script" {
#   template = file("setup.ps1")
# }
## <https://www.terraform.io/docs/providers/azurerm/r/resource_group.html>
resource "azurerm_resource_group" "rg" {
  name     = "TerraformTesting"
  location = "eastus"
}
resource "azurerm_public_ip" "windows-vm-ip" {
  name                = "${var.windows-vm-hostname}-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"

  # tags = {
  #   application = "back-end"
  #   environment = "dev"
  # }
}

## <https://www.terraform.io/docs/providers/azurerm/r/availability_set.html>
resource "azurerm_availability_set" "DemoAset" {
  name                = "example-aset"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

## <https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html>
resource "azurerm_virtual_network" "vnet" {
  name                = "vNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

## <https://www.terraform.io/docs/providers/azurerm/r/subnet.html> 
resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

## <https://www.terraform.io/docs/providers/azurerm/r/network_interface.html>
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows-vm-ip.id
  }
}

## <https://www.terraform.io/docs/providers/azurerm/r/windows_virtual_machine.html>
resource "azurerm_windows_virtual_machine" "example" {
  name                = "${var.windows-vm-hostname}-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = var.windows-admin-username
  admin_password      = var.windows-admin-password
  availability_set_id = azurerm_availability_set.DemoAset.id
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    name                 = "${var.windows-vm-hostname}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.windows-2019-sku
    version   = "latest"
  }

}

resource "azurerm_virtual_machine_extension" "vmext" {
  name                 = azurerm_windows_virtual_machine.example.name
  virtual_machine_id   = azurerm_windows_virtual_machine.example.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1",
        "fileUris": ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"]
    }
SETTINGS

}