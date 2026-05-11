resource "azurerm_monitor_action_group" "rohan_action_group" {
  name                = "rohan-action-group-task5-final"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  short_name          = "rohanag"

  email_receiver {
    name          = "send-email"
    email_address = "rohangoud0999@gmail.com"
  }
}

resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "high-cpu-alert-task5-final"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  scopes              = [azurerm_linux_virtual_machine.rohan_vm.id]

  description = "Alert when CPU usage is high"
  severity    = 2
  frequency   = "PT1M"
  window_size = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.rohan_action_group.id
  }
}
