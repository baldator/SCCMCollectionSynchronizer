<#
.SYNOPSIS
  Add a list of device to a collection
.DESCRIPTION
  Add the list of devices in vmList to the collection defined in collectionName parameter. 
  A full synchronisation can be triggered by setting the fullSync parameter to true. A full synchronisation will first flush the collection and the add all vms to it.
.PARAMETER SCCMSiteCode
  The SCCM site code
.PARAMETER collectionName
  The name of the collection to add devices to
.PARAMETER vmList
  An array containing the list of VMs to add
.PARAMETER fullSync
  A boolean parameter. Default value is false. If set to true a full sync is triggered. 
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

Function Add-DevicesToCollection{
  Param(
      [parameter(Mandatory=$true)]
        [String] $SCCMSiteCode,
      [parameter(Mandatory=$true)]
        [String] $collectionName,
      [parameter(Mandatory=$true)]
        [String[]] $vmList,
      [parameter(Mandatory=$false)]
        [switch] $fullSync = $false
    )
  
  Begin{
    Write-Output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - Start executing Add-DevicesToCollection on $collectionName"
  }
  
  Process{
    Try{
        Set-Location $SCCMSiteCode

        if($fullSync){
            Flush-SCCMCollection -SCCMSiteCode $SCCMSiteCode -collectionName $collectionName
        }

        $collection = Get-CMCollection -Name $collectionName
        $members = (Get-CMCollectionMember -CollectionId $collection.CollectionID).Name.tolower()
		$rules = (Get-CMDeviceCollectionDirectMembershipRule -CollectionId $collection.CollectionID).ruleName.tolower()

        foreach($vm in $vmList){
            $allDevice = Get-CMDevice -Name $vm -CollectionName "All Desktop and Server Clients"
            if($allDevice.count -eq 1){
                if($members -notcontains $vm.tolower() -and $rules -notcontains $vm.tolower()){
                    write-output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - Need to add $vm"
                    $retry = 0
                    while($retry -le 10){
                        try{
							Add-CMDeviceCollectionDirectMembershipRule -CollectionId $collection.CollectionID -ResourceId  $allDevice.ResourceID
                            $retry = 99
                        }
                        catch{
							$retry += 1
							write-output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - Error number : $retry retry in 30s"
							start-sleep 30
                        }
                    }
                }
            }
            else{
                write-output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - $vm not found in SCCM"
            }
        }

    }
    
    Catch{
      Write-output $_.Exception
      Break
    }
  }
  
  End{
    If($?){
      Write-output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - Completed Successfully."
    }
  }
}