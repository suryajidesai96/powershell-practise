$refsInputArray = @("refs/heads/releases/1.0.0",
                    "refs/heads/releases/1.a.0",
                    "refs/heads/releases/1.2.0.5.6.9",
                    "refs/heads/release/1.1.1",
                    "refs/heads/releases/1.0.1",
                    "refs/heads/releases/2.4.3",
                    "refs/heads/main",
                    "refs/heads/develop")

#https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
$semVerRegex = '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'

$refsInputArray | ForEach-Object {
    $refParts = ($PSItem -split '/')

    if ($refParts[-2] -eq 'releases') {
        if ("$($refParts[-1])" -match $semVerRegex) {
            Write-Host "Reference $($PSItem) is in releases folder and has a correct semver format"
        }
        else {
            Write-Error "Reference $($PSItem) is in releases folder but has an incorrect semver format"
        }
    }
    else {
        Write-Error "Reference $($PSItem) is not in releases folder"
    }
}