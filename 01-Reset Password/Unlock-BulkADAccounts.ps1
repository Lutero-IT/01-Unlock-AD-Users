# 1. Get a list of ALL blocked account in the domain.
# 2. List the to the user and ask if he want to unlcok One/Few users or All.
# 3. Unlock accounts and return the output.
# 4. Unlock only specifed users

$Indent = "`t"
# add indent and make atomic commit NOW!!!

# POINT 1 & 2 #
Write-Host "${Indent}"
Write-Host "${Indent}Checking if there are any locked accounts..."
$result = Search-ADAccount -LockedOut
$formattedResult = $result | Format-Table Name, ObjectClass, LockedOut | Out-String
$indentedResult = $formattedResult -replace '(?m)^', "$Indent"
# tu dodać ograniczenie do wyświetlanych users

if ($result -eq $null) {
    Write-Host "${Indent}No locked accounts found in the database!"
    } else {
        Write-Host "${Indent}Found locked accounts in the database!"
        $indentedResult  # ogranicz liczbe wyswietlanych users do 50 lub 100 dla wielkich korporacji
        # Write-Host "${Indent}" z $formattedResult nie działa, zobaczyć dlaczego

        ### LOOP ###

        while ($result.Count -gt 0) {
            Write-Host "${Indent}Which accounts do you wish to unlock?"
            Write-Host "${Indent}OPTIONS:" -ForegroundColor Cyan
            Write-Host "${Indent}1. User/Users" -ForegroundColor Yellow
            Write-Host "${Indent}2. All" -ForegroundColor Yellow
            Write-Host "${Indent}3. Exit" -ForegroundColor Yellow
            Write-Host "${Indent}4. Show list" -ForegroundColor Yellow
            $userChoice = Read-Host "${Indent}Type option number or option value"

            # Options Lits #
            $userOptions = "1","one","user","users"
            $allOptions = "2","two","all"
            $exitOptions = "3","three","exit"
            $listOptions = "4", "four", "show list", "show", "list"

            # OPTION 1: Unlock User/Users
            if ($userChoice -in $userOptions) {
                Write-Host "${Indent}Chose option number 1 - Unlock User or Users"
                Write-Host "${Indent}Type user or list of users separated by comma that you want to unlock"
                Write-Host "${Indent}For example 'John, Andre, Matthew'"
                $usersString = Read-Host "${Indent}" # change prompt sign to '>>' !!!
                $formatedList = $usersString.Split(',').Trim()
                # pressing Enter without typing value triggers error 'ArgumentOutOfRangeException'. WHY? CHECK IT !!!
                foreach ($user in $formatedList) {
                    try {
                        $user = Get-ADUser -Identity $user -Properties * -ErrorAction Stop
                        $username = $user.name
                        Write-Host "${Indent}$username found in database!"
                    } catch {
                        Write-Host "${Indent}Account $username doesn't exist in database!"
                        Write-Host "${Indent}Removing $username account from a list..."
                        $formatedList.Remove($user)
                        $formatedList = $formatedList | Where-Object { $_ -ne $user }
                        Write-Host "${Indent}$user account removed from a list"
                    }   

                    Write-Host "${Indent}Is $username account locked?"                        
                    $isLocked = $user.LockedOut
                    if ($isLocked) {
                        Write-Host "${Indent}$isLocked"
                        Write-Host "${Indent}Account is locked"
                    } else {
                        Write-Host "${Indent}$isLocked"
                        Write-Host "${Indent}Cannot unlock account. Account is not locked out!"
                        Write-Host "${Indent}Removing $username account from a list..."
                        $formatedList = $formatedList | Where-Object { $_ -ne $username }
                        Write-Host "${Indent}$username account removed from a list"
                    }
                }
                
                    if ($formatedList -eq $null) {
                        Write-Host "${Indent}### LIST ###"
                        Write-Host "${Indent}------------"
                        Write-Host "${Indent}List is empty. Returning to main menu"
                    } else {
                        Write-Host "${Indent}Accounts you wish to unlock:"
                        Write-Host "${Indent}### LIST ###"
                        Write-Host "${Indent}$formatedList"
                        # format LIST to look like a TABLE ( record /breakline record)

                        Write-Host "${Indent}Are you sure you want to unlock these accounts?"
                        while ($true) {
                            $confirm = Read-Host "${Indent}Type [Yes/Y] or [No/N]"
                            $yesList = "y", "yes"
                            $noList = "n", "no"

                            if ($confirm -in $yesList) {
                                Write-Host "${Indent}Unlocking accounts..."
                                $formatedList | Get-ADUser | Unlock-ADAccount
                                Write-Host "${Indent}Accounts unlocked!"
                                break
                            } elseif ($confirm -in $noList) {
                                Write-Host "${Indent}Accounts left locked"
                                break
                            } else {
                                Write-Host "${Indent}Invalid value!"
                                Write-Host "${Indent}Choose one of the suggested options"
                            }
                        }
                    }
                
                # UPDATE the list of locked accounts!
                $result = Search-ADAccount -LockedOut

            # OPTION 2: Unlock ALL
            } elseif ($userChoice -in $allOptions) {
                Write-Host "${Indent}Chose option number 2 - Unlock all the users"
                Write-Host "${Indent}Unlocking all the users..."
                Search-ADAccount -LockedOut | Unlock-ADAccount
                Write-Host "${Indent}All the users unlocked!"
                $result = Search-ADAccount -LockedOut
            # OPTION 3: Exit
            } elseif ($userChoice -in $exitOptions) {
                Write-Host "${Indent}Chose option number 3 - Exit"
                Write-Host "${Indent}Terminating the program..."
                break
            }elseif ($userChoice -in $listOptions) {
                Write-Host "${Indent}Chose option number 4 - Show list"
                $formattedResult = $result | Format-Table Name, ObjectClass, LockedOut | Out-String
                $indentedResult = $formattedResult -replace '(?m)^', "$Indent"
                Write-Host "${Indent}Displaying list of locked accoutns..."
                Write-Host "${Indent}"
                Write-Host "${Indent}### LIST ###"
                $indentedResult
            } else {
                Write-Host "${Indent}Non existent option or invalid value."
                Write-Host "${Indent}Type number of option like 'one', '2', or 'THREE'..."
                Write-Host "${Indent}...or option value like 'user', 'ALL' or 'Exit' "
            }
        }
        Write-Host "${Indent}Program Terminated!"
    }

### NOTES ###
# jak zrobic, zeby wszystkie linie byly o jednego Taba od krawedzi konsoli?