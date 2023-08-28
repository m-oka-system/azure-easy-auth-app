#!/bin/bash
set -e

rgName="easyauth-dev-rg"
frontendAppName="easyauth-dev-frontend"

# Add Azure Cli extension
az extension add --name authV2

# Set login parameters
authSettings=$(az webapp auth show -g $rgName -n $frontendAppName)
authSettings=$(echo "$authSettings" | jq '.properties' | jq '.identityProviders.azureActiveDirectory.login += {"loginParameters":["scope=openid offline_access api://<back-end-client-id>/user_impersonation"]}')
az webapp auth set --resource-group $rgName --name $frontendAppName --body "$authSettings"
