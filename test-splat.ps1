$path = Join-Path -Path $env:TEMP -ChildPath "splat-test"
$value = "File created at: $(Get-Date -Format "FileDateTime")"

# version 1
New-Item -Name "testv1-$([guid]::NewGuid().ToString()).txt" -Path $path -ItemType File -Value $value

# version 2
$parameters = @{
    Name =  "testv2-$([guid]::NewGuid().ToString()).txt"
    Path = $path
    ItemType = "File"
    Value = $value
}
New-Item @parameters

# version 3 - doesnt work
New-Item @{
    Name =  "testv3-$([guid]::NewGuid().ToString()).txt"
    Path = $path
    ItemType = "File"
    Value = $value
}