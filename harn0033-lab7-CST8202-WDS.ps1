#Lab 7 progarm for 8202WDS
#Log file is located in C:\logfile.txt
#By Alex Harnett


$UseBuilder = "UseBuilder"

$logfile = "C:\logfile.txt"

#Functions used by the script

#Function used when writing to the log file
function WriteToLog ($message) {
    Add-content $logfile -value $message
}

#Function for the start banner
function StartBanner {
Write-Output ""
Write-Output "==============================================="
Write-Output "            Welcome to UseBuilder              "
Write-Output "==============================================="
Write-Output ""
}

#Funcation for the End banner
function EndBanner {
#Record time, date and current user (needs address)
$CurrentTime = Get-Date -Format "dd/MM/yyyy HH:mm"
WriteToLog "User $env:UserName closed $UseBuilder at $CurrentTime"

#Closing Message    
Write-Output ""  
Write-Output "==============================================="
Write-Output "               G O O D    B Y E                "
Write-Output "==============================================="
Write-Output ""  
}

#Function for the Return Banner to bring user back to main menu
function MainMenu {
    Write-Output ""
    Write-Output "Returning the Main Menu......"
    Write-Output ""
}

#Function for creating new user [1]
function CreateUser {
    
    #Username for New Account
    $Username = Read-Host -Prompt "Enter a Username for the New User: " 
    
    #Check if name exists from get-localuser, if it does, then creation is canceled
    $UserCheck = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue  
    

    #Checks if the username exists. If it does not, then creation will continue, if it does, creation canceled
    if ($Username -eq $UserCheck) {
        #Canceled creation If username is alrady in use
        Write-Output "User $Username already exist, canceling creation...."
    }
     
    else {
        #Secure password for new user
        $pass = Read-Host -AsSecureString "Enter a Password for the User: " 

        #add description for user
        $desc = Read-Host -Prompt "Enter a Description for the User: " 

        #create user and marks time of creation
        $CurrentTime = Get-Date -Format " (Created: dd/MM/yyyy HH:mm)"
        New-LocalUser -Name $Username -Description "$desc, $CurrentTime" -Password $pass -Confirm
        
        #Create or added new account to group
        $GroupSingleUser = Read-Host "Enter the name of the group you wish to add the new user to: "  
        $CheckGroup = Get-LocalGroup -Name $GroupSingleUser -ErrorAction SilentlyContinue
        
        #If Group already exists, adds user to group
        if ($GroupSingleUser -eq $CheckGroup){
            Write-Output "Group $CheckGroup already exists, added user to group $CheckGroup...."
            Add-LocalGroupMember -Group $CheckGroup -Member $Username
            #logs creation of new user
            WriteToLog "Finised creating user $Username, added to group $CheckGroup ($CurrentTime)"
        }

        #if group does not exist, creates the group and adds user 
        else {
            Write-Output "Group $GroupSingleUser does not exist, creating group $GroupSingleUser...."
            New-LocalGroup -Name $GroupSingleUser 
            Add-LocalGroupMember -Group $GroupSingleUser -Name $Username       
            WriteToLog "Finised creating user $Username, added to group $GroupSingleUser ($CurrentTime)"

        
        }
    #Marks the end of the function
    Write-Output "The User has been created"

        #Return to Main Menu
         
    }
      
   
}

#Function for creating 100 new users [3]
function CreateUser100 {
    #Confirms With user if they want to create accounts
    $choice = Read-Host "Would you like to create 100 new user accounts ([1] for yes [2]for no): " 

    #Testing how switches work instead of if statments, if user pick 1, user creation is started, 2 cancels and anything else errors
    Switch ($choice) {

        #If they selected 1
        1 { 
            #Set default password for new user accounts
            $Defaultpass = Read-Host -AsSecureString "Enter a Default Password for all the New Users: " 
            
            #Skips this part if Workgroup exists
            $group0 = Get-LocalGroup -Name "Group100Users"

            if ($null -ne $group0) {
                Write-Output "Placing new users into Group100Users"

            }

            #Creates WorkGroup to put new users in if needed
            else {
                Write-Output "Creating new group for Users00-User99......"
                New-LocalGroup -Name "Group100Users"
                WriteToLog "Created Local Group Group100Users"
            }

            #The users are created using this for loop
            Write-Output "Creating User00-User99........"
            for ( $i = 0 ; $i -lt 100 ; $i++ ) {
                #New users get name, default password and makes user create new pass a logon
                $Name = "User$i"
                New-LocalUser -Name $Name -Password $Defaultpass | Set-LocalUser -PasswordNeverExpires $false
                #adds user to group
                Add-LocalGroupMember -Name "Group100Users" -Member $Name
            }
        
        #logs action and returns to main menu
        $CurrentTime = Get-Date -Format " (Created: dd/MM/yyyy HH:mm)"
        WriteToLog "Created 100 new users ($CurrentTime)"
        
        }
        
        2 {
            #If user Does not want to make new accounts, returns to mainmenu
           Write-Output "Action canceled" 
        }    
            
        default {
            Write-Output "invaild input, try again"
            CreateUser100
        }
        
    }
    
    
}

#Function for create user from a file [4]
function CreateUserFile {
    #enter the file which the users will be created from
    #$UserPath = Read-Host -Prompt "Enter the path to the CVS file you want to use: (Userlist.csv)"
   
    $Cvsfile = Import-Csv -Path "C:\Users\pffff_THE_BIG_ONE\Documents\Algonquin\Fall 2021\Windows Desktop Support\UserList.csv" -Demlimiter ";"
    Write-Output "$Cvsfile"

    #foreach 
    foreach ($User in $Cvsfile) {

        #Collects data from Userlist.csv onto variables
        $First = $User.First 
        $Last = $User.Last
        $Uname = $User.Uname
        $Group1 = $User.Group
        $Group2 = $User.Group2 
        
        New-LocalUser -Name $Uname -FullName "$Last, $First" -NoPassword | Set-LocalUser -PasswordNeverExpires $false
        Add-LocalGroupMember -Name $Group1 -Member $Uname
        Add-LocalGroupMember -Name $Group2 -Member $Uname
        Write-Host "The user account $Uname has been created and has been added to $Group1, and $Group2"
        $CurrentTime = Get-Date -Format " (Created: dd/MM/yyyy HH:mm)"
        WriteToLog "Created Users from CVS ($CurrentTime)"  
        
            
    }

    Write-Output "Process Complete"
}

#Function for removing user [2]
function RemoveUser {
    #list of users
    $UserList = Get-LocalUser 
    Write-Output "$UserList"

    #prompt for user to delete
    $RemoveUser = Read-Host "Enter Name of User You Want to Remove: " 

    #Check if user exists


    #Confirms with the user that they want to remove entered account
    $Confirm = Read-Host "Are you Sure you would want to remove $RemoveUser (y/n): " 
    #Removes account and returns to main menu
    if ( $Confirm -eq 'y' ) {
        Write-Output "Removing User $RemoveUser"
        Remove-LocalUser -Name $RemoveUser
        Write-Output "$RemoveUser has been removed"
        $CurrentTime = Get-Date -Format " (Created: dd/MM/yyyy HH:mm)"
        WriteToLog "User $RemoveUser was removed ($CurrentTime)"
    }
    #Cancels action if user anwsered n
    else 
    {
        Write-Output "Stoping Action....."
    }
    
}

#Main menu for the script
Clear-Host

#do sends user back to main menu after completing function or misinputing at main menu
do {
    [int]$UserChoice = 0 
    while ( $UserChoice -lt 1 -or $UserChoice -gt 5) {
        StartBanner
        Write-Output  "[1] Create a new User"
        Write-Output  "[2] Remove a User"
        Write-Output  "[3] Create 100 Users"
        Write-Output  "[4] Create User From File"
        Write-Output  "[5] Exit Program"
        
        #user inputs their choice 
        [int]$UserChoice = Read-Host -Prompt "Please Select a Corresponding Option: " 

        #Switch for the optio
        switch ($UserChoice) {
            #Option for Create User
            1 {
                CreateUser; MainMenu
            }
    
            #Option for Remove User
            2 {
                RemoveUser; MainMenu
            }
    
            #Option for Create 100 Users
            3 {
                CreateUser100; MainMenu
            }
    
            #Option for Create User from File
            4 {
                CreateUserFile; MainMenu
            }

            #Exits Script
            5 {
                EndBanner; break    
            }

            #If User Enters Invaild Input
            default {
                Write-Host "Invaild Input, try again"; MainMenu
            }
        }
    }    
} while ( $UserChoice -ne 5 )   

break
#Exit Protcol
