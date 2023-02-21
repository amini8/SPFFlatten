function Extract-Mechanisms {
    param(
        [Parameter(Mandatory=$true)]
        [string]$spfRecord
    )

    $mechanismRegex = '([+~-])?([a-z]+)(:.+)?'
    $mechanisms = @()

    # Loop through each mechanism in the SPF record
    while ($spfRecord -match $mechanismRegex) {
        $mechanism = $matches[0]
        $mechanisms += $mechanism
        $spfRecord = $spfRecord.Replace($mechanism, '')
    }

    return $mechanisms
}

function Flatten-SPFRecord {
    param(
        [Parameter(Mandatory=$true)]
        [string]$spfRecord
    )

    $mechanisms = @(Extract-Mechanisms $spfRecord)
    $flattenedRecord = ''
    $currentMechanism = ''
    $previousMechanism = ''

    # Loop through each mechanism in the SPF record
    foreach ($mechanism in $mechanisms) {
        $currentMechanism = $mechanism

        # Skip the "v=spf1" tag
        if ($currentMechanism -eq 'v=spf1') {
            continue
        }

        # Add the "all" mechanism if this is the last mechanism
        if ($mechanism -eq $mechanisms[-1]) {
            $currentMechanism = 'all'
        }

        # Remove redundant mechanisms
        if ($currentMechanism -eq $previousMechanism) {
            continue
        }

        $flattenedRecord += " $currentMechanism"
        $previousMechanism = $currentMechanism
    }

    # Add the "v=spf1" tag at the beginning
    $flattenedRecord = "v=spf1$flattenedRecord"

    return $flattenedRecord
}

# Prompt user for SPF record
$spfRecord = Read-Host -Prompt 'Enter the SPF record to flatten'

# Flatten the SPF record
$flattenedRecord = Flatten-SPFRecord $spfRecord

Write-Host 'Flattened SPF record:'
Write-Host $flattenedRecord
