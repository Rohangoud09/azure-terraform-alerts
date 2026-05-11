output "public_ip_address" {
  value = azurerm_public_ip.rohan_public_ip.ip_address
}

output "vm_username" {
  value = "rohan"
}
