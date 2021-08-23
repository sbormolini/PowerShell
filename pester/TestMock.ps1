function Get-RandomNumber
{
    return Get-Random -Maximum 10 -Minimum 1
}

function Get-RandomNumberPlus1
{
    return (Get-RandomNumber) + 1
}

Describe "How to mock a function" {
    Mock Get-RandomNumber { } # doesnt return anything
    it "should return 1" {
        Get-RandomNumberPlus1 | Should -be 1
    }
}



function Test-LocalFile
{
    param (
        [string]
        $filepath
    )
    try 
    {
        $FileInfo = Get-Item -Path $filepath -ErrorAction SilentlyContinue
        if ( $FileInfo.GetType().Name -eq "FileInfo") 
        {
            return $true
        }
    } 
    catch 
    {
        Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
    }
}

Describe "How to mock a function" {
    Mock Get-Item  {
        New-MockObject -Type "System.IO.Directory"
    }

    it "return txt" {
        Test-LocalFile -filepath hans.vla | Should -BeTrue
    }
}
