# Functions created to change classical Write-Host and Read-Host behaviour
# by adding indentation in the beginning of each message and newline below it
# for better readability

$Indent = "`t"

function Write-IndentedLog ($Message) {
    Write-Host "${Indent}$Message" @Args
    Write-Host ""
}

function Read-IndentedLog ($Message) {
    Read-Host "${Indent}$Message"
}

# MAKE ATOMIC COMMIT AFTER IMPLEMENTING READ-INDETNEDLOG FUNCIOTN AND
# CODE REFACTORING !!!

# COMMITS PLAN:
# 1 commit - after making use of @Args ( PowerShell Splatting) to use parameters like
# -ForegroundColor or -BackgroundColor

# 2 commit - after refactoring sricpt and implementing colors to output messages
# mention that you removed newline character (`n) from Write-IndentedLog and put Write-Host

# 3 commit - solve the problem when no value is provided and just enter pressed
# along with this remove all the obsolete comments and notes. leave only important ones.

Write-IndentedLog ""
Write-IndentedLog "Checking if there are any locked accounts..."
$result = Search-ADAccount -LockedOut
$formattedResult = $result | Format-Table Name, ObjectClass, LockedOut | Out-String
$indentedResult = $formattedResult -replace '(?m)^', "$Indent"
# tu dodać ograniczenie do wyświetlanych users

if ($result -eq $null) {
    Write-IndentedLog "No locked accounts found in the database!" -BackgroundColor Yellow -ForegroundColor Black
    } else {
        Write-IndentedLog "Found locked accounts in the database!"  -BackgroundColor Yellow -ForegroundColor Black
        $indentedResult  # ogranicz liczbe wyswietlanych users do 50 lub 100 dla wielkich korporacji

        ### MAIN LOOP ###
        while ($result.Count -gt 0) {
            Write-IndentedLog "Which accounts do you wish to unlock?"
            Write-IndentedLog "OPTIONS:" -ForegroundColor Yellow
            Write-Host "${Indent}1. User/Users" -ForegroundColor Yellow
            Write-Host "${Indent}2. All" -ForegroundColor Yellow
            Write-Host "${Indent}3. Exit" -ForegroundColor Yellow
            Write-Host "${Indent}4. Show list`n" -ForegroundColor Yellow
            $userChoice = Read-IndentedLog "Type option number or option value"

            # OPTIONS LIST #
            $userOptions = "1","one","user","users"
            $allOptions = "2","two","all"
            $exitOptions = "3","three","exit"
            $listOptions = "4", "four", "show list", "show", "list"

            # OPTION 1: UNLOCK USER/USERS #
            if ($userChoice -in $userOptions) {
                Write-IndentedLog "Chose option number 1 - Unlock User or Users"  -BackgroundColor Yellow -ForegroundColor Black
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
                        Write-IndentedLog "$username found in database!" -BackgroundColor Yellow -ForegroundColor Black
                    } catch {
                        Write-IndentedLog "Account $username doesn't exist in database!" -BackgroundColor Yellow -ForegroundColor Black
                        Write-IndentedLog "Removing $username account from a list..."
                        $formatedList.Remove($user)
                        $formatedList = $formatedList | Where-Object { $_ -ne $user }
                        Write-IndentedLog "$user account removed from a list"
                    }   

                    Write-IndentedLog "Is $username account locked?"                        
                    $isLocked = $user.LockedOut
                    if ($isLocked) {
                        Write-IndentedLog "$isLocked" -BackgroundColor Green -ForegroundColor Black
                        Write-IndentedLog "Account is locked"  -BackgroundColor Yellow -ForegroundColor Black
                    } else {
                        Write-IndentedLog "$isLocked" -BackgroundColor Red -ForegroundColor White
                        Write-IndentedLog "Cannot unlock account. Account is not locked out!" -BackgroundColor Yellow -ForegroundColor Black
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
                        # format LIST to look like a TABLE ( record /breakline record) !!! DO IT !!!

                        Write-IndentedLog "Are you sure you want to unlock these accounts?"
                        while ($true) {
                            $confirm = Read-IndentedLog "Type [Yes/Y/y] or [No/N/n]"
                            $yesList = "y", "yes"
                            $noList = "n", "no"

                            if ($confirm -in $yesList) {
                                Write-IndentedLog "Unlocking accounts..."
                                $formatedList | Get-ADUser | Unlock-ADAccount
                                Write-IndentedLog "Accounts unlocked!"  -BackgroundColor Yellow -ForegroundColor Black
                                break
                            } elseif ($confirm -in $noList) {
                                Write-IndentedLog "Accounts left locked"  -BackgroundColor Yellow -ForegroundColor Black
                                break
                            } else {
                                Write-IndentedLog "Invalid value!" -BackgroundColor Yellow -ForegroundColor Black
                                Write-IndentedLog "Choose one of the suggested options"
                            }
                        }
                    }
                
                # UPDATE the list of locked accounts! #
                $result = Search-ADAccount -LockedOut

            # OPTION 2: UNLOCK ALL #
            } elseif ($userChoice -in $allOptions) {
                Write-IndentedLog "Chose option number 2 - Unlock all the users" -BackgroundColor Yellow -ForegroundColor Black
                Write-IndentedLog "Unlocking all the users..."
                Search-ADAccount -LockedOut | Unlock-ADAccount
                Write-IndentedLog "All the users unlocked!"
                $result = Search-ADAccount -LockedOut
            # OPTION 3: EXIT #
            } elseif ($userChoice -in $exitOptions) {
                Write-IndentedLog "Chose option number 3 - Exit" -BackgroundColor Yellow -ForegroundColor Black
                Write-IndentedLog "Terminating the program..."
                break
            # OPTION 4: SHOW LIST OF LOCKED ACCOUNTS #
            }elseif ($userChoice -in $listOptions) {
                Write-IndentedLog "Chose option number 4 - Show list" -BackgroundColor Yellow -ForegroundColor Black
                $formattedResult = $result | Format-Table Name, ObjectClass, LockedOut | Out-String
                $indentedResult = $formattedResult -replace '(?m)^', "$Indent"
                Write-IndentedLog "Displaying list of locked accoutns..."
                Write-IndentedLog ""
                Write-IndentedLog "### LIST ###"
                $indentedResult
            } else {
                Write-IndentedLog "Non existent option or invalid value." -BackgroundColor Red -ForegroundColor Black
                Write-IndentedLog "Type number of option like 'one', '2', or 'THREE'..."
                Write-IndentedLog "...or option value like 'user', 'ALL' or 'Exit' "
            }
        }
        Write-IndentedLog "Program Terminated!"  -BackgroundColor Yellow -ForegroundColor Black
    }