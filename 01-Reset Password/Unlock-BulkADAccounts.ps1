# 1. Get a list of ALL blocked account in the domain.
# 2. List the to the user and ask if he want to unlcok One/Few users or All.
# 3. Unlock accounts and return the output.
# 4. Unlock only specifed users

$Indent = "`t"
# add function to combine indentation and newline and make ATOMIC COMMIT!

# function created to replace classical Write-IndentedLog to add indentation on the
# beginning of each message and newline below it
function Write-IndentedLog ($Message, $Color = "White") {
    Write-Host "${Indent}$Message`n" -ForegroundColor $Color
}

function Read-IndentedLog ($Message, $Color = "White") {
    Read-Host "${Indent}$Message"
}

# MAKE ATOMIC COMMIT AFTER IMPLEMENTING READ-INDETNEDLOG FUNCIOTN AND
# CODE REFACTORING !!!

# COMMITS PLAN:
# 0 commit - after Read-IndentedLog function
# 1 commit - after finishing indentation
# 2 commit - after refactoring sricpt and implementing colors to output messages

# POINT 1 & 2 #
Write-IndentedLog ""
Write-IndentedLog "Checking if there are any locked accounts..."
$result = Search-ADAccount -LockedOut
$formattedResult = $result | Format-Table Name, ObjectClass, LockedOut | Out-String
$indentedResult = $formattedResult -replace '(?m)^', "$Indent"
# tu dodać ograniczenie do wyświetlanych users

if ($result -eq $null) {
    Write-IndentedLog "No locked accounts found in the database!"
    } else {
        Write-IndentedLog "Found locked accounts in the database!"
        $indentedResult  # ogranicz liczbe wyswietlanych users do 50 lub 100 dla wielkich korporacji
        # Write-IndentedLog "" z $formattedResult nie działa, zobaczyć dlaczego

        ### LOOP ###

        while ($result.Count -gt 0) {
            Write-IndentedLog "Which accounts do you wish to unlock?"
            Write-IndentedLog "OPTIONS:" -ForegroundColor Yellow # ForeGround nie działa, dlaczego?
            Write-Host "${Indent}1. User/Users" -ForegroundColor Yellow
            Write-Host "${Indent}2. All" -ForegroundColor Yellow
            Write-Host "${Indent}3. Exit" -ForegroundColor Yellow
            Write-Host "${Indent}4. Show list`n" -ForegroundColor Yellow
            $userChoice = Read-IndentedLog "Type option number or option value"

            # Options Lits #
            $userOptions = "1","one","user","users"
            $allOptions = "2","two","all"
            $exitOptions = "3","three","exit"
            $listOptions = "4", "four", "show list", "show", "list"

            # OPTION 1: Unlock User/Users
            if ($userChoice -in $userOptions) {
                Write-IndentedLog "Chose option number 1 - Unlock User or Users"
                Write-IndentedLog "Type user or list of users separated by comma that you want to unlock"
                Write-IndentedLog "For example 'John, Andre, Matthew'"
                # PROBLEM HERE !!! CHOSE OPTION 1 AND SOLVE IT !
                # sprawdz czy Read-Host może mieć pusty prompt (-Prompt "") ???

                $usersString = Read-IndentedLog ">>>"  # change prompt sign to '>>' !!!

                $formatedList = $usersString.Split(',').Trim()
                # pressing Enter without typing value triggers error 'ArgumentOutOfRangeException'. WHY? CHECK IT !!!
                foreach ($user in $formatedList) {
                    try {
                        $user = Get-ADUser -Identity $user -Properties * -ErrorAction Stop
                        $username = $user.name
                        Write-IndentedLog "$username found in database!"
                    } catch {
                        Write-IndentedLog "Account $username doesn't exist in database!"
                        Write-IndentedLog "Removing $username account from a list..."
                        $formatedList.Remove($user)
                        $formatedList = $formatedList | Where-Object { $_ -ne $user }
                        Write-IndentedLog "$user account removed from a list"
                    }   

                    Write-IndentedLog "Is $username account locked?"                        
                    $isLocked = $user.LockedOut
                    if ($isLocked) {
                        Write-IndentedLog "$isLocked"
                        Write-IndentedLog "Account is locked"
                    } else {
                        Write-IndentedLog "$isLocked"
                        Write-IndentedLog "Cannot unlock account. Account is not locked out!"
                        Write-IndentedLog "Removing $username account from a list..."
                        $formatedList = $formatedList | Where-Object { $_ -ne $username }
                        Write-IndentedLog "$username account removed from a list"
                    }
                }
                
                    if ($formatedList -eq $null) {
                        Write-IndentedLog "### LIST ###"
                        Write-IndentedLog "------------"
                        Write-IndentedLog "List is empty. Returning to main menu"
                    } else {
                        Write-IndentedLog "Accounts you wish to unlock:"
                        Write-IndentedLog "### LIST ###"
                        Write-IndentedLog "$formatedList"
                        # format LIST to look like a TABLE ( record /breakline record)

                        Write-IndentedLog "Are you sure you want to unlock these accounts?"
                        while ($true) {
                            $confirm = Read-IndentedLog "Type [Yes/Y] or [No/N]"
                            $yesList = "y", "yes"
                            $noList = "n", "no"

                            if ($confirm -in $yesList) {
                                Write-IndentedLog "Unlocking accounts..."
                                $formatedList | Get-ADUser | Unlock-ADAccount
                                Write-IndentedLog "Accounts unlocked!"
                                break
                            } elseif ($confirm -in $noList) {
                                Write-IndentedLog "Accounts left locked"
                                break
                            } else {
                                Write-IndentedLog "Invalid value!"
                                Write-IndentedLog "Choose one of the suggested options"
                            }
                        }
                    }
                
                # UPDATE the list of locked accounts!
                $result = Search-ADAccount -LockedOut

            # OPTION 2: Unlock ALL
            } elseif ($userChoice -in $allOptions) {
                Write-IndentedLog "Chose option number 2 - Unlock all the users"
                Write-IndentedLog "Unlocking all the users..."
                Search-ADAccount -LockedOut | Unlock-ADAccount
                Write-IndentedLog "All the users unlocked!"
                $result = Search-ADAccount -LockedOut
            # OPTION 3: Exit
            } elseif ($userChoice -in $exitOptions) {
                Write-IndentedLog "Chose option number 3 - Exit" -BackgroundColor Green
                Write-IndentedLog "Terminating the program..."
                break
            }elseif ($userChoice -in $listOptions) {
                Write-IndentedLog "Chose option number 4 - Show list"
                $formattedResult = $result | Format-Table Name, ObjectClass, LockedOut | Out-String
                $indentedResult = $formattedResult -replace '(?m)^', "$Indent"
                Write-IndentedLog "Displaying list of locked accoutns..."
                Write-IndentedLog ""
                Write-IndentedLog "### LIST ###"
                $indentedResult
            } else {
                Write-IndentedLog "Non existent option or invalid value."
                Write-IndentedLog "Type number of option like 'one', '2', or 'THREE'..."
                Write-IndentedLog "...or option value like 'user', 'ALL' or 'Exit' "
            }
        }
        Write-IndentedLog "Program Terminated!"
    }

### NOTES ###
# jak zrobic, zeby wszystkie linie byly o jednego Taba od krawedzi konsoli?