#!/bin/bash

# Configuration
OperationsPath="$(dirname "$(readlink -f "$0")")"
ArmArtifactsPath="$OperationsPath/infrastructure"

# Azure Environment Configuration
TenantId='#{YOUR-AZUREAD-TENANT-ID}#'
SubscriptionId='#{YOUR-AZURE-SUBSCRIPTION-ID}#'

# Connect to the Correct Tenant and Subscription
CurrentContext=$(az account show --query "{SubscriptionId:id,TenantId:tenantId}" --output json)
if [ -z "$CurrentContext" ]; then
    az login --service-principal -u "$TenantId" -p "$SubscriptionId" --tenant "$TenantId"
fi

# Service Constants
ProjectName='mert'
Stage='dev'
ServiceType='fnc'
Region='wus'

# Service Curated Parameters
ResourceGroupName="${ProjectName}${Stage}${ServiceType}${Region}01"
TemplateFile="$ArmArtifactsPath/template.json"
TemplateParameterFile="$ArmArtifactsPath/parameters.${Stage}.${Region}01.json"

# Deployment Helpers
export ErrorActionPreference="Stop"
if [ "$Test" = true ]; then
    az deployment group validate \
        --resource-group "$ResourceGroupName" \
        --template-file "$TemplateFile" \
        --parameters "@$TemplateParameterFile"
    exit $?
fi

if [ "$WhatIf" = true ]; then
    az deployment group what-if \
        --resource-group "$ResourceGroupName" \
        --template-file "$TemplateFile" \
        --parameters "@$TemplateParameterFile"
    exit $?
fi

# Deployment ("Validate & Deploy" or "Forced" Deployment)
echo "Deploying $Region"
DeploymentName=$(uuidgen)
az deployment group create \
    --name "$DeploymentName" \
    --resource-group "$ResourceGroupName" \
    --template-file "$TemplateFile" \
    --parameters "@$TemplateParameterFile" \
    --mode Incremental \
    --verbose

DeploymentProvisioningState=$(az deployment group show \
    --name "$DeploymentName" \
    --resource-group "$ResourceGroupName" \
    --query "provisioningState" \
    --output tsv)

# Tell me if my Deployment was Successful
if [ "$DeploymentProvisioningState" = "Succeeded" ]; then
    echo "Deployed $Region Successfully"
    exit 0
fi

# Or if there was an error during Deployment, I want to know about it
if [ "$DeploymentProvisioningState" != "Succeeded" ]; then
    CorrelationId=$(az deployment group show \
        --name "$DeploymentName" \
        --resource-group "$ResourceGroupName" \
        --query "correlationId" \
        --output tsv)

    az monitor activity-log list \
        --correlation-id "$CorrelationId" \
        --query "[].{Message:properties.statusMessage}" \
        --output table

    exit 1
fi

# Else just let me know if there was no AzResourceGroupDeployment Object found
echo "No AzResourceGroupDeployment Object Found"
exit 1
