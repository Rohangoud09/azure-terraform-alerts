data "azurerm_resource_group" "rohan_rg" {
  name = "Rohan-rg"
}

resource "azurerm_virtual_network" "rohan_vnet" {
  name                = "rohan-vnet-new"
  address_space       = ["10.1.0.0/16"]
  location            = data.azurerm_resource_group.rohan_rg.location
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
}

resource "azurerm_subnet" "rohan_subnet" {
  name                 = "rohan-subnet-new"
  resource_group_name  = data.azurerm_resource_group.rohan_rg.name
  virtual_network_name = azurerm_virtual_network.rohan_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "rohan_pip" {
  name                = "rohan-public-ip-new"
  location            = data.azurerm_resource_group.rohan_rg.location
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "rohan_nsg" {
  name                = "rohan-nsg-new"
  location            = data.azurerm_resource_group.rohan_rg.location
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
}

resource "azurerm_network_interface" "rohan_nic" {
  name                = "rohan-nic-new"
  location            = data.azurerm_resource_group.rohan_rg.location
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

resource "tls_private_key" "rohan_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "rohan_vm" {
  name                = "rohan-vm-new"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  location            = data.azurerm_resource_group.rohan_rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.rohan_nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.rohan_ssh.public_key_openssh
  }

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

  disable_password_authentication = true

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      user        = "azureuser"
      private_key = tls_private_key.rohan_ssh.private_key_pem
      host        = self.public_ip_address
    }
  }
}
