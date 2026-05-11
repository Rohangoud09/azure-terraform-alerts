data "azurerm_resource_group" "rohan_rg" {
  name = "Rohan-rg"
}

data "azurerm_linux_virtual_machine" "existing_vm" {
  name                = "rohan-vm-new"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
}

resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  name                 = "AzureMonitorLinuxAgent"
  virtual_machine_id   = data.azurerm_linux_virtual_machine.existing_vm.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.0"

  auto_upgrade_minor_version = true
}
