## Ensure the function is available
. .\Add-One.ps1
. .\Combine-String.ps1

describe 'Add-One' {
    $TestNumber = 1
    $result = Add-One -Number $TestNumber
    it 'should return 2' {
        $result | should be 2
    }
}

describe 'Combine-String' {
    $result = Combine-String -a "Hallo" -b "Welt"
    it 'should return HalloWelt' {
        $result | should be "HalloWelt"
    }
}