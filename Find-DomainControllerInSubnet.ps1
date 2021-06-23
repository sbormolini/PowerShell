
<#
.Synopsis
   Discover Domain Controller in connected subnet
.DESCRIPTION
   Discover Domain Controller in connected subnet
.EXAMPLE
   Find-DomainControllerInSubnet
.INPUTS
   None
.OUTPUTS
   TypeName: Microsoft.ActiveDirectory.Management.ADDomainController
#>
function Find-DomainControllerInSubnet
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([System.Object])]
    param
    ( )

    Import-Module -Name ActiveDirectory

    $localIPAddress = Get-NetIPAddress -ErrorAction Stop | 
        Where-Object { ($_.InterfaceAlias -like "Ethernet*") -and ($_.AddressFamily -eq "IPv4") }
    
    $gateway = (Get-NetRoute | Where-Object { $_.DestinationPrefix -eq "0.0.0.0/0" }).NextHop

    $hosts = [System.Math]::Pow(32-$localIPAddress.PrefixLength,2)

    $domainController = $null
    for ($i=1; $i -lt $hosts; $i++) 
    {
        [string]$ipAddress = "$($gateway.Split('.')[0]).$($gateway.Split('.')[1]).$($gateway.Split('.')[2]).$($gateway.Split('.')[3]-1+$i)"
        
        if ( ($ipAddress -ne $gateway) -and ($ipAddress -ne $localIP) )
        {
            if (Test-Connection -Quiet -Count 1 -ComputerName $ipAddress)
            {
                try 
                {
                    $domainController = Get-ADDomainController -Server $ipAddress
                }
                catch
                {
                    Write-Verbose -Message "No DomainController found at address $($ipAddress)"
                }
                if ($null = $domainController)
                {
                    Write-Verbose -Message "DomainController found at address $($ipAddress)"
                    return  $domainController
                }
            }
        }
    }
}
