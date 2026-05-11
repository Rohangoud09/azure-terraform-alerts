resource "azurerm_resource_group" "rohan-rg" {
  name     = "Rohan-rg"
  location = "Central India"
}

resource "azurerm_virtual_network" "rohan_vnet" {
  name                = "rohan-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rohan-rg.location
  resource_group_name = azurerm_resource_group.rohan-rg.name
}

resource "azurerm_subnet" "rohan_subnet" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.rohan-rg.name
  virtual_network_name = azurerm_virtual_network.rohan_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "rohan_nsg" {
  name                = "rohan-vm-nsg"
  location            = azurerm_resource_group.rohan-rg.location
  resource_group_name = azurerm_resource_group.rohan-rg.name

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

resource "azurerm_public_ip" "rohan_public_ip" {
  name                = "rohan-public-ip"
  location            = azurerm_resource_group.rohan-rg.location
  resource_group_name = azurerm_resource_group.rohan-rg.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "rohan_nic" {
  name                = "rohan-nic"
  location            = azurerm_resource_group.rohan-rg.location
  resource_group_name = azurerm_resource_group.rohan-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.rohan_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rohan_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "rohan_nsg_association" {
  network_interface_id      = azurerm_network_interface.rohan_nic.id
  network_security_group_id = azurerm_network_security_group.rohan_nsg.id
}

resource "azurerm_linux_virtual_machine" "rohan_vm" {
  name                  = "rohan-linux-vm"
  location              = azurerm_resource_group.rohan-rg.location
  resource_group_name   = azurerm_resource_group.rohan-rg.name
  network_interface_ids = [azurerm_network_interface.rohan_nic.id]
  size                  = "Standard_B1s"

  computer_name  = "rohanvm"
  admin_username = "rohan"

  disable_password_authentication = true

  admin_ssh_key {
    username   = "rohan"
    public_key = file("~/.ssh/id_rsa.pub")
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

  provisioner "remote-exec" {

    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install nginx -y",

      "echo '<html><body><h1>Welcome to Rohan Azure Terraform Project 🚀</h1></body></html>' | sudo tee /var/www/html/index.html",

      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      user        = "rohan"
      private_key = file("~/.ssh/id_rsa")
      host        = azurerm_public_ip.rohan_public_ip.ip_address
    }
  }
}
