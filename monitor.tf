# =========================================
# ACTION GROUP
# =========================================

resource "azurerm_monitor_action_group" "rohan_action_group" {
  name                = "rohan-action-group"
  resource_group_name = azurerm_resource_group.rohan_rg.name
  short_name          = "rohanag"

  email_receiver {
    name          = "rohan-email"
    email_address = "rohangoud0999@gmail.com"
  }
}

# =========================================
# CPU ALERT
# =========================================

resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "rohan-cpu-alert"
  resource_group_name = azurerm_resource_group.rohan_rg.name
  scopes              = [azurerm_linux_virtual_machine.rohan_vm.id]
  description         = "Alert when CPU usage is high"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

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

# =========================================
# MEMORY ALERT
# =========================================

resource "azurerm_monitor_metric_alert" "memory_alert" {
  name                = "rohan-memory-alert"
  resource_group_name = azurerm_resource_group.rohan_rg.name
  scopes              = [azurerm_linux_virtual_machine.rohan_vm.id]
  description         = "Alert when memory usage is high"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1000000000
  }

  action {
    action_group_id = azurerm_monitor_action_group.rohan_action_group.id
  }
}

# =========================================
# DISK ALERT
# =========================================

resource "azurerm_monitor_metric_alert" "disk_alert" {
  name                = "rohan-disk-alert"
  resource_group_name = azurerm_resource_group.rohan_rg.name
  scopes              = [azurerm_linux_virtual_machine.rohan_vm.id]
  description         = "Alert when disk usage is high"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

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
