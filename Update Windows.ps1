# Functions

function CheckPrivilege() {
    Write-host "Checking for Admin Privileges..."

    # End Script if not being run as Admin
    if ( -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    write-output "" 
    write-host -fore Red "You are not currently running this script under an Administrator account!"
    Start-Sleep -Seconds 1
    Exit
    } 
}


function UpdateOS(){
    Write-Host "`nUpdating OS."

    # Open Eventlogs for Windows Update
    Start-Process powershell -ArgumentList "-noexit", "-noprofile", "-command &{Get-Content C:\Windows\SoftwareDistribution\ReportingEvents.log -Tail 1 -Wait}"

    #Define update criteria.
    $Criteria = "IsInstalled=0"

    #Search for relevant updates.
    $Searcher = New-Object -ComObject Microsoft.Update.Searcher

    $SearchResult = $Searcher.Search($Criteria).Updates

    #Download updates.
    $Session = New-Object -ComObject Microsoft.Update.Session

    $Downloader = $Session.CreateUpdateDownloader()
    $Downloader.Updates = $SearchResult
    $Downloader.Download()

    $Installer = New-Object -ComObject Microsoft.Update.Installer
    $Installer.Updates = $SearchResult

    $Result = $Installer.Install()

    If ($Result.rebootRequired) { shutdown.exe /t 0 /r }
}



# Run Functions
CheckPrivilege
UpdateOS