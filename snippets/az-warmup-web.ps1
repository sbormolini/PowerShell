param
(
    [Parameter(Mandatory=$true)]
    [string] $ApplicationName
)

# Warmup Azure service
$warmupUrl = "https://$ApplicationName.azurewebsites.net/"
Write-Output "Making request to $warmupUrl"
$stopwatch = [Diagnostics.Stopwatch]::StartNew()

try 
{
    # Allow redirections on the warm up
    $response = Invoke-WebRequest -UseBasicParsing $warmupUrl -MaximumRedirection 10 -TimeoutSec 240
    $stopwatch.Stop()
    Write-Output "$($response.StatusCode) Warmed Up Site $TestUrl in $($stopwatch.ElapsedMilliseconds)s ms"
} 
catch 
{
    #$_.Exception| Format-List
} 
finally
{
    $stopwatch.Stop()
    Write-Output "Warmed Up Site $warmupUrl in $($stopwatch.ElapsedMilliseconds)s ms"
}