#Requires -Version 5


# Load configuration file
$configuration = Get-Content -Raw -Path "$PSScriptRoot\configuration.json" | ConvertFrom-json

try{
    Import-Module  $configuration.SCCMConfig.SCCMModulePath
}
catch{
    Write-output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - Failed to import SCCM module. "
}

$currentLocation = Get-Location
$location = $configuration.SCCMConfig.SiteName
if (!($location.endswith(":"))){
    $location = $location + ":"
}

Set-location $location

# Load functions
Get-ChildItem -File -Path "$PSScriptRoot\Functions" | Foreach {
    $scriptPath = "$PSScriptRoot\Functions\" + $_.Name
    . $scriptPath
}

# Load collections files
Get-ChildItem -File -Path "$PSScriptRoot\Collections" | Foreach {
    $collectionName = $_.Name -replace ".ps1", ""
    $scriptPath = "$PSScriptRoot\Collections\" + $_.Name
    invoke-expression ". '$scriptPath'"
    $functionName =  ($_).Basename -replace " ",""
    try{
        $vmList = invoke-expression  "$functionName"
    }
    catch{
        Write-output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - Failed to get VM list for $functionName."
        continue
    }

    # Check if collection exist
    if (!(Test-SCCMCollection -SCCMSiteCode $configuration.SCCMConfig.SiteName -collectionName $collectionName)){
        Write-output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - Collection $collectionName doesn't exist."
    }
    else{
        try{
            Add-DevicesToCollection -SCCMSiteCode $configuration.SCCMConfig.SiteName -collectionName $collectionName -vmList $vmList
        }
        catch{
            Write-output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - Error while adding VMs to $collectionName."
            continue
        }
    }
}

Set-location $currentLocation