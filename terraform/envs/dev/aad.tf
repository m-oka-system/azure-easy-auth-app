# resource "random_uuid" "oauth2_permission_scope_id" {}

# resource "azuread_application" "this" {
#   display_name     = "easyauth-dev-frontend"
#   identifier_uris  = ["api://easyauth-dev-frontend"]
#   sign_in_audience = "AzureADMyOrg"

#   api {
#     requested_access_token_version = 2

#     oauth2_permission_scope {
#       admin_consent_description  = "Allow the application to access easyauth-dev-frontend on behalf of the signed-in user."
#       admin_consent_display_name = "Access easyauth-dev-frontend"
#       enabled                    = true
#       id                         = random_uuid.oauth2_permission_scope_id.result
#       type                       = "User"
#       user_consent_description   = "Allow the application to access easyauth-dev-frontend on your behalf."
#       user_consent_display_name  = "Access easyauth-dev-frontend"
#       value                      = "user_impersonation"
#     }
#   }
# }

# resource "azuread_application_password" "this" {
#   application_object_id = azuread_application.this.object_id
# }
