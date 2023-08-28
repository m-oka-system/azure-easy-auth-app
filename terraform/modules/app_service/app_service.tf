################################
# App Service
################################
resource "azurerm_service_plan" "this" {
  for_each            = var.service_plan
  name                = "${var.common.prefix}-${var.common.env}-${each.value.name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.common.location
  os_type             = each.value.os_type
  sku_name            = each.value.sku_name
}

resource "azurerm_linux_web_app" "this" {
  for_each                      = var.app_service
  name                          = "${var.common.prefix}-${var.common.env}-${each.value.name}"
  resource_group_name           = var.resource_group_name
  location                      = var.common.location
  service_plan_id               = azurerm_service_plan.this[each.value.target_service_plan].id
  https_only                    = each.value.https_only
  public_network_access_enabled = each.value.public_network_access_enabled


  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []
    content {
      type = identity.value.type
      identity_ids = [
        var.identity[each.value.target_user_assigned_identity].id
      ]
    }
  }

  app_settings = {}

  site_config {
    always_on                                     = each.value.site_config.always_on
    ftps_state                                    = each.value.site_config.ftps_state
    vnet_route_all_enabled                        = each.value.site_config.vnet_route_all_enabled
    scm_use_main_ip_restriction                   = true
    container_registry_use_managed_identity       = each.value.identity != null ? true : false
    container_registry_managed_identity_client_id = each.value.identity != null ? var.identity[each.value.target_user_assigned_identity].client_id : null

    dynamic "cors" {
      for_each = each.value.site_config.cors != null ? [each.value.site_config.cors] : []
      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }

    dynamic "ip_restriction" {
      for_each = each.value.ip_restriction

      content {
        name        = ip_restriction.value.name
        priority    = ip_restriction.value.priority
        action      = ip_restriction.value.action
        ip_address  = lookup(ip_restriction.value, "ip_address", null) == "MyIP" ? var.allowed_cidr : lookup(ip_restriction.value, "ip_address", null)
        service_tag = ip_restriction.value.service_tag

        dynamic "headers" {
          for_each = ip_restriction.key == "frontdoor" ? [true] : []

          content {
            x_azure_fdid = [
              var.frontdoor_profile[each.value.target_frontdoor_profile].resource_guid
            ]
            x_fd_health_probe = []
            x_forwarded_for   = []
            x_forwarded_host  = []
          }
        }
      }
    }

    dynamic "application_stack" {
      for_each = each.value.site_config.application_stack != null ? [each.value.site_config.application_stack] : []
      content {
        # Initial container image (overwritten by CI/CD)
        docker_image_name   = application_stack.value.docker_image_name
        docker_registry_url = application_stack.value.docker_registry_url
      }
    }
  }

  lifecycle {
    ignore_changes = [
      site_config[0].application_stack[0],
    ]
  }
}
