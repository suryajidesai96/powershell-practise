function New-HttpTestResult {
    param (
        [Parameter(ValueFromPipeline=$true)]
        [PSCustomObject]
        $TestArgs
    )
    $ProgressPreference = 'SilentlyContinue'

    $Method = 'Get'

    $duration = Measure-Command {
        $Response = Invoke-WebRequest -Uri $TestArgs.url -Method $Method -SkipHttpErrorCheck
    }

    $result = [PSCustomObject]@{
        name = $TestArgs.name
        status_code = $Response.StatusCode.ToString()
        status_description = $Response.StatusDescription
        responsetime_ms = $duration.Milliseconds
        timestamp = (get-date).ToString('O')
    }

    return $result
}