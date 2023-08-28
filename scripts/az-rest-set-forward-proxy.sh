#!/bin/bash
set -e

subscriptionId=$(az account show --query id -o tsv)
rgName="easyauth-dev-rg"
appNames=("easyauth-dev-frontend" "easyauth-dev-backend")

for appName in "${appNames[@]}"; do
  # Export authsettingsV2 configuration
  az rest --uri /subscriptions/"${subscriptionId}"/resourceGroups/"${rgName}"/providers/Microsoft.Web/sites/"${appName}"/config/authsettingsV2?api-version=2020-09-01 --method get >auth_"${appName}".json
  cp ./auth_"${appName}".json ./auth_"${appName}".json.org
  sed -i 's/"convention": "NoProxy"/"convention": "Standard"/g' auth_"${appName}".json

  # Import authsettingsV2 configuration
  az rest --uri /subscriptions/"${subscriptionId}"/resourceGroups/"${rgName}"/providers/Microsoft.Web/sites/"${appName}"/config/authsettingsV2?api-version=2020-09-01 --method put --body @auth_"${appName}".json
done
