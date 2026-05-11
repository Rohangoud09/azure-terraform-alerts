resource "azurerm_monitor_action_group" "rohan_action_group" {
  name                = "rohan-action-group-existingvm-v2"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  short_name          = "rohanag"

  email_receiver {
    name          = "send-email"
    email_address = "rohangoud0999@gmail.com"
  }
}

resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "high-cpu-alert-existingvm-v2"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  scopes              = [data.azurerm_resources.existing_vm.resources[0].id]

  description = "CPU usage alert"
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

resource "azurerm_monitor_metric_alert" "memory_alert" {
  name                = "high-memory-alert-existingvm-v2"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  scopes              = [data.azurerm_resources.existing_vm.resources[0].id]

  description = "Memory usage alert"
  severity    = 2
  frequency   = "PT1M"
  window_size = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 200000000
  }

  action {
    action_group_id = azurerm_monitor_action_group.rohan_action_group.id
  }
}

resource "azurerm_monitor_metric_alert" "disk_alert" {
  name                = "high-disk-alert-existingvm-v2"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  scopes              = [data.azurerm_resources.existing_vm.resources[0].id]

  description = "Disk usage alert"
  severity    = 2
  frequency   = "PT1M"
  window_size = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "OS Disk Queue Depth"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 5
  }

  action {
    action_group_id = azurerm_monitor_action_group.rohan_action_group.id
  }
}
