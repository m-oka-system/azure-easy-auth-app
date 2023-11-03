variable "common" {
  type = map(string)
  default = {
    prefix   = "easyauth"
    env      = "dev"
    location = "japaneast"
  }
}

variable "allowed_cidr" {
  type = string
}

variable "container_registry" {
  type = map(object({
    sku_name                      = string
    admin_enabled                 = bool
    public_network_access_enabled = bool
    zone_redundancy_enabled       = bool
  }))
  default = {
    app = {
      sku_name                      = "Basic"
      admin_enabled                 = false
      public_network_access_enabled = true
      zone_redundancy_enabled       = false
    }
  }
}

variable "app_service_plan" {
  type = map(map(string))
  default = {
    app = {
      name     = "app"
      os_type  = "Linux"
      sku_name = "B1"
    }
  }
}

variable "app_service" {
  type = map(object({
    name                          = string
    target_service_plan           = string
    target_subnet                 = string
    target_user_assigned_identity = string
    target_frontdoor_profile      = string
    https_only                    = bool
    public_network_access_enabled = bool
    sticky_settings = object({
      app_setting_names = list(string)
    })
    site_config = object({
      always_on              = bool
      ftps_state             = string
      vnet_route_all_enabled = bool
      cors = object({
        allowed_origins_key         = string
        allowed_origins_staging_key = string
        support_credentials         = bool
      })
      application_stack = object({
        docker_image_name   = string
        docker_registry_url = string
      })
    })
    ip_restriction = map(object({
      name        = string
      priority    = number
      action      = string
      ip_address  = string
      service_tag = string
    }))
    scm_ip_restriction = map(object({
      name        = string
      priority    = number
      action      = string
      ip_address  = string
      service_tag = string
    }))
    use_easy_auth = bool
  }))
  default = {
    frontend = {
      name                          = "frontend"
      target_service_plan           = "app"
      target_subnet                 = "app"
      target_user_assigned_identity = "frontend"
      target_frontdoor_profile      = "app"
      https_only                    = true
      public_network_access_enabled = true
      sticky_settings = {
        app_setting_names = [
          "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET",
        ]
      }
      site_config = {
        always_on              = false
        ftps_state             = "Disabled"
        vnet_route_all_enabled = true
        cors                   = null
        application_stack      = null
      }
      ip_restriction = {
        frontdoor = {
          name        = "AllowFrontDoor"
          priority    = 100
          action      = "Allow"
          ip_address  = null
          service_tag = "AzureFrontDoor.Backend"
        }
        myip = {
          name        = "AllowMyIP"
          priority    = 200
          action      = "Allow"
          ip_address  = "MyIP"
          service_tag = null
        }
      }
      scm_ip_restriction = {
        devops = {
          name        = "AllowDevOps"
          priority    = 100
          action      = "Allow"
          ip_address  = null
          service_tag = "AzureCloud"
        }
        myip = {
          name        = "AllowMyIP"
          priority    = 200
          action      = "Allow"
          ip_address  = "MyIP"
          service_tag = null
        }
      }
      use_easy_auth = false
    }
    backend = {
      name                          = "backend"
      target_service_plan           = "app"
      target_subnet                 = "app"
      target_user_assigned_identity = "backend"
      target_frontdoor_profile      = "app"
      https_only                    = true
      public_network_access_enabled = true
      sticky_settings = {
        app_setting_names = [
          "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET",
        ]
      }
      site_config = {
        always_on              = false
        ftps_state             = "Disabled"
        vnet_route_all_enabled = true
        cors                   = null
        application_stack = {
          docker_image_name   = "appsvc/staticsite:latest"
          docker_registry_url = "https://mcr.microsoft.com"
        }
      }
      ip_restriction = {
        frontdoor = {
          name        = "AllowFrontDoor"
          priority    = 100
          action      = "Allow"
          ip_address  = null
          service_tag = "AzureFrontDoor.Backend"
        }
        myip = {
          name        = "AllowMyIP"
          priority    = 200
          action      = "Allow"
          ip_address  = "MyIP"
          service_tag = null
        }
      }
      scm_ip_restriction = {
        devops = {
          name        = "AllowDevOps"
          priority    = 100
          action      = "Allow"
          ip_address  = null
          service_tag = "AzureCloud"
        }
        myip = {
          name        = "AllowMyIP"
          priority    = 200
          action      = "Allow"
          ip_address  = "MyIP"
          service_tag = null
        }
      }
      use_easy_auth = false
    }
  }
}

