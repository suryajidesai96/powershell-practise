function New-FeatureBranchName {
    [CmdletBinding()]
    param (
        # Work Item ID
        [Parameter(Mandatory)][Alias('i','id')][string]$workItemId,
        # Work Item Title
        [Parameter(Mandatory)][Alias('t','title')][string]$workItemTitle,
        # Initials
        [Parameter()][Alias('in','name', 'inits')][string]$initials
    )

        $featureprefix = "feature/"

        if($initials) {$featureprefix = $featureprefix + $initials + '/'}

        $TitleFormatted = $workItemTitle -replace " ", "_"

        $branchname = $featureprefix + $workItemId + '_' + $TitleFormatted

        return $branchname
}