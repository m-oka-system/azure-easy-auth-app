################################
# Private Endpoint
################################
resource "azurerm_private_endpoint" "this" {
  for_each                      = var.private_endpoint
  name                          = "${each.value.name}-pe"
  resource_group_name           = var.resource_group_name
  location                      = var.common.location
  subnet_id                     = var.subnet[each.value.target_subnet].id
  custom_network_interface_name = "${each.value.name}-pe-nic"

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      var.private_dns_zone[each.value.target_private_dns_zone].id
    ]
  }

  private_service_connection {
    name                           = "connection"
    is_manual_connection           = false
    private_connection_resource_id = each.value.private_connection_resource_id
    subresource_names              = each.value.subresource_names
  }
}
