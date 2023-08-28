locals {
  common = {
    subscription_id = data.azurerm_subscription.primary.subscription_id
    tenant_id       = data.azurerm_subscription.primary.tenant_id
    random          = random_integer.num.result
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
