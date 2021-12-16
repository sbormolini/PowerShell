# create nuget package
# nuget required!
# https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools
function New-NuGetPackage
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([object])]
    param 
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Id,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Name,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]  
        [System.String]$Description, 

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$ReleaseNotes, 

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]  
        [System.String]$Tags, 

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]  
        [System.String]$Version,
     
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$PreRelease,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [System.String]$InstallationPath, 

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [System.String]$SourceFilePath,

        [Parameter(Mandatory=$false)]
        [System.String[]]$FileFilter = @('*'), 

        [Parameter(Mandatory=$false)]
        [System.String[]]$FolderFilter = @( '\' ), 

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [System.String]$NuSpecTemplate, 

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [System.String]$ChocoInstallTemplate,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [System.String]$ChocoUnInstallTemplate,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [System.String]$ChocoBeforeUpgradeTemplate,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [System.String]$StagingDirectory, 

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]  
        [System.String]$OutputDirectory,

        [Parameter(Mandatory=$false)]
        [System.Object[]]$Dependencies,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [switch]$MetaPackage
    )

    <# package structure
    \src
        \sources
            \All source tree
        \tools
            \chocolateyInstall.ps1
            \chocolateyUnInstall.ps1
            \chocolateybeforemodify.ps1
        \packageId.nuspec
    #>

    # verify parameters
    Write-Verbose -Message "Verify source folder and .nuspec file"
    if ( -not $MetaPackage -and -not ( Test-Path -Path $SourceFilePath ) )
    {
        throw "No source files found!"
    }
    if ( $NuSpecTemplate -inotmatch '#PackageId#' -and $NuSpecTemplate -inotmatch '#Version#' )
    {
        throw "Invalid nuspec template given"
    }
    if ( $ChocoInstallTemplate -inotmatch '#PackageId#' -and $ChocoInstallTemplate -inotmatch '#InstallationPath#' )
    {
        throw "Invalid installScript template given"
    }
    if ( $ChocoUnInstallTemplate -inotmatch '#PackageId#' )
    {
        throw "Invalid uninstallScript template given"
    }

    # create nuspec file from template
    if ($PreRelease)
    {
        switch ($PreRelease) 
        {
            develop { $suffix = "-dev" }
            Testing { $suffix = "-test" }
        }
        $Version += $suffix
    }

    # replaces values in nuspec file
    Write-Verbose -Message "Replace package information values in .nuspec file"

    # set new version in temporary spec file                              
    $tempNuspec = $nuspecTemplate.Replace("#Version#", $Version)
    $tempNuspec = $tempNuspec.Replace("#PackageId#", $Id)
    $tempNuspec = $tempNuspec.Replace("#PackageName#", $Name)
    $tempNuspec = $tempNuspec -ireplace '#Copyright#', "Copyright TestBos $(Get-Date -Format yyyy)"
    if ( -not[string]::IsNullOrEmpty($Description) )
    { 
        $tempNuspec = $tempNuspec.Replace("#PackageDescription#", $Description) 
    }
    if ( -not[string]::IsNullOrEmpty($ReleaseNotes) )
    {
        $tempNuspec = $tempNuspec.Replace("#PackageReleaseNotes#", $ReleaseNotes)
    }
    if ( -not[string]::IsNullOrEmpty($Tags) )
    {
        $tempNuspec = $tempNuspec.Replace("#PackageTags#", $Tags)
    }
    $XMLDependencies = ''
    foreach ($dependency in $Dependencies)
    {
        if ( $Null -ne $dependency.Id -and $Null -ne $dependency.Version )
        {
            $XMLDependencies += "`n<dependency id=`"$($dependency.Id)`" version=`"$($dependency.Version)`"/>"
        }
    }
    $tempNuspec = $tempNuspec.Replace("#Dependencies#", $XMLDependencies)
    
    # create temporary folder
    Write-Verbose "Create temporary folder $StagingDirectory\${Id}Source-$((Get-Date -f yyyyMMddHHmmss))"
    $tempSourceFolder = New-Item -Path $StagingDirectory -Name "${Id}Source-$(Get-Date -f yyyyMMddHHmmss)" -ItemType Directory

    # save new nuspec file to temporary source folder structure
    Write-Verbose "Temporary nuspec definition is $tempNuspec"
    $tempNuspec | Out-File -FilePath "$($tempSourceFolder.FullName)\${Id}.nuspec"

    If ( -not $MetaPackage )
    {
        $subFolders = @("sources","tools")
        foreach ($item in $subFolders) 
        {
            New-Item -Path $tempSourceFolder -Name $item -ItemType Directory
        }

        # save choco install/uninstall script to temporary source tools folder structure
        $installScript = $ChocoInstallTemplate.Replace("#PackageId#", $Id)
        $installScript = $installScript.Replace("#InstallationPath#", $InstallationPath)
        $installScript | Out-File -FilePath "$($tempSourceFolder.FullName)\tools\chocolateyInstall.ps1"

        $uninstallScript = $ChocoUnInstallTemplate.Replace("#PackageId#", $Id)
        $uninstallScript | Out-File -FilePath "$($tempSourceFolder.FullName)\tools\chocolateyUnInstall.ps1"

        $BeforeUpgradeScript = $ChocoBeforeUpgradeTemplate
        $BeforeUpgradeScript | Out-File -FilePath "$($tempSourceFolder.FullName)\tools\chocolateybeforemodify.ps1"

        # copy source to temporary source folder structure
        If ( $Null -eq $FolderFilter -or $FolderFilter.Count -eq 0 )
        {
            $FolderFilter = @( '\' )
        }
        ForEach( $subfolder in $FolderFilter )
        {
            If ( $subFolder[0] -ine '\' )
            {
                $subFolder = "\$subFolder"
            }
            Write-Host "Copying ${SourceFilePath}${subfolder} to $($tempSourceFolder.FullName)\sources$subfolder, filtering with $FileFilter"
            Copy-Filtered -Source ${SourceFilePath}${subfolder} -Target "$($tempSourceFolder.FullName)\sources$subfolder" -Include $FileFilter -Exclude "*.nuspec"
        }
    }

    if (-not$OutputDirectory)
    {
        $OutputDirectory = (Get-Location).Path
    }

    # pack package
    # https://docs.microsoft.com/en-us/nuget/reference/cli-reference/cli-ref-pack
    Write-Verbose -Message "Pack package $($Id).$($Version.ToString()).nupkg"
    nuget.exe pack "$($tempSourceFolder.FullName)\${Id}.nuspec" -OutputDirectory $OutputDirectory -Verbosity quiet
}