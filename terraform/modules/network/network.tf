################################
# Virtual network
################################
resource "azurerm_virtual_network" "this" {
  for_each            = var.network
  name                = "${var.common.prefix}-${var.common.env}-${each.value.name}-vnet"
  address_space       = each.value.address_space
  location            = var.common.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "this" {
  for_each                                  = var.subnet
  name                                      = "${each.value.name}-subnet"
  resource_group_name                       = var.resource_group_name
  virtual_network_name                      = azurerm_virtual_network.this[each.value.target_vnet].name
  address_prefixes                          = each.value.address_prefixes
  private_endpoint_network_policies_enabled = each.value.private_endpoint_network_policies_enabled

  dynamic "delegation" {
    for_each = lookup(each.value, "service_delegation", null) != null ? [each.value.service_delegation] : []
    content {
      name = "delegation"
      service_delegation {
        name    = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }
}
