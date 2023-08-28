################################
# Azure Container Registry
################################
resource "azurerm_container_registry" "this" {
  for_each                      = var.container_registry
  name                          = "${var.common.prefix}${var.common.env}acr"
  resource_group_name           = var.resource_group_name
  location                      = var.common.location
  sku                           = each.value.sku_name
  admin_enabled                 = each.value.admin_enabled
  public_network_access_enabled = each.value.public_network_access_enabled
  zone_redundancy_enabled       = each.value.zone_redundancy_enabled
}
