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