# Code to Unlock locked AD User Account after passing wrong password excessive number of times
# ( beyond 'Lockout Threshold' limit accessed by net accounts command)

# 1. Get a user account that is locked
$lockedAccount = Read-Host "Provide user that you wish to unlock (type username)"
Get-ADUser -Identity $lockedAccount

# 2. Unlock the account
Unlock-ADAccount -Identity $lockedAccount