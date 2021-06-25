<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
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
function Invoke-ParseSQLQuery
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
        [System.String]$Query,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Boolean","Parser")]
        [System.String]$OperationMode = "Boolean"
    )
    try
    {
        Import-Module -Name @("SqlServer") -Force 

        # new parser option object
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.SqlParser") | Out-Null
        $parseOptions = New-Object Microsoft.SqlServer.Management.SqlParser.Parser.ParseOptions
        $parseOptions.BatchSeparator = "GO"
        
        # remove parser invalid section
        $collection = @(
            "SET ANSI_NULLS ON", 
            "SET QUOTED_IDENTIFIER ON",
            "SORT_IN_TEMPDB = *",
            "ONLINE = *",
            "OPTIMIZE_FOR_SEQUENTIAL_KEY = *"
        )
        foreach ($item in $collection)
        {
            $Query = $Query.Replace($item, '')
        }

        # new parser object
        $parser = [Microsoft.SqlServer.Management.SqlParser.Parser.Parser]::Parse(
            $Query, 
            $parseOptions
        )
        
        switch ($OperationMode) 
        {
            "Boolean" { 
                if ($parser.Errors)
                {
                    return $false
                }
                else 
                {
                    return $true
                }
            }
            "Parser" {
                return $parser.Errors
            }
        }
    }
    catch
    {
        throw "Unhandled error occured: $($_.Exception.GetType().FullName)`n$($_.Exception.Message)"
    }
}