variable "easy_auth" {
  type = map(object({
    client_id     = string
    client_secret = string
  }))
}

variable "frontdoor_profile" {
  type = map(object({
    name                     = string
    sku_name                 = string
    response_timeout_seconds = number
  }))
  default = {
    app = {
      name                     = "app"
      sku_name                 = "Standard_AzureFrontDoor"
      response_timeout_seconds = 60
    }
  }
}

variable "frontdoor_endpoint" {
  type = map(object({
    name                     = string
    target_frontdoor_profile = string
  }))
  default = {
    frontend = {
      name                     = "frontend"
      target_frontdoor_profile = "app"
    }
    backend = {
      name                     = "backend"
      target_frontdoor_profile = "app"
    }
  }
}

variable "frontdoor_origin_group" {
  type = map(object({
    name                                                      = string
    target_frontdoor_profile                                  = string
    session_affinity_enabled                                  = bool
    restore_traffic_time_to_healed_or_new_endpoint_in_minutes = number
    load_balancing = object({
      additional_latency_in_milliseconds = number
      sample_size                        = number
      successful_samples_required        = number
    })
  }))
  default = {
    frontend = {
      name                                                      = "frontend"
      target_frontdoor_profile                                  = "app"
      session_affinity_enabled                                  = false
      restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
      load_balancing = {
        additional_latency_in_milliseconds = 50
        sample_size                        = 4
        successful_samples_required        = 3
      }
    }
    backend = {
      name                                                      = "backend"
      target_frontdoor_profile                                  = "app"
      session_affinity_enabled                                  = false
      restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
      load_balancing = {
        additional_latency_in_milliseconds = 50
        sample_size                        = 4
        successful_samples_required        = 3
      }
    }
  }
}

variable "frontdoor_origin" {
  type = map(object({
    name                           = string
    target_frontdoor_origin_group  = string
    target_backend_origin          = string
    certificate_name_check_enabled = bool
    http_port                      = number
    https_port                     = number
    priority                       = number
    weight                         = number
  }))
  default = {
    frontend = {
      name                           = "frontend"
      target_frontdoor_origin_group  = "frontend"
      target_backend_origin          = "frontend"
      certificate_name_check_enabled = true
      http_port                      = 80
      https_port                     = 443
      priority                       = 1
      weight                         = 1000
    }
    backend = {
      name                           = "backend"
      target_frontdoor_origin_group  = "backend"
      target_backend_origin          = "backend"
      certificate_name_check_enabled = true
      http_port                      = 80
      https_port                     = 443
      priority                       = 1
      weight                         = 1000
    }
  }
}

variable "frontdoor_route" {
  type = map(object({
    name                          = string
    target_frontdoor_endpoint     = string
    target_frontdoor_origin_group = string
    target_frontdoor_origin       = string
    forwarding_protocol           = string
    https_redirect_enabled        = bool
    patterns_to_match             = list(string)
    supported_protocols           = list(string)
    link_to_default_domain        = bool
    cache = object({
      compression_enabled           = bool
      query_string_caching_behavior = string
      query_strings                 = list(string)
      content_types_to_compress     = list(string)
    })
  }))
  default = {
    frontend = {
      name                          = "frontend"
      target_frontdoor_endpoint     = "frontend"
      target_frontdoor_origin_group = "frontend"
      target_frontdoor_origin       = "frontend"
      forwarding_protocol           = "HttpsOnly"
      https_redirect_enabled        = true
      patterns_to_match             = ["/*"]
      supported_protocols           = ["Http", "Https"]
      link_to_default_domain        = true
      cache                         = null
    }
    backend = {
      name                          = "backend"
      target_frontdoor_endpoint     = "backend"
      target_frontdoor_origin_group = "backend"
      target_frontdoor_origin       = "backend"
      forwarding_protocol           = "HttpsOnly"
      https_redirect_enabled        = true
      patterns_to_match             = ["/*"]
      supported_protocols           = ["Http", "Https"]
      link_to_default_domain        = true
      cache                         = null
    }
  }
}

variable "user_assigned_identity" {
  type = map(object({
    name = string
  }))
  default = {
    frontend = {
      name = "frontend"
    }
    backend = {
      name = "backend"
    }
  }
}

variable "role_assignment" {
  type = map(object({
    target_identity      = string
    role_definition_name = string
  }))
  default = {
    app_acr_pull = {
      target_identity      = "backend"
      role_definition_name = "AcrPull"
    }
  }
}
