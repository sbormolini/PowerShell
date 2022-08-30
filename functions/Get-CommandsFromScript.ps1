
<#
.Synopsis
   Discover Commands and Modules from Script
.DESCRIPTION
   Discover Commands and Modules from Script using Script Analyzer
.EXAMPLE
   Get-CommandsFromScript
.INPUTS
   None
.OUTPUTS
   TypeName: PsCustomObject
#>
function Get-CmdletsFromScript
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string] $FilePath = "C:\Users\Sandro\Workspace\PowerShell\functions\Find-DomainControllerInSubnet.ps1"
    )

    # sources
    # https://docs.microsoft.com/en-us/powershell/module/psscriptanalyzer/?view=ps-modules
    # https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.2
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes?view=powershell-7.2

    # pre load all modules?
    Get-Module -ListAvailable | Import-Module

    class CommandSearchResult
    {
        [string] $Name
        [string] $Module
        [int] $Line

        CommandSearchResult ([string]$n, [string]$m, [int]$l)
        {
            $this.Name = $n
            $this.Module = $m
            $this.Line = $l
        }
    }

    $approvedVerbs = @(
        "Add",
        "Clear",
        "Close",
        "Copy",
        "Enter",
        "Exit",
        "Find",
        "Format",
        "Get",
        "Hide",
        "Join",
        "Lock",
        "Move",
        "New",
        "Open",
        "Optimize",
        "Pop",
        "Push",
        "Redo",
        "Remove",
        "Rename",
        "Reset",
        "Resize",
        "Search",
        "Select",
        "Set",
        "Show",
        "Skip",
        "Split",
        "Step",
        "Switch",
        "Undo",
        "Unlock",
        "Watch",
        "Test",
        "Write"
    )

    $pattern = "^($($approvedVerbs -join '|'))-[A-Z].*$"
    $commands = @()

    $content = Get-Content -Path $FilePath
    $lineCounter = 0
    foreach ($line in $content) 
    {
        foreach ($word in $line.Split(' '))
        {
            if ($word -match $pattern)
            {
                $command = Get-Command -Name $word -ErrorAction SilentlyContinue
                $commands += [CommandSearchResult]::new(
                    $command.Name ? $command.Name : $word,
                    $command.Source ? $command.Source : "Module not loaded?",
                    $lineCounter
                )
            }
        }
        $lineCounter++
    }

    return $commands
}
