# Add check if user is in group
# Add logging
# Confirm user is out of group
# Add confirm passing

$OUPath = "OU"
$ExportPath = "Path\RemoveFromGroups.csv"

Get-ADUser -Filter * -SearchBase $OUpath | Select-object DistinguishedName,Name,UserPrincipalName | Export-Csv -NoType $ExportPath

$import = Import-Csv $ExportPath

ForEach ($user in $import) {

    # Removes user from all groups expect domain_users

    Write-Output `n"Removing $import From all AD Groups..."

    try{

        Get-AdPrincipalGroupMembership -Identity $import | Where-Object -Property Name -Ne -Value 'Domain Users' | Remove-AdGroupMember -Members $import

        Write-Host "Removed $import Group Membership" -Foregroundcolor Cyan

    }catch{
        Write-Host "Failed to Remove Group Membership!" -Foregroundcolor Red
    }
}

Write-Host "Done!"
