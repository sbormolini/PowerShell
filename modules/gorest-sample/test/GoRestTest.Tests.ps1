$ModuleManifestName = 'GoRestTest.psd1'
$ModuleManifestPath = (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath $ModuleManifestName)

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        $manifest = Test-ModuleManifest -Path $ModuleManifestPath
        $manifest | Should -Not -BeNullOrEmpty
        $manifest.Name | Should -Be "GoRestTest"
        $manifest.ModuleType | Should -Be "Script"
    }
}