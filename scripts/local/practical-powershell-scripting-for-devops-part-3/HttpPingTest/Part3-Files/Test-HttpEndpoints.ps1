[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline = $true)]
    [string]
    $TestsFilePath =  '.\Tests.json'
)

#Lets Create a StopWatch Object.
$Stopwatch = [System.Diagnostics.Stopwatch]::new()

# Now Start the timer.
$Stopwatch.Start()

# Convert JSON Config Files String value to a PowerShell Object
$TestsObj = Get-Content -Path $TestsFilePath | ConvertFrom-Json

# Import the Tester Function
. ./lib/New-HttpTestResult.ps1

$funcDef = ${function:New-HttpTestResult}.ToString()

$jobs = $TestsObj | ForEach-Object -Parallel {

    ${function:New-HttpTestResult} = $using:funcDef

    New-HttpTestResult -TestArgs $_
} -AsJob -ThrottleLimit 50

$jobs | Receive-Job -Wait | Format-Table

# Now Stop the timer.
$Stopwatch.Stop()

$TestDuration  =  $Stopwatch.Elapsed.TotalSeconds

Write-Host "Total Script Execution Time: $($TestDuration) Seconds"