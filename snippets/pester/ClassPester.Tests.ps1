## Ensure the class is available
. .\Class-Device.ps1

describe 'Method SetDeviceName' {
    $device = [Device]::new('TestDevice')
    $result = $device.Name
    it 'should return TestDevice' {
        $result | should be "TestDevice"
    }
    $device.SetDeviceName('NewDeviceName')
    $result = $device.Name
    it 'should return NewDeviceName' {
        $result | should be "NewDeviceName"
    }
}

describe 'Method SetDeviceName' {
    $device = [Device]::new('TestDevice')
    $result = $device.Name
    it 'should return TestDevice' {
        $result | should be "TestDevice"
    }
    $device.SetDeviceName('NewDeviceName')
    $result = $device.Name
    it 'should return NewDeviceName' {
        $result | should be "NewDeviceName"
    }
}