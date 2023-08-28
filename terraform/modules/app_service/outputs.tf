output "app_service_plan" {
  value = azurerm_service_plan.this
}

output "app_service" {
  value = azurerm_linux_web_app.this
}
