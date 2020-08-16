function Set-MyAzSub {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)][string]$SubCode
    )
    
    $SubscriptionTable = @{
        'proj1-dev'  = @{
            'SubscriptionName' = '' #Name of subscription Ex: 'Project1 - Development'
            'SubscriptionId'   = '' #Subscription ID(GUID) Ex: cb9ace2f-e5e1-42ba-afe2-b9a4d6126e01
            'TenantId'         = '' #Tenant ID(GUID) Ex: 0c683a78-b01a-4f8c-98ff-402276a56b22
        }
        'proj1-test' = @{
            'SubscriptionName' = ''
            'SubscriptionId'   = ''
            'TenantId'         = ''
        }
        'proj1-stg'  = @{
            'SubscriptionName' = ''
            'SubscriptionId'   = ''
            'TenantId'         = ''
        }
        'proj2-dev'  = @{
            'SubscriptionName' = ''
            'SubscriptionId'   = ''
            'TenantId'         = ''
        }
        'proj2-test' = @{
            'SubscriptionName' = ''
            'SubscriptionId'   = ''
            'TenantId'         = ''
        }
        'proj2-stg'  = @{
            'SubscriptionName' = ''
            'SubscriptionId'   = ''
            'TenantId'         = ''
        }
    }
    
    $SubscriptionName = $SubscriptionTable.$SubCode.SubscriptionName
    $SubscriptionId = $SubscriptionTable.$SubCode.SubscriptionId
    $TenantId = $SubscriptionTable.$SubCode.TenantId
    
    Write-Host "Changing AzContext to:" -ForegroundColor Red
    
    Write-Host "Subscription: " -ForegroundColor Green -NoNewline
    Write-Host "$SubscriptionName" -ForegroundColor Blue
    
    Write-Host "SubscriptionId: " -ForegroundColor Green -NoNewline
    Write-Host "$SubscriptionId" -ForegroundColor Blue
    
    Write-Host "TenantID: " -ForegroundColor Green -NoNewline
    Write-Host "$TenantId" -ForegroundColor Blue
    
    #region connect to correct tenant and subscription
    $CurrentContext = Get-AzContext
    #If there is no AzContext found connect to desired Subscription and Tenant
    if (!$CurrentContext) {
        Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId -UseDeviceAuthentication
        $CurrentContext = Get-AzContext
    }
    #If subscription ID doesnt match, call the set-azcontext with subid and tenantid to allow switch between tenants as well. 
    if ($CurrentContext.Subscription.Id -ne $SubscriptionId) {
        $CurrentContext = Set-AzContext -Subscription $SubscriptionId -Tenant $TenantId
    }
    #endregion

    Get-AzContext
}