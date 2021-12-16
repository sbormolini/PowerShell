# load api client
using module "C:\Users\fastewaie\Documents\Dev\PowerShell\GoRestTest\GoRestTest.psm1"
#using module GoRestTest

Describe "Test Client with Mocking" {
    BeforeAll {
       class Mock : GoRestClient {
           Mock () { }
           [string] GetUser() { return "blubb" }
        }
    }

    It "Value should be 'blubb'" {
        $mock = New-Object Mock
        $expected = $mock.GetUser()
        $expected | Should -BeExactly "blubb"
    }
}

Describe "Test Function" {
    It "Value should be 'Test'" {
        $expected = Write-Test
        # version 1
        #Should -ActualValue $expected -ExpectedValue "Test" -BeExactly
        # version 2
        $expected | Should -BeExactly "Test"
    }
}


<#
$client = New-Object -TypeName GoRestClient("eAgqVXKkawoQFWQ1gy5Tj5zCIe0Z0cWL8aOi")
Mock $client.GetUser(1642) {
    $object = [PSCustomObject]@{
        id = "1642"
        first_name = "Jamil"
        last_name = "Feest"
        gender = "male"
        dob = "1997-03-12"
        email = "celine34@example.net"
        phone = "(641) 644-7689 x00166"
        website = "https://waelchi.org/voluptatem-est-qui-laudantium-magnam.html"
        address = "8658 Mollie Drives`nLake Dayana, ID 16404-7906"
        status = "inactive"
        _links = @{
            self = @{href="https://gorest.co.in/public-api/users/1642"}
            edit = @{href="https://gorest.co.in/public-api/users/1642"}
            avatar = @{href="https://lorempixel.com/250/250/people/?83372"}
        }
    }
    return $object #>