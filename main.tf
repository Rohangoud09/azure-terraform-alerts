data "azurerm_resource_group" "rohan_rg" {
  name = "Rohan-rg"
}

resource "azurerm_virtual_network" "rohan_vnet" {
  name                = "rohan-vnet-eastus-alerts-v1"
  address_space       = ["10.40.0.0/16"]
  location            = "East US"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
}

resource "azurerm_subnet" "rohan_subnet" {
  name                 = "rohan-subnet-eastus-alerts-v1"
  resource_group_name  = data.azurerm_resource_group.rohan_rg.name
  virtual_network_name = azurerm_virtual_network.rohan_vnet.name
  address_prefixes     = ["10.40.1.0/24"]
}

resource "azurerm_public_ip" "rohan_pip" {
  name                = "rohan-public-ip-eastus-alerts-v1"
  location            = "East US"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "rohan_nsg" {
  name                = "rohan-nsg-eastus-alerts-v1"
  location            = "East US"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "rohan_nic" {
  name                = "rohan-nic-eastus-alerts-v1"
  location            = "East US"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.rohan_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rohan_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "rohan_assoc" {
  network_interface_id      = azurerm_network_interface.rohan_nic.id
  network_security_group_id = azurerm_network_security_group.rohan_nsg.id
}

resource "azurerm_linux_virtual_machine" "rohan_vm" {
  name                = "rohan-vm-eastus-alerts-v1"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  location            = "East US"
  size                = "Standard_B1ls"
  admin_username      = "azureuser"
  admin_password      = "Rohan@123456"

  network_interface_ids = [
    azurerm_network_interface.rohan_nic.id
  ]

  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  name                 = "AzureMonitorLinuxAgent"
  virtual_machine_id   = azurerm_linux_virtual_machine.rohan_vm.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.0"

  auto_upgrade_minor_version = true
}
