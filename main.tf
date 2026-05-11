# =========================================
# RESOURCE GROUP
# =========================================

resource "azurerm_resource_group" "rohan_rg" {
  name     = "Rohan-rg"
  location = "Central India"
}

# =========================================
# VIRTUAL NETWORK
# =========================================

resource "azurerm_virtual_network" "rohan_vnet" {
  name                = "rohan-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rohan_rg.location
  resource_group_name = azurerm_resource_group.rohan_rg.name
}

# =========================================
# SUBNET
# =========================================

resource "azurerm_subnet" "rohan_subnet" {
  name                 = "rohan-subnet"
  resource_group_name  = azurerm_resource_group.rohan_rg.name
  virtual_network_name = azurerm_virtual_network.rohan_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# =========================================
# PUBLIC IP
# =========================================

resource "azurerm_public_ip" "rohan_public_ip" {
  name                = "rohan-public-ip"
  location            = azurerm_resource_group.rohan_rg.location
  resource_group_name = azurerm_resource_group.rohan_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# =========================================
# NETWORK SECURITY GROUP
# =========================================

resource "azurerm_network_security_group" "rohan_nsg" {
  name                = "rohan-nsg"
  location            = azurerm_resource_group.rohan_rg.location
  resource_group_name = azurerm_resource_group.rohan_rg.name

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

# =========================================
# NETWORK INTERFACE
# =========================================

resource "azurerm_network_interface" "rohan_nic" {
  name                = "rohan-nic"
  location            = azurerm_resource_group.rohan_rg.location
  resource_group_name = azurerm_resource_group.rohan_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.rohan_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rohan_public_ip.id
  }
}

# =========================================
# NSG ASSOCIATION
# =========================================

resource "azurerm_network_interface_security_group_association" "rohan_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.rohan_nic.id
  network_security_group_id = azurerm_network_security_group.rohan_nsg.id
}

# =========================================
# LINUX VIRTUAL MACHINE
# =========================================

resource "azurerm_linux_virtual_machine" "rohan_vm" {
  name                = "rohan-vm"
  resource_group_name = azurerm_resource_group.rohan_rg.name
  location            = azurerm_resource_group.rohan_rg.location
  size                = "Standard_B1s"
  admin_username      = "rohan"

  network_interface_ids = [
    azurerm_network_interface.rohan_nic.id,
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "rohan"
    
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgDTbbMTEJscglZaA804kQ5dsFAzglZ4TdWURIyF7qhXRUkYKSBXrQX22XnxNlicU4NZOTKNKedvZsKrkd4yjX1W+XEwnaAiFK6UTqMWNuIPjlIQ/R+jg4+v42A2st6sIdmKFGXazSLKmnsQxHHzifjcTqH5IF2aimrsDQI3uB3XZ/G/QPkzr5AE0mfQKdkm6uGDsEoKOJV37mL9y2ZLfUlVWD1bGcu4xSq7PhkuWJtmlXsdOtlNWXxrJRTZSQyVHYh+WQ8TDVWfFHRJCL1QPL2XsDvh/9LoEwT1noDs/fQ4iOjWj0D+sKydmb3ynRshsFX5J1aNdUyRPTfbhLsbOfkExUZ/JmPu66LhE3Lon56nUisj/F6i75quq4mkVgZMWRRcKOttYA4BikXftI5S+C4Q94xQHo2VAHgM2L4GlpL7S5Y1d1jJqfzY0/wCx2n5NHeDAryuia+6pOxEyxvPtmZq9pVF6ciKY69fcNIZbB5V6YKJjmIgU6KqsCDmuSui4FVB2wX5Ddobr3pZqU678ZaHjcqr/XJZ5+SyWFcx5sb1JOQIicjoDZX6BZF59de1v9MyS3T1xOWUGmRm9AvUuGMCfq9JH7O+V37xPdp/trPMHsqIt9ElsA5ZJJjNSzE6J7pF8FssZxylFtbBjvThhGMXR5Eokr5sCOGa+AOBg4FQ== rohan@LAPTOP-TQ2HLFNL"
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

  computer_name = "rohanvm"
}
