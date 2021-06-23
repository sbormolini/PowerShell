<#
    About Classes
    Source: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes?view=powershell-6 
#>
function test-write
{
    param($string)
    Write-Host $string
}

# define class
class Device 
{
    hidden [Guid]$Id

    [String]$Name
    [String]$Model
    [String]$SerialNumber
    
    [bool]$Active

    static [Int]$Value = 4

    [string] SampleMethod() 
    {
       return "This is $($this.Name) ($($this.Model))"
    }

    [string] Test(

       [string]
       $value
    ) 
    {
       return $value
    }
}

# inherited class
class Firewall : Device
{
    [String]$Version
    [System.Collections.IDictionary]$Rules

    AddRule()
    {}

    RemoveRule()
    {}
}

# interface
#interface Hallo {} - cant create interface but you can inherited from
class MyComparable : System.IComparable
{
    [int] CompareTo([object] $obj)
    {
        return 0;
    }
}

class MyComparableDevice : Device, System.IComparable
{
    [int] CompareTo([object] $obj)
    {
        return 0;
    }
}


# create instance
$d = New-Object Device -Property @{ 
    Id = (New-Guid).Guid              
    Name="Test"
    Model = "Cisco Thing 1213"
}

# call method
$d.SampleMethod()

# create inhertied instance
$f = New-Object Firewall -Property @{
    Version = "1.0"
}

$f.Version
