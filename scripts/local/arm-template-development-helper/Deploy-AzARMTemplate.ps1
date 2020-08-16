<#
    .DESCRIPTION
    Tests, Validates or Deploys Azure Resource Manager Template

    .PARAMETER Test
    Switch for only running the Offline Template Validation

    .PARAMETER WhatIf
    Switch for only running the What-If Validation, that simulates a deployment via the Azure ARM REST API

    .PARAMETER Force
    Switch for skipping the Confirmation Prompt for Deployment
    .NOTES
    MIT License

    Copyright (c) 2020 Mert Senel

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>
#Requires -Module @{ ModuleName = 'Az'; ModuleVersion = '4.2' }

[CmdletBinding()]
param (
    [Parameter()][switch]$WhatIf,
    [Parameter()][switch]$Test,
    [Parameter()][switch]$Force
)
#region Configuration
#Deployment Assets Configuration
# Go Up one level so you can pick a project
# This is here in case you want to keep your script in different folder.
$OperationsPath = Split-Path $PSScriptRoot 
$ArmArtifactsPath = "$OperationsPath\infrastructure" # Target the folder which desired ARM Template and Parameter files are in. 

#Azure Environment Configuration
$TenantId = '#{YOUR-AZUREAD-TENANT-ID}#'
$SubscriptionId = '#{YOUR-AZURE-SUBSCRIPTION-ID}#'
#endregion

#region Connect to Correct Tenant and Subscription
$CurrentContext = Get-AzContext
#If there is no AzContext found connect to desired Subscription and Tenant
if (!$CurrentContext) {
    Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId -UseDeviceAuthentication
    $CurrentContext = Get-AzContext
}
#If subscription ID doesnt match, call the Set-AzContext with 
#SubscriptionId and TenantId to allow switch between tenants as well. 
if ($CurrentContext.Subscription.Id -ne $SubscriptionId) {
    $CurrentContext = Set-AzContext -Subscription $SubscriptionId -Tenant $TenantId
}
#endregion

#region Service Constants
$ProjectName = 'mert'
$Stage = 'dev'
$ServiceType = 'fnc'
$Region = "wus"
#endregion

#region Service Curated Parameters
$ResourceGroupName = $ProjectName + $Stage + $ServiceType + $Region + '01'
$TemplateFile = "$ArmArtifactsPath\template.json"
$TemplateParameterFile = "$ArmArtifactsPath\parameters.$Stage.$($Region)01.json"

$ARGS = @{
    ResourceGroupName     = $ResourceGroupName
    TemplateFile          = $TemplateFile
    TemplateParameterFile = $TemplateParameterFile
    Mode                  = 'Incremental'
    Verbose               = $true
    ErrorAction           = 'Stop'
}
#endregion

#region Deployment Helpers
$ErrorActionPreference = "Stop"
if ($Test) {
    Test-AzResourceGroupDeployment @ARGS
    exit $LASTEXITCODE
}
if ($WhatIf) {
    $WhatIfResult = Get-AzResourceGroupDeploymentWhatIfResult @ARGS `
                                    -ResultFormat FullResourcePayloads
    $WhatIfResult
    exit $LASTEXITCODE
}
#endregion

#region Deployment ("Validate & Deploy" or "Forced" Deployment)
try {
    $PromptForConfirmation = (($Force) ? $false : $true)
    Write-Host "Deploying $Region"
    $Deployment = New-AzResourceGroupDeployment @ARGS `
                                                -Name "$(New-Guid)" `
                                                -Confirm:$PromptForConfirmation `
                                                -WhatIfResultFormat FullResourcePayloads
}
catch {
    Write-Host $_.Exception.Message
    exit $LASTEXITCODE
}

# Tell me If my Deployment was Successfull
if ($Deployment.ProvisioningState -eq "Succeeded") {
    Write-Host "Deployed $Region Successfully"
}
# Or if there was an error during Deployment I want to know about it
elseif ($Deployment.ProvisioningState -ne "Succeeded" -and ($Deployment.CorrelationId)) {
    Write-Host "$(Get-AzLog -CorrelationId $Deployment.CorrelationId)"
}
# Else just let me know if there was no AzResourceGroupDeployment Object found
elseif (!($Deployment)) {
    Write-Warning "No AzResourceGroupDeployment Object Found"
}
#endregion
