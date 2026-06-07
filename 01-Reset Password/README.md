# Active Directory Account Unlocker (Bulk and Single User)
Scripts in this repository allow an Administrator to check whether there are any locked user accounts in Active Directory and unlock them if they choose to. There is a script for unlocking a single AD user account called `Unlock-ADUser.ps1` and a script for unlocking bulk users named `Unlock-BulkADAccounts.ps1`.

## The Context 
A user reports that their account is blocked after passing an invalid password too many times, exceeding the password lockout threshold.

## The Task
To solve the problem of locked accounts without using a GUI, relying solely on PowerShell.

### Single User Operations
Create a script that checks whether a user account is present in the database. If not, an appropriate message should be shown, and the script should prompt for an existing account until the user chooses to exit the program. After a valid account is provided, the script should check whether it is locked. If the account is not locked, the user should be informed, and the program terminates. If the account is locked, the user should be asked whether they want to unlock it or leave it locked.

### Bulk Operations
The same logic applies to bulk operations, but additionally, the script should allow an Administrator to unlock not only a single user but a few or all users, or leave them locked.

## The Solution

### Single User Operations
I implemented a robust error handling mechanism using `try/catch` blocks and strict error policies (`-ErrorAction Stop`) inside the first `while` loop.

In the second `while` loop, I made use of whitelists of accepted values for a better user experience. Thanks to PowerShell's built-in case insensitivity, it is possible to type options or usernames in uppercase, lowercase, or mixed case and still achieve the desired result.

### Bulk Operations
The same architectural design applies to bulk users, but the `if/else` statements and `while` loops are much more developed to accommodate a wider range of administrative choices.

## The Automation

This section provides a step-by-step guide on prerequisites, deployment, and how to execute the tools in a production environment.

### Prerequisites & Dependencies
To run these scripts successfully, the administrative workstation or server must meet the following infrastructure requirements:
* **Operating System:** Windows 10/11 or Windows Server 2016/2019/2022.
* **PowerShell:** PowerShell 5.1 or higher.
* **Permissions:** Active Directory administrative privileges (specifically delegated permissions to modify user account states in the target Organizational Units).
* **Remote Server Administration Tools (RSAT):** The native `ActiveDirectory` PowerShell module must be installed.

### Installation / Module Deployment
If the `ActiveDirectory` module is not present on your system, install it via PowerShell as an Administrator:

# For Windows Server environments:
Add-WindowsFeature RSAT-AD-PowerShell

# For Windows Client (10/11) environments:
Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"

### Execution Guide

#### Running Single User Unlocker
To handle an individual user lockout request, navigate to the script directory and execute:
```powershell
.\Unlock-ADUser.ps1
```

The script will initiate an interactive loop, validating the user's existence and lock state before prompting for the final action.

#### Running Bulk User Unlocker
To manage multiple locked accounts across the domain simultaneously, execute:
```powershell
.\Unlock-BulkADAccounts.ps1
```

This tool will automatically query the Active Directory database for all currently locked accounts and present a control menu for batch processing.