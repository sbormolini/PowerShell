#delegate example
function Invoke-FunctionWithDelegate
{
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
            [System.String]$UserInputString,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
            [System.Management.Automation.ScriptBlock]$Delegate
    )

    $string = "$($UserInputString)_Test"
    # call delegate
    $Delegate.Invoke($string)               
}

Invoke-FunctionWithDelegate -UserInputString "Dies_ist_ein" -Delegate { param($s) Write-Host -Object $s }

# new test
function test ()
{
    # kekew
    Write-Output -InputObject "TEST"
}

# another test 
function kekw()
{
    # not implemented
    Write-host "Manchmnal aber nur manchmal haben scripe wie du ein wenig haue gern"
}
