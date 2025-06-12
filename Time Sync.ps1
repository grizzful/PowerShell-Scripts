#Requires -RunAsAdministrator

# Script Functions
function Show-Menu {
    # Menu function
    Write-Host "Choose an NTP Server:"
    Write-Host "1. Windows"
    Write-Host "2. Google"
    Write-Host "3. NTP.org"
}

function Change-NTP ($NewNTP) {
    # Set the NTP server in the registry  
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters" -Name "NtpServer" -Value $NewNTP
    
    # Change NTP server to the selected source
    w32tm /config /syncfromflags:manual /manualpeerlist:$NewNTP /update
   
    # Restart the Windows Time service
    Stop-Service w32time
    Start-Service w32time

    # Force a time resynchronization
    w32tm /resync /force

    # Display Current Configutation info
    w32tm /query /status

    # Display the current NTP server
    Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters" -Name "NtpServer"
}

# Start of Main Script
while ($true) {
    # Ask user to Choose which NTP server to use.
    $choice = Read-Host "Enter your choice (1-3)"

    switch ($choice) {
        "1" {
            # Change NTP to Windows NTP
            Write-Host "Selecting time.windows.com ..."
            $NewNTP = "time.windows.com"
            Change-NTP $NewNTP
            break
        }
        "2" {
            # Change NTP to Google NTP
            Write-Host "Selecting time.google.com ..."
            $NewNTP = "time.google.com"
            Change-NTP $NewNTP
            break
        }
        "3" {
            # Change NTP to NTP.org NTP
            Write-Host "Selecting pool.ntp.org ..."
            $NewNTP = "pool.ntp.org"
            Change-NTP $NewNTP
            break
        }
        default {
            Write-Host "Invalid choice. Please enter 1, 2, or 3."
        }
    }
    if ($choice -in ("1","2","3")) {
        break
    }
}
