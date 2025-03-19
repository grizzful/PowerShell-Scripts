#Requires -RunAsAdministrator
#Requires -Version 4.0

# Define Global Variables
$Global:transcriptPath = ""
# Define Empty Global Variables
Param (
    $user,
    $Selecteduser,
    $Offboarduser,
    [string]$Confirmation
)

function Transcribe { 
    # Transcript for logging
    $currentAdmin = $env:Username
    $adminPC = $env:ComputerName
    $date = Get-Date -f yyyy-MM-dd_hh-mm-ss
    $transcriptFile = $transcriptPath + $currentAdmin + "_" + "$adminPC" + "_" + $date + ".txt" 
    Start-Transcript -Path $transcriptFile -noclobber
}

Function DisableUser ($Offboarduser) {
    try{
        Disable-ADAccount -Identity $Offboarduser
        write-host "User Disabled" -Foregroundcolor Cyan
    }catch{
        write-host "Fail to Disable User" Foregroundcolor Red
    }
}

Function RemoveGroupMemberships ($Offboarduser) {
    # Removes user from all groups expect domain_users
    Write-Output "Removing User From Groups"
    try{
        Get-AdPrincipalGroupMembership -Identity $Offboarduser | Where-Object -Property Name -Ne -Value 'Domain Users' | Remove-AdGroupMember -Members $Offboarduser
        Write-Host "Removed $Offboarduser Group Membership" -Foregroundcolor Cyan
    }catch{
        Write-Host "Failed to Remove Group Membership!" -Foregroundcolor Red
    }
}

Function ResetPassword ($Offboarduser) {
    # Generate Random password using System.Web
    Add-Type -Assembly System.Web
    $newPassword = [Web.Security.Membership]::GeneratePassword(16,4)
    # Set user's password to generated one
    Try{
    Set-ADAccountPassword -Identity $Offboarduser -NewPassword (ConvertTo-SecureString -AsPlainText $RandomPassword -Force)
    }catch{
        Write-Host "Failed to Reset Password"
    }
}

Function ChangeDesc ($Offboarduser) {
    # Changes User's Description to say when they were offboarded
    $CurrentTime = Get-Date -Format " (Offboarded: dd/MM/yyyy HH:mm)"
    try {
        Set-ADuser -Identity $Offboarduser -Clear Description
        Set-ADUser -Identity $Offboarduser -Description $CurrentTime
    }catch{

    }
}

Function MoveToInactiveAccounts ($Offboarduser) {
    # Moves account to Inactive Accounts
    $InactiveUserOU = "OU=Inactive Users,OU=TESTLANDIA,DC=TestDomain,DC=com"
    try{
    Get-ADUser $Offboarduser | Move-ADObject -TargetPath $InactiveUserOU
    Write-Host "$Offboarduser moved to IncactiveUsers" -Foregroundcolor Cyan
    }catch{
        Write-Host "Failed to Move User!" -Foregroundcolor Red
    }
}

# Exchange functions will go here
Function ConnectExchange () {
    param(
        [Parameter(Mandatory=$false)]
        [string]$URL="Exchange URL Here"
    )
    
    # Enter Admin Credentials to access Exchange
    $Credentials = Get-Credential -Message "Enter your Exchange admin credentials"

    Try{
        $ExOPSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$URL/PowerShell/ -Authentication Kerberos -Credential $Credentials
        Import-PSSession $ExOPSession
    } catch {
        Write-Host "Unable to connect to Exchange, unable to complete Exchange Offboard!"
    }
}


cls
# Main Script
# Get all users from Users OU
$users = Get-ADUser -Filter *

# Create a GUI for user selection
$Selecteduser = $users | Out-GridView -Title "Select a user to offboard" -PassThru
$Offboarduser = $Selecteduser.sAMAccountName

# None GUI: $Offboarduser = Read-Host "Select a user to offboard: "

# Ask to confirm offboard
$Confirmation = Read-Host "Are you sure you want to offboard $Offboarduser? (yes/no): " 

# If Confirm is yes, Offboard user
if ($Confirmation -like "y*") {
    DisableUser $Offboarduser
    RemoveGroupMemberships $Offboarduser
    MoveToInactiveAccounts $Offboarduser
}

else {
    Write-Output ""
    Write-Output "Offboarding has benn cancelled."
}

End
