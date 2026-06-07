# 1. Get a list of ALL blocked account in the domain.
# 2. List the to the user and ask if he want to unlcok One/Few users or All.
# 3. Unlock accounts and return the output.
# 4. Unlock only specifed users

# POINT 1 & 2 #
Write-Host "Checking if there are any locked accounts..."
$result = Search-ADAccount -LockedOut
$formattedResult = $result | Format-Table Name, ObjectClass, LockedOut

if ($result -eq $null) {
    Write-Host "No locked accounts found in the database!"
    } else {
        Write-Host "Found locked accounts in the database!"
        $formattedResult  # ogranicz liczbe wyswietlanych users do 50 lub 100 dla wielkich korporacji

        ### LOOP ###

        while ($result.Count -gt 0) {
            Write-Host "Which accounts do you wish to unlock?"
            #Make options to choose (1. User/Users | 2. All | 3. Exit)
            # Add Option "4. Show locked accounts"
            Write-Host "OPTIONS:"
            Write-Host "    1. User/Users"
            Write-Host "    2. All"
            Write-Host "    3. Exit"
            $userChoice = Read-Host "Type option number or option value"

            # Options Lits #
            $userOptions = "1","one","user","users"
            $allOptions = "2","two","all"
            $exitOptions = "3","three","exit"

            # OPTION 1: Unlock User/Users
            if ($userChoice -in $userOptions) {
                Write-Host "Script in progress. Terminating the loop..."
                break
            # OPTION 2: Unlock ALL
            } elseif ($userChoice -in $allOptions) {
                Write-Host "Chose option number 2 - Unlock all the users"
                Write-Host "Unlocking all the users..."
                Search-ADAccount -LockedOut | Unlock-ADAccount
                Write-Host "All the users unlocked!"
                $result = Search-ADAccount -LockedOut
            # OPTION 3: Exit
            } elseif ($userChoice -in $exitOptions) {
                Write-Host "Chose option number 3 - Exit"
                Write-Host "Terminating the loop..."
                break
            } else {
                Write-Host "Non existent option or invalid value."
                Write-Host "Type number of option like 'one', '2', or 'THREE'..."
                Write-Host "...or option value like 'user', 'ALL' or 'Exit' "
            }
        }
        Write-Host "Loop Terminated!"
    }

# make a commit after finishind options 'All' or 'Exit'

# make a loop that will iterate as long as there are any locked accounts left or until user choose to exit the script
# in order to make a loop I have to turn an array into a number, that represents the number of users. use length of the array
# and on each iteration check whether it is greter than 1. if it is not, terminate the loop and show a message that there are
# no more locked accounts


# POINT 4 #
# Unlock only specified users #
# 1. get list | 2. present the list | 3. ask user | 4. unlock chosen users
