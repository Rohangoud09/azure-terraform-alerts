data "azurerm_resource_group" "rohan_rg" {
  name = "Rohan-rg"
}

resource "azurerm_virtual_network" "rohan_vnet" {
  name                = "rohan-vnet-eastus-v3"
  address_space       = ["10.30.0.0/16"]
  location            = "East US"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
}

resource "azurerm_subnet" "rohan_subnet" {
  name                 = "rohan-subnet-eastus-v3"
  resource_group_name  = data.azurerm_resource_group.rohan_rg.name
  virtual_network_name = azurerm_virtual_network.rohan_vnet.name
  address_prefixes     = ["10.30.1.0/24"]
}

resource "azurerm_public_ip" "rohan_pip" {
  name                = "rohan-public-ip-eastus-v3"
  location            = "East US"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "rohan_nsg" {
  name                = "rohan-nsg-eastus-v3"
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

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-NodeJS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "rohan_nic" {
  name                = "rohan-nic-eastus-v3"
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
  name                = "rohan-vm-eastus-v3"
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
