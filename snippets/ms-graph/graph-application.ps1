# https://docs.microsoft.com/en-us/graph/authenticationmethods-get-started
# add Microsoft Graph PowerShell as business application to azure ad

# dev tenant
$TenantId = "<tenant-id>"

Connect-AzAccount -Tenant $TenantId
$token = (Get-AzAccessToken -ResourceTypeName "MSGraph" -TenantId $TenantId).token 
Connect-MgGraph -AccessToken $token 


<# app : permission / role / api access#>

# new application
[Microsoft.Graph.PowerShell.Models.MicrosoftGraphWebApplication]$web = @{
    HomePageUrl = "http://test.local"
    LogoutUrl = $null
    RedirectUris = $null
    ImplicitGrantSettings = @{
        EnableAccessTokenIssuance = $true # Oauth2AllowImplicitFlow
        EnableIdTokenIssuance = $false
    }
}

# Microsoft.Graph.PowerShell.Models.MicrosoftGraphApplication1
$app = New-MgApplication -DisplayName "New awesome app" -Web $web #-IdentifierUris "https://test.core.local"
$app | Format-List


# add api permission 
# app: New awesome app
$parameters = @{
    Scopes = @("Application.ReadWrite.All","AppRoleAssignment.ReadWrite.All")
    TenantId = $TenantId
    Environment = "Global"
    ContextScope = "Process"
}
Connect-MgGraph @parameters

$app = Get-MgApplication -ApplicationId "<app-id>"
#$svc = Get-MgServicePrincipal -ServicePrincipalId "<svc-id>"

$adapp = Get-AzADApplication -DisplayName "New awesome app"
$adapp.RequiredResourceAccess

# Microsoft Graph
$svcGraph = Get-MgServicePrincipal -ServicePrincipalId "<svc-id>"
$svcGraph = Get-AzADServicePrincipal -DisplayName "Microsoft Graph"
$svcGraph.AppRoles

$svcGraph.Oauth2PermissionScopes
$svcGraph.AppId # = resourceAppId

# add permission
$newPermission = @{
    ResourceAppId = "<app-id>"
    ResourceAccess = @(
        @{
            id = "<id>"
            type = "Scope"
        }
    )
}

# get existing permission
$existingResources = $adapp.RequiredResourceAccess

Update-MgApplication -ApplicationId $adapp.Id -RequiredResourceAccess ($existingResources + $newPermission) #works

Update-AzADApplication -ApplicationId $adapp.Id -RequiredResourceAccess ($existingResources + $newPermission)