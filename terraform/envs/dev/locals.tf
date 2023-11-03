locals {
  common = {
    subscription_id = data.azurerm_subscription.primary.subscription_id
    tenant_id       = data.azurerm_subscription.primary.tenant_id
    random          = random_integer.num.result
  }

  app_service = {
    app_settings = {
      frontend = {
        "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET" = var.easy_auth["frontend"].client_secret
      }
      backend = {
        "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET" = var.easy_auth["backend"].client_secret
      }
    }

    allowed_origins = {}

    auth_settings_v2 = {
      frontend = {
        client_id = var.easy_auth["frontend"].client_id
        login_parameters = {
          "scope" = "openid offline_access api://${var.easy_auth["backend"].client_id}/user_impersonation"
        }
      }
      backend = {
        client_id        = var.easy_auth["backend"].client_id
        login_parameters = {}
      }
    }
  }

  front_door = {
    backend_origins = {
      frontend = {
        host_name          = module.app_service.app_service["frontend"].default_hostname
        origin_host_header = module.app_service.app_service["frontend"].default_hostname
      }
      backend = {
        host_name          = module.app_service.app_service["backend"].default_hostname
        origin_host_header = module.app_service.app_service["backend"].default_hostname
      }
    }
  }
}
