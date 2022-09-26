# https://docs.microsoft.com/en-us/graph/authenticationmethods-get-started
# add Microsoft Graph PowerShell as business application to azure ad

# tenant
$TenantId = "<tenant-id>"

Connect-AzAccount -Tenant $TenantId
$token = (Get-AzAccessToken -ResourceTypeName "MSGraph" -TenantId $TenantId).token 
Connect-MgGraph -AccessToken $token 

#region : mfa
$parameters = @{
    Scopes = @("UserAuthenticationMethod.ReadWrite.All','User.ReadWrite.All")
    TenantId = $TenantId
    Environment = "Global"
    ContextScope = "Process"
}
Connect-MgGraph @parameters

$me = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/me"
#$authMethods = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/users/$($me.Id)/authentication/methods"
# result 403 Forbidden
Get-MgUserAuthenticationMethod -UserId $me.id  

#$user = Get-MgUser -UserId "<user-id>"
#$methods = Get-MgUserAuthenticationMethod -UserId $user.id

<#
# IMicrosoftGraphAutenthicaton1
[Microsoft.Graph.PowerShell.Models.MicrosoftGraphAuthenticationMethod]$phone = @{
    Id = [guid]::NewGuid().ToString()
    AdditionalProperties = @{

    }
}
Update-MgUser -UserId $userp.Id -Authentication $phone

$url = "https://graph.microsoft.com/beta/users/$($user.UserPrincipalName)/authentication/methods"
Invoke-MgGraphRequest -Method GET -Uri $url
#>

$param = @{
    PhoneNumber = "123456789"
    PhoneType = "mobile"
}
New-MgUserAuthenticationPhoneMethod -UserId $userp.UserPrincipalName -BodyParameter $param

#endregion

# tenant
$TenantId = "<tenant-id>"
$appid = "<app-id>"
$secret = "<secret>"

#Connect-MgGraph -ClientID YOUR_APP_ID -TenantId YOUR_TENANT_ID -CertificateName YOUR_CERT_SUBJECT ## Or -CertificateThumbprint instead of -CertificateName

# get token 
$body =  @{
    Grant_Type = "client_credentials"
    Scope = "https://graph.microsoft.com/.default"
    Client_Id = $appid
    Client_Secret = $secret
}

$parameters = @{
    Uri = "https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token"
    Method = "POST"
    Body = $body
}
$response = Invoke-RestMethod @parameters
$token = $response.access_token

# connect as graph handler app to MS Graph
Connect-MgGraph -AccessToken $token

# check auth method of user
Get-MgUserAuthenticationMethod -UserId "<user-id>"