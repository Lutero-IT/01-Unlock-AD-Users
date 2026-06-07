# Code to Unlock locked AD User Account after passing wrong password excessive number of times
# ( beyond 'Lockout Threshold' limit accessed by net accounts command)

# 1. Get a user account that is locked

$exit = $true

while ($true) {
    $lockedAccount = Read-Host "Provide user that you wish to unlock (type username) or exit program (type exit)"

    if ($lockedAccount -eq "exit")
    {
        Write-Host "Exiting program..."
        break
    } else {
        try {
            $user = Get-ADUser -Identity $lockedAccount -Properties * -ErrorAction Stop
            Write-Host "$lockedAccount found in database!"
            $isLocked = $user.LockedOut
            Write-Host "Is $lockedAccount locked?"
            $isLocked
            $exit = $false
            break
        } catch {
            Write-Host "Account doesn't exist in database!"
            Write-Host "Provide existing account or exit the program"
        }
    }
}

# 2. Unlock the account
if ($exit) {
    Write-Host "Program terminated!"
    exit
} else {
    if ($isLocked) {
        while ($true) {
        Write-Host "Do you wish to unlock the account?"
        $decision = Read-Host "Type [Yes/Y] or [No/N]"
        $yesList = "y", "yes"
        $noList = "n", "no"
            if ($decision -in $yesList) {
            Write-Host "Unlocking account..."
            Unlock-ADAccount -Identity $lockedAccount
            Write-Host "Account unlocked!"
            break
            } elseif ($decision -in $noList) {
                Write-Host "Account left locked"
                break
            } else {
                Write-Host "Invalid value!"
                Write-Host "Choose one of the suggested options"
            }
        }
    } else {
        Write-Host "Cannot unlock account. Account is not locked out!"
    }
}