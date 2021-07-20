$path = Join-Path -Path $env:TEMP -ChildPath "splat-test"
$value = "File created at: $(Get-Date -Format "FileDateTime")"

# version 1
New-Item -Name "testv1-$([guid]::NewGuid().ToString()).txt" -Path $path -ItemType File -Value $value

# version 2
New-Item -Name "testv2-$([guid]::NewGuid().ToString()).txt" `
         -Path $path `
         -ItemType File `
         -Value $value

# version 3
$parameters = @{
    Name =  "testv3-$([guid]::NewGuid().ToString()).txt"
    Path = $path
    ItemType = "File"
    Value = $value
}
New-Item @parameters

# version 4 - doesnt work
New-Item @{
    Name =  "testv4-$([guid]::NewGuid().ToString()).txt"
    Path = $path
    ItemType = "File"
    Value = $value
}