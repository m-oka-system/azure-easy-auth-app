################################
# Web App for Containers
################################
resource "azurerm_linux_web_app" "this" {
  for_each                        = var.app_service
  name                            = "${var.common.prefix}-${var.common.env}-${each.value.name}"
  resource_group_name             = var.resource_group_name
  location                        = var.common.location
  service_plan_id                 = var.app_service_plan[each.value.target_service_plan].id
  https_only                      = each.value.https_only
  public_network_access_enabled   = each.value.public_network_access_enabled
  key_vault_reference_identity_id = var.identity[each.value.target_user_assigned_identity].id

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.identity[each.value.target_user_assigned_identity].id
    ]
  }

  app_settings = var.app_settings[each.key]

  sticky_settings {
    app_setting_names = each.value.sticky_settings.app_setting_names
  }

  site_config {
    always_on                                     = each.value.site_config.always_on
    ftps_state                                    = each.value.site_config.ftps_state
    vnet_route_all_enabled                        = each.value.site_config.vnet_route_all_enabled
    scm_use_main_ip_restriction                   = false
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = var.identity[each.value.target_user_assigned_identity].client_id

    dynamic "cors" {
      for_each = each.value.site_config.cors != null ? [true] : []

      content {
        allowed_origins     = var.allowed_origins[each.value.site_config.cors.allowed_origins_key]
        support_credentials = true
      }
    }

    dynamic "ip_restriction" {
      for_each = each.value.ip_restriction

      content {
        name        = ip_restriction.value.name
        priority    = ip_restriction.value.priority
        action      = ip_restriction.value.action
        ip_address  = lookup(ip_restriction.value, "ip_address", null) == "MyIP" ? join(",", [for ip in split(",", var.allowed_cidr) : "${ip}/32"]) : lookup(ip_restriction.value, "ip_address", null)
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

    dynamic "scm_ip_restriction" {
      for_each = each.value.scm_ip_restriction

      content {
        name        = scm_ip_restriction.value.name
        priority    = scm_ip_restriction.value.priority
        action      = scm_ip_restriction.value.action
        ip_address  = lookup(scm_ip_restriction.value, "ip_address", null) == "MyIP" ? join(",", [for ip in split(",", var.allowed_cidr) : "${ip}/32"]) : lookup(scm_ip_restriction.value, "ip_address", null)
        service_tag = scm_ip_restriction.value.service_tag
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

  dynamic "auth_settings_v2" {
    for_each = each.value.use_easy_auth ? [true] : []

    content {
      auth_enabled             = true
      default_provider         = "azureactivedirectory"
      require_authentication   = true
      require_https            = true
      unauthenticated_action   = "RedirectToLoginPage"
      forward_proxy_convention = "Standard"

      active_directory_v2 {
        client_id                  = var.auth_settings_v2[each.key].client_id
        client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
        tenant_auth_endpoint       = "https://sts.windows.net/${var.tenant_id}/v2.0"
        allowed_audiences          = ["api://${var.auth_settings_v2[each.key].client_id}"]
        login_parameters           = var.auth_settings_v2[each.key].login_parameters
      }

      login {
        token_store_enabled               = true
        validate_nonce                    = true
        preserve_url_fragments_for_logins = false
        cookie_expiration_convention      = "FixedTime"
        cookie_expiration_time            = "08:00:00"
        nonce_expiration_time             = "00:05:00"
        token_refresh_extension_time      = 72
      }
    }
  }

  lifecycle {
    ignore_changes = [
      site_config[0].application_stack[0],
      auth_settings_v2,
    ]
  }
}
