$modules = @(
    "Microsoft.PowerShell.SecretManagement",
    "Microsoft.PowerShell.SecretStore",
    "SecretManagement.Chromium",
    "SecretManagement.KeePass"
)

Install-Module -Name $modules

#region : Keepass
# Set path to KeePass file and test it exists
$KeePassDBFilePath = ".\keepass\database.kdbx"

# set up the value for the VaultParameters parameter
$parameters = @{ 
    Path = $KeePassDBFilePath 
    UseMasterPassword = $true
    MasterPassword = "pwd"
}

# Set a vault name and if it exists then unregister that vault in this session
$vaultName = 'keepass-vault-01'
if (Get-SecretVault -Name $vaultName -ErrorAction SilentlyContinue)
{
    Unregister-SecretVault $vaultName
}

# register our chosen vault
Register-SecretVault -Name $vaultName -ModuleName SecretManagement.keepass -VaultParameters $parameters

Test-SecretVault -Name $vaultName

# get secret from keepass vault
$secret = Get-Secret -Vault $vaultName -Name "Sample Entry"
$secret.GetNetworkCredential().Password

# set new secret
Set-Secret -Name 'Anton' -Vault $vaultName -Secret '@_thisIsAT3st!' 

# return secret meta info
Get-SecretInfo -Vault $vaultName
#endregion

#region : Azure Key Vault
# azure key vault
Install-Module Az.KeyVault
Register-SecretVault -Module Az.KeyVault -Name AzKV -VaultParameters @{ AZKVaultName = $vaultName; SubscriptionId = $subID}
#endregion

#region : Local Secret Store
# scenario automation
Install-Module -Name Microsoft.PowerShell.SecretStore -Repository PSGallery -Force
$password = Import-CliXml -Path $securePasswordPath

Set-SecretStoreConfiguration -Scope CurrentUser -Authentication Password -PasswordTimeout 3600 -Interaction None -Password $password -Confirm:$false

Install-Module -Name Microsoft.PowerShell.SecretManagement -Repository PSGallery -Force
Register-SecretVault -Name SecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault

Unlock-SecretStore -Password $password
#endregion
