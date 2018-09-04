<#
.SYNOPSIS
  Flush SCCM collection
.DESCRIPTION
  Remove all devices in a given collection
.PARAMETER SCCMSiteCode
  The SCCM site code
.PARAMETER collectionName
  The name of the collection to flush
.INPUTS
  None
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
.NOTES
  Version:        1.0
  Author:         Marco Torello
  Creation Date:  31/8/2018
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

Function Flush-SCCMCollection{
  Param(
      [parameter(Mandatory=$true)]
        [String] $SCCMSiteCode,
      [parameter(Mandatory=$true)]
        [String] $collectionName
    )
  
  Begin{
    Write-Output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - Start executing Flush-SCCMCollection on $collectionName"
  }
  
  Process{
    Try{
        Set-Location $SCCMSiteCode

        $collection.CollectionRules | %{
            if($_ -and $_.RuleName -ne ''){
                $name=$(get-cmdevice -name $_.RuleName | Select-Object ResourceID).ResourceID;
                if ($name){
                    write-output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - Removing $name from collection $collectionName"  
                    Remove-CMDeviceCollectionDirectMembershipRule -CollectionId $collectionID -resourceId $name -force
                }
            }
        }

    }
    
    Catch{
      Write-output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - $_.Exception"
      Break
    }
  }
  
  End{
    If($?){
      Write-output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - Completed Successfully."
    }
  }
}