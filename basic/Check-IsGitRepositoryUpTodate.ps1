# simple dirty test
function Check-IsGitRepositoryUpTodate
(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateNotNullOrEmpty()]
        [System.String]$LocalRepositoryFilePath
)
{
    if ( -not(Test-Path -Path $LocalRepositoryFilePath) )
    {
        throw "The path ${LocalRepositoryFilePath} is not available!"
    }
    else 
    {
        Set-Location -Path $LocalRepositoryFilePath    
    }

    # fetch repo
    git.exe fetch | Out-Null
    $result = git.exe status
    if ($result -match "branch is behind")
    {
        return $false
    }
    else 
    {
        return $true
    }
}

# or git fetch > git status regex "Your branch is behind 'origin/master'" (git pull needed)