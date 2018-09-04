<#
.SYNOPSIS
  Test the existance of a collection
.DESCRIPTION
  Check if the collection exist and return a boolean.
.PARAMETER SCCMSiteCode
  The SCCM site code
.PARAMETER collectionName
  The name of the collection to add devices to
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

Function Test-SCCMCollection{
  Param(
      [parameter(Mandatory=$true)]
        [String] $SCCMSiteCode,
      [parameter(Mandatory=$true)]
        [String] $collectionName
    )
  
  Begin{
    #Write-Output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - Start executing Test-SCCMCollection on $collectionName"
  }
  
  Process{
    $val = $false
    Try{
        Set-Location $SCCMSiteCode

        $collection = Get-CMCollection -Name $collectionName

        if ($collection){
            $true
        }
    }
    
    Catch{
      Write-output $_.Exception
      Break
    }

    return $val
  }
  
  End{
    If($?){
      #Write-output "$(get-date -Format 'hh:mm, dd/MM/yyyy') - Completed Successfully."
    }
  }
}