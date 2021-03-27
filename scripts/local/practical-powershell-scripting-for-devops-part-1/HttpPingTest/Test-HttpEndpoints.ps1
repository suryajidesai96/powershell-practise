[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline = $true)]
    [string]
    $TestsFilePath =  '.\Tests.json'
)

# Convert JSON Config Files String value to a PowerShell Object
$TestsObj = Get-Content -Path $TestsFilePath | ConvertFrom-Json

# Import the Tester Function
. ./lib/New-HttpTestResult.ps1

# Loop through Test Objects and get the results as a collection
$TestResults = foreach ($Test in $TestsObj) { 
    New-HttpTestResult -TestArgs $Test 
}

$TestResults | Format-Table -AutoSize