resource "azurerm_resource_group" "this" {
  name     = "${var.common.prefix}-${var.common.env}-rg"
  location = var.common.location
}
