################################
# User Assigned Managed ID
################################
resource "azurerm_user_assigned_identity" "this" {
  for_each            = var.user_assigned_identity
  name                = "${var.common.prefix}-${var.common.env}-${each.value.name}-mngid"
  resource_group_name = var.resource_group_name
  location            = var.common.location
}

resource "azurerm_role_assignment" "this" {
  for_each             = var.role_assignment
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = each.value.role_definition_name
  principal_id         = azurerm_user_assigned_identity.this[each.value.target_identity].principal_id
}
