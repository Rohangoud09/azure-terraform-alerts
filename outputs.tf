output "public_ip_address" {
  value = azurerm_public_ip.rohan_pip.ip_address
}
output "vm_username" {
  value = "rohan"
}
