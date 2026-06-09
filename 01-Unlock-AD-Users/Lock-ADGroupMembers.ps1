# This script is for test purposes.
# Lock chosen AD Group members and try to unlock them.

$groupName = Read-Host "Provide an AD group you wish to lock"
$group = Get-ADGroupMember -Identity $groupName

foreach ($user in $group) {
    1..5 | ForEach-Object {
        net use \\localhost /user:$($user.SamAccountName) "ZleHaslo123!" 2>$null
    }
    Write-Host "$($user.SamAccountName) account is locked ..."
}

# Check if accounts are blocked
Get-ADGroupMember -Identity Shadows | Get-ADUser -Properties LockedOut | Select-Object -Property Name, LockedOut