# Set path to the installer
$Installpath = "" # Enter path to installer

# Installs
if (!(test-path -path $Installpath)) {
    write-output 'Path to the installer not found.'
} else {
    $Installer = (Get-ItemProperty -path $Installpath)
    write-output 'Installing...'
    invoke-item -path $Installer
}

# End of Script
