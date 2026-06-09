# 1. Get a list of ALL blocked account in the domain.
# 2. List the to the user and ask if he want to unlcok One/Few users or All.
# 3. Unlock accounts and return the output.
# 4. Unlock only specifed users

# POINT 1 & 2 #
Write-Host "Checking if there are any locked accounts..."
$result = Search-ADAccount -LockedOut
$formattedResult = $result | Format-Table Name, ObjectClass, LockedOut # tu dodać ograniczenie do wyświetlanych users

if ($result -eq $null) {
    Write-Host "No locked accounts found in the database!"
    } else {
        Write-Host "Found locked accounts in the database!"
        $formattedResult  # ogranicz liczbe wyswietlanych users do 50 lub 100 dla wielkich korporacji

        ### LOOP ###

        while ($result.Count -gt 0) {
            Write-Host "Which accounts do you wish to unlock?"
            #Make options to choose (1. User/Users | 2. All | 3. Exit)
            Write-Host "OPTIONS:"
            Write-Host "    1. User/Users"
            Write-Host "    2. All"
            Write-Host "    3. Exit"
            Write-Host "    4. Show list"
            $userChoice = Read-Host "Type option number or option value"

            # Options Lits #
            $userOptions = "1","one","user","users"
            $allOptions = "2","two","all"
            $exitOptions = "3","three","exit"
            $listOptions = "4", "four", "show list", "show", "list"

            # OPTION 1: Unlock User/Users
            if ($userChoice -in $userOptions) {
                Write-Host "Chose option number 1 - Unlock User or Users"
                Write-Host "Type user or list of users separated by comma that you want to unlock"
                Write-Host "For example 'John, Andre, Matthew'"
                $usersString = Read-Host
                $formatedList = $usersString.Split(',').Trim()

                foreach ($user in $formatedList) {
                    try {
                        $user = Get-ADUser -Identity $user -Properties * -ErrorAction Stop
                        $username = $user.name
                        Write-Host "$username found in database!"
                    } catch {
                        Write-Host "Account $username doesn't exist in database!"
                        Write-Host "Removing $username account from a list..."
                        $formatedList.Remove($user)
                        $formatedList = $formatedList | Where-Object { $_ -ne $user }
                        Write-Host "$user account removed from a list"
                    }   

                    Write-Host "Is $username account locked?"                        
                    $isLocked = $user.LockedOut
                    if ($isLocked) {
                        $isLocked
                        Write-Host "Account is locked"
                    } else {
                        $isLocked
                        Write-Host "Cannot unlock account. Account is not locked out!"
                        Write-Host "Removing $username account from a list..."
                        $formatedList = $formatedList | Where-Object { $_ -ne $username }
                        Write-Host "$username account removed from a list"
                    }
                }
                
                    # CHECK IF FormatedList is empty and if is, dont execute code below !!!
                    if ($formatedList -eq $null) {
                        Write-Host "### LIST ###"
                        Write-Host "------------"
                        Write-Host "List is empty. Returning to main menu"
                    } else {
                        Write-Host "Accounts you wish to unlock:"
                        Write-Host "### LIST ###"
                        $formatedList

                        Write-Host "Are you sure you want to unlock these accounts?"
                        while ($true) {
                            $confirm = Read-Host "Type [Yes/Y] or [No/N]"
                            $yesList = "y", "yes"
                            $noList = "n", "no"

                            if ($confirm -in $yesList) {
                                Write-Host "Unlocking accounts..."
                                $formatedList | Get-ADUser | Unlock-ADAccount
                                Write-Host "Accounts unlocked!"
                                break
                            } elseif ($confirm -in $noList) {
                                Write-Host "Accounts left locked"
                                break
                            } else {
                                Write-Host "Invalid value!"
                                Write-Host "Choose one of the suggested options"
                            }
                        }
                    }
                
                # UPDATE the list of locked accounts!
                $result = Search-ADAccount -LockedOut

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
                Write-Host "Terminating the program..."
                break
            }elseif ($userChoice -in $listOptions) {
                Write-Host "Chose option number 4 - Show list"
                $formattedResult = $result | Format-Table Name, ObjectClass, LockedOut
                Write-Host "Displaying list of locked accoutns..."
                Write-Host ""
                Write-Host "### LIST ###"
                $formattedResult
            } else {
                Write-Host "Non existent option or invalid value."
                Write-Host "Type number of option like 'one', '2', or 'THREE'..."
                Write-Host "...or option value like 'user', 'ALL' or 'Exit' "
            }
        }
        Write-Host "Program Terminated!"
    }
