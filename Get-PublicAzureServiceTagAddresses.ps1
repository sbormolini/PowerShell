<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Get-PublicAzureServiceTagAddresses  -ServiceName "DataFactory" -Region SwitzerlandNorth
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Get-PublicAzureServiceTagAddresses
{
    [CmdletBinding(PositionalBinding=$false, ConfirmImpact="Low")]
    [Alias()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$ServiceName,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet(
            "AustraliaCentral"
            ,"AustraliaCentral2"
            ,"AustraliaEast"
            ,"AustraliaSoutheast"
            ,"BrazilSouth"
            ,"BrazilSoutheast"
            ,"CanadaCentral"
            ,"CanadaEast"
            ,"CentralIndia"
            ,"CentralUS"
            ,"CentralUSEUAP"
            ,"EastAsia"
            ,"EastUS"
            ,"EastUS2"
            ,"EastUS2EUAP"
            ,"EastUSSLV"
            ,"EastUSSTG"
            ,"FranceCentral"
            ,"FranceSouth"
            ,"GermanyNorth"
            ,"GermanyWestCentral"
            ,"JapanEast"
            ,"JapanWest"
            ,"SouthIndia"
            ,"SoutheastAsia"
            ,"SwedenCentral"
            ,"SwedenSouth"
            ,"SwitzerlandNorth"
            ,"SwitzerlandWest"
            ,"UAECentral"
            ,"UAENorth"
            ,"UKNorth"
            ,"UKSouth"
            ,"UKSouth2"
            ,"UKWest"
            ,"WestCentralUS"
            ,"WestEurope"
            ,"WestIndia"
            ,"WestUS"
            ,"WestUS2"
            ,"WestUS3"
        )]
        [System.String]$Region,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [System.String]$Path,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [switch]$IPv6
    )
    try
    {
        # Offical url 
        $url = "https://download.microsoft.com/download/7/1/D/71D86715-5596-4529-9B13-DA13A5DE5B63/ServiceTags_Public_20211101.json"

        if ( -not(Test-Path -Path $Path) )
        {
            Write-Warning -Message "Can not find valid ServiceTag json file!"
            $answer = Read-Host -Prompt "Do you want do download it from ${url}? y/n"
            switch ($answer) 
            {
                "y"
                {  
                    $Path = New-TemporaryFile
                    Invoke-WebRequest -Uri $url -OutFile $Path
                }
                "n"
                { 
                    Write-Output -InputObject "Can not procced! Quit function"
                    exit 
                }
                default 
                {
                    exit
                }
            }    
        }

        $serviceTags = Get-Content -Path $Path | ConvertFrom-Json

        if ($null -ne $Region)
        {
            $name = "$ServiceName.$Region"
        }
        else 
        {
            $name = $ServiceName
        }

        $serviceRanges = $serviceTags.values.Where({$_.Name -like $name}).properties.addressPrefixes
        #$ranges = $service.properties.addressPrefixes

        if ($IPv6 -eq $false)
        {
            $value = @() 
            foreach($item in $serviceRanges)
            {
                if ($item.Split('/')[0] -match "\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}\b")
                {
                    $value += $item
                }
            }
        }
        else 
        {
            $value = $ranges    
        }

        return $value
    }
    catch
    {
        throw "Unhandled error"
    }
}