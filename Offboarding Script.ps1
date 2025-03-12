#Requires -RunAsAdministrator
#Requires -Version 4.0


# Defined Variables
Param (
    $user,
    $Selecteduser,
    $Offboarduser
)


Function DisableUser ($Offboarduser) {
    try{
        Disable-ADAccount -Identity $Offboarduser
        write-host "User Disabled" -Foregroundcolor Cyan
    }
    catch{
        write-host "Fail to Disable User" Foregroundcolor Red
    }
}

Function RemoveGroupMemberships ($Offboarduser) {
    #Remove memberships from group
    Write-Output "Removing User From Groups"
    try{
        Get-AdPrincipalGroupMembership -Identity $Offboarduser | Where-Object -Property Name -Ne -Value 'Domain Users' | Remove-AdGroupMember -Members $Offboarduser
        Write-Host "Removed $Offboarduser Group Membership" -Foregroundcolor Cyan
    }catch{
        Write-Host "Failed to Remove Group Membership!" -Foregroundcolor Red
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

cls
# Main Script
# Get all users from Users OU
$users = Get-ADUser -Filter *

# Create a GUI for user selection
$Selecteduser = $users | Out-GridView -Title "Select a user to offboard" -PassThru
$Offboarduser = $Selecteduser.sAMAccountName

# None GUI: $Offboarduser = Read-Host "Select a user to offboard: "

DisableUser $Offboarduser
RemoveGroupMemberships $Offboarduser
MoveToInactiveAccounts $Offboarduser
break
