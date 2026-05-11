resource "azurerm_monitor_action_group" "rohan_action_group" {
  name                = "rohan-action-group-new"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  short_name          = "rohanag"

  email_receiver {
    name          = "send-email"
    email_address = "rohangoud0999@gmail.com"
  }
}

# ================= CPU CRITICAL ALERT =================

resource "azurerm_monitor_metric_alert" "cpu_critical_alert" {
  name                = "cpu-critical-alert"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  scopes              = [azurerm_linux_virtual_machine.rohan_vm_new.id]
  description         = "Critical alert when CPU usage is above 95%"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 95
  }

  frequency   = "PT1M"
  window_size = "PT5M"
  severity    = 0

  action {
    action_group_id = azurerm_monitor_action_group.rohan_action_group.id
  }
}

# ================= MEMORY CRITICAL ALERT =================

resource "azurerm_monitor_metric_alert" "memory_critical_alert" {
  name                = "memory-critical-alert"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  scopes              = [azurerm_linux_virtual_machine.rohan_vm_new.id]
  description         = "Critical alert when memory usage is high"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 200000000
  }

  frequency   = "PT1M"
  window_size = "PT5M"
  severity    = 0

  action {
    action_group_id = azurerm_monitor_action_group.rohan_action_group.id
  }
}

# ================= DISK CRITICAL ALERT =================

resource "azurerm_monitor_metric_alert" "disk_critical_alert" {
  name                = "disk-critical-alert"
  resource_group_name = data.azurerm_resource_group.rohan_rg.name
  scopes              = [azurerm_linux_virtual_machine.rohan_vm_new.id]
  description         = "Critical alert when disk usage is high"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "OS Disk Queue Depth"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 5
  }

  frequency   = "PT1M"
  window_size = "PT5M"
  severity    = 0

  action {
    action_group_id = azurerm_monitor_action_group.rohan_action_group.id
  }
}
