terraform {
  required_version = "~> 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.65.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.41.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_subscription" "primary" {}

resource "random_integer" "num" {
  min = 10000
  max = 99999
}


module "resource_group" {
  source = "../../modules/resource_group"

  common = var.common
}

module "user_assigned_identity" {
  source = "../../modules/user_assigned_identity"

  common                 = var.common
  resource_group_name    = module.resource_group.resource_group_name
  subscription_id        = local.common.subscription_id
  user_assigned_identity = var.user_assigned_identity
  role_assignment        = var.role_assignment
}

module "container_registry" {
  source = "../../modules/container_registry"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  container_registry  = var.container_registry
}

module "app_service_plan" {
  source = "../../modules/app_service_plan"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  app_service_plan    = var.app_service_plan
}

module "app_service" {
  source = "../../modules/app_service"

  common              = var.common
  resource_group_name = module.resource_group.resource_group_name
  app_service         = var.app_service
  app_settings        = local.app_service.app_settings
  allowed_origins     = local.app_service.allowed_origins
  allowed_cidr        = var.allowed_cidr
  app_service_plan    = module.app_service_plan.app_service_plan
  identity            = module.user_assigned_identity.user_assigned_identity
  frontdoor_profile   = module.frontdoor.frontdoor_profile
  tenant_id           = local.common.tenant_id
  auth_settings_v2    = local.app_service.auth_settings_v2
}

module "frontdoor" {
  source = "../../modules/frontdoor"

  common                 = var.common
  resource_group_name    = module.resource_group.resource_group_name
  frontdoor_profile      = var.frontdoor_profile
  frontdoor_endpoint     = var.frontdoor_endpoint
  frontdoor_origin_group = var.frontdoor_origin_group
  frontdoor_origin       = var.frontdoor_origin
  frontdoor_route        = var.frontdoor_route
  backend_origins        = local.front_door.backend_origins
}
