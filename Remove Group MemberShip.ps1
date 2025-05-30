# Things to add
# Confirm user is out of group
# ADD OU PATH CONFIRMATION!
# Remove the csv file on script completion (maybe)

#Requires -RunAsAdministrator

# Assign OU path and CVS file path to variables
$OUPath = "" #samaccountname for path
$ExportPath = "C:\CDITS\RemoveFromGroups.csv"

# Uses the OUPath to export the users to a csv file
Get-ADUser -Filter * -SearchBase $OUpath | Select-object DistinguishedName,Name,UserPrincipalName | Export-Csv -NoType $ExportPath
Write-host `n"Exporting Inactive Accounts users to CSV file..."

$import = Import-Csv $ExportPath
# Ends script if no CSV file was made
if ($null -eq $import) {
    Write-Host `n"Failed to Create CSV file!" -Foregroundcolor Red
    Write-Host "Canceling Script!" -Foregroundcolor Red
    break
}

else{
    # Ask user the check csv file and confirm to remove users from groups
    Write-Host `n"CSV File Created Successfully!"
    $Confirmation = Read-Host "!CHECK CSV FILE! Are you sure you want to remove Inactive user from all groups? (yes/no): "
    
    if ($Confirmation -like "y*") {
        ForEach ($user in $import) {
    
            $UserDN = $user.DistinguishedName
            $Identity = $user.Name

            # Removes user from all groups expect domain_users
            Write-Output `n"Removing $Identity From all AD Groups..."
            try{
                Get-AdPrincipalGroupMembership -Identity $UserDN | Where-Object -Property Name -Ne -Value 'Domain Users' | Remove-AdGroupMember -Members $UserDN -Confirm:$False
                Write-Host "Removed $Identity Group Membership" -Foregroundcolor Cyan
            }catch{
                Write-Host "Failed to Remove Group Membership!" -Foregroundcolor Red
            }
   
        }
    }
    # Ends script if no was entered
    else {
        Write-Output `n"Group Removal was cancelled!"
    }
}
Write-Host `n"Done! Exiting script..."
