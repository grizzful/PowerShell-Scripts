# Script to reset the password of a user in Active Directory
$Username = $ENV:Username
$ADUser = Get-ADUser -Identity $Username -ErrorAction SilentlyContinue
if ($null -eq $ADUser) {
    Write-Host "User $Username does not exist in Active Directory!" -ForegroundColor Red
    Write-Host "Canceling Script!" -ForegroundColor Red
    Exit 1
} else {
    Write-Host "User $Username found in Active Directory!" -ForegroundColor Cyan
}
Set-ADAccountPassword -Identity $ADUser -Reset -NewPassword (ConvertTo-SecureString -AsPlainText '1stPassword!' -Force) | set-aduser -changepasswordatlogon $true
write-host "Password for $Username has been reset successfully!" -ForegroundColor Cyan

# END OF SCRIPT
