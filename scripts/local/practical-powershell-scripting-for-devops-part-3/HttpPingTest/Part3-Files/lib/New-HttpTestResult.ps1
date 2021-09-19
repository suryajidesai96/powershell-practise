function New-HttpTestResult {
    param (
        [Parameter(ValueFromPipeline = $true)]
        [PSCustomObject]
        $TestArgs,
        # Maximum Retry Amount
        [Parameter()][int]$MaxRetryNo = 10,
        # Time to wait in between retry attempts
        [Parameter()][int]$WaitTimeInSeconds = 1
    )
    $ProgressPreference = 'SilentlyContinue'

    $Method = 'Get'

    $TestCounter = 0 

    # -lt: Lower Than 
    while ($TestCounter -lt $MaxRetryNo) {
        
        #Increment our counter by 1 before we make our first attempt
        $TestCounter++
        $duration = Measure-Command {
            $Response = Invoke-WebRequest -Uri $TestArgs.url -Method $Method -SkipHttpErrorCheck
        }

        # If we find the 200 code we stop polling
        if($Response.StatusCode.ToString() -eq '200'){
            break;
        }
        else {
            #Else we need to wait for configured amount of time
            Start-Sleep -Seconds $WaitTimeInSeconds
        }
    }

    $result = [PSCustomObject]@{
        name               = $TestArgs.name
        status_code        = $Response.StatusCode.ToString()
        status_description = $Response.StatusDescription
        attempt_no         = "$($TestCounter)/$($MaxRetryNo)"
        responsetime_ms    = $duration.Milliseconds
        timestamp          = (get-date).ToString('O')
    }

    return $result 
}