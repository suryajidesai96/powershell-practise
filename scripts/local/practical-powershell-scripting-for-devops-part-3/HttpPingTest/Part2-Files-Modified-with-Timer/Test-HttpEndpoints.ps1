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

# Loop through Test Objects and get the results as a collection
$TestResults = foreach ($Test in $TestsObj) { 
    New-HttpTestResult -TestArgs $Test 
}

$TestResults | Format-Table -AutoSize

# Now Stop the timer.
$Stopwatch.Stop()

$TestDuration  =  $Stopwatch.Elapsed.TotalSeconds

Write-Host "Total Script Execution Time: $($TestDuration) Seconds"