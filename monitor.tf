data "azurerm_resource_group" "rohan_rg" {
  name = "Rohan-rg"
}

data "azurerm_resources" "existing_vm" {
  resource_group_name = data.azurerm_resource_group.rohan_rg.name

  type = "Microsoft.Compute/virtualMachines"
  name = "rohan-vm-new"
}
