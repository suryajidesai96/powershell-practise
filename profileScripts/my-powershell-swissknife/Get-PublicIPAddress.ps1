function Get-PublicIPAddress {
    [CmdletBinding()]

    $OriginalPref = $ProgressPreference # Default is 'Continue'

    $ProgressPreference = "SilentlyContinue"

    (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content

    $ProgressPreference = $OriginalPref
}