# Implement your module commands in this script.

# api client
class GoRestClient
{
    $BaseUrl = "https://gorest.co.in"
    [string] hidden $accessToken

    GoRestClient ()
    {}

    GoRestClient (
        [string]$AccessToken
    )
    {
        $this.accessToken = $AccessToken
    }

    [System.Object] GetRequest(
        [string]$Uri
    )
    {
        $value = $null
        $headers = @{
            "Authorization" = "Bearer $($this.accessToken)"
            "Content-Type" = "application/json"
        }

        $result = Invoke-WebRequest -Uri $Uri `
                                    -Headers $headers `
                                    -UseBasicParsing

        switch ($result.StatusCode)
        {
            200
            {
                $value = (ConvertFrom-Json -InputObject $result.Content).result
            }
            Default
            {
                throw "Unhandled error occured"
            }
        }

        return $value
    }

    # get all users
    [System.Object] GetUsers()
    {
        return $this.GetRequest("$($this.BaseUrl)/public-api/users")
    }

    # get user by id
    [System.Object] GetUser(
        [int]$Id
    )
    {
        return $this.GetRequest("$($this.BaseUrl)/public-api/users/$($Id)")
    }
}

# Get class and function definition files.
$function = Get-ChildItem -Path "${PSScriptRoot}\function\*.ps1" -ErrorAction SilentlyContinue

# Dot source the files
foreach ($import in $function)
{
    try
    {
        . $import.FullName
    }
    catch
    {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*