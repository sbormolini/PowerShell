# upload to artifactory
# nuget required!
# https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools
function Publish-NuGetPackage
{
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath, 

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$APIKey,

        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$URL
    )
    try 
    {
        nuget.exe push $FilePath -ApiKey $APIKey -Source $URL
    }
    catch 
    {
        throw "Unhandled error occured.`n$($Error)"
    }
}