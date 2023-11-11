<#

SCRIPT NAME: Remove smbshare

VERSION: 1.0

AUTHOR: Alexander Harnett

PLATFORM: Windows OS

DESCRIPTION: PowerShell script to remove a smb shares

MODIFIED: 2023-01-31

#>



#----------------------------------------------------------

#----------------------------------------------------------



# Varibles

# Path or list of protected shares that should never be removed
$ProtectedShares = 'ADMIN$', 'APPS$', 'C$', 'D$', 'IPS$'

# Share or list of shares to be removed
$RemoveShareList = 'LOGS'

# Default same folder path as this script (empty if script is not saved)
$strLogFolder = $($PSScriptRoot)
if (-not($strLogFolder)) {
    $strLogFolder = "C:\TEMP"
}

# Path to logfile
$LogFile = "$strLogFolder\RemoveLOGS.csv"

$strDate = (Get-Date).ToString(“yyyyMMdd-hhmm”)
$LogFile = "$strLogFolder\RemoveLOGS-$strDate.csv"

$aryResults = @()

$Result = "" | select time, action, result
##########################################

Write-Output ""

# Check for Administrator Permissions before running script

$MSG_RUNAS_ADMIN = "Checking to see if the current user context is Administrator"
$MSG_RUNAS_ADMIN_FAIL = "You are not currently running this script under an Administrator account!"
Clear-Host
Write-Output ""
Write-Host -Fore Yellow
$MSG_RUNAS_ADMIN

if ( -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output ""
    Write-Host -Fore Red $MSG_RUNAS_ADMIN_FAIL
    Start-Sleep -Seconds 1
    Exit

}  

# Verify that no protected shares are being removed. Close Program if protected share is detected
foreach($RemoveShare in $RemoveShareList){
    if ($ProtectedShares -eq $RemoveShare){
       $MSG_ERROR = Write-Output "The share '$RemoveShare' is are protected share and can not be removed!"
       Write-Host -Fore Red $MSG_ERROR
       Exit
    }

}

# Remove Share(s) from devices
foreach($RemoveShare in $RemoveShareList){
    Write-Output "Removing share $RemoveShare......"
    $Error.Clear()
    Try {
        Remove-SmbShare -Name $RemoveShare -Force -ErrorAction Stop
        $outcome = "Share $RemoveShare has been deleted"
        Write-Output $outcome
    } Catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] {
        $strErrMsg = "No Share with the name '$RemoveShare' found on device." # + $vbCrLf
        if ($Error[0]) { 
            $strErrMsg += $($Error[0].Exception.Message)}
            Write-Output $strErrMsg
            $outcome = $strErrMsg

        } Catch {
            $strErrMsg = "Share '$RemoveShare' - An error occurred that could not be resolved. "
            if ($Error[0]) {
                $strErrMsg += $($Error[0].Exception.Message) }
            Write-Output $strErrMsg
            $outcome = $strErrMsg

        }

        # Log the results of the share deletion 
        $Result.time = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
        $Result.action = "Remove smb-share"
        $Result.result = $outcome 
        $Result | Format-Table

}   

Write-Output ""

# Log results and create/update to logfile
Write-Output "Logging results ..."
$Result | Out-File -FilePath $LogFile -Encoding ASCII -NoTypeInformation -Append

# Check if logfile path is correct
Try { 
    Test-Path -Path $LogFile -ErrorAction Stop
    $null = $aryResults |
    Set-Content -Path $LogFile
    Invoke-Item $LogFile

} Catch {

    Write-Output "ERROR: Invalid Log file : '$LogFile'!"

}

# End of Script
