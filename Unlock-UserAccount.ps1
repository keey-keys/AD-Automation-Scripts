#Requires -Modules ActiveDirectory
#Requires -Version 5.1

<#
.SYNOPSIS
    Unlocks a locked Active Directory user account and logs the action.

.DESCRIPTION
    Accepts a username as a parameter, verifies the account exists,
    checks its lock status, unlocks if necessary, and logs the action
    with a timestamp for compliance and audit trail purposes.

.PARAMETER Username
    The SamAccountName of the user account to unlock.

.PARAMETER LogPath
    Directory path where the unlock log will be saved. Default is C:\Scripts\Logs.

.EXAMPLE
    .\Unlock-UserAccount.ps1 -Username "jsmith"
    .\Unlock-UserAccount.ps1 -Username "jsmith" -LogPath "D:\Logs"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Username,

    [string]$LogPath = "C:\Scripts\Logs"
)

$LogFile = Join-Path $LogPath "UnlockLog.txt"

# Create log directory if it doesn't exist
New-Item -Path $LogPath -ItemType Directory -Force | Out-Null

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $Entry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    Write-Host $Entry -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $Entry
}

try {
    # Verify user exists
    $User = Get-ADUser -Identity $Username -Properties LockedOut -ErrorAction Stop

    if ($User.LockedOut) {
        Unlock-ADAccount -Identity $Username
        Write-Log "SUCCESS: Unlocked account for $Username" -Color "Green"
    } else {
        Write-Log "INFO: Account $Username is not locked. No action taken." -Color "Yellow"
    }

} catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    Write-Log "ERROR: User '$Username' not found in Active Directory." -Color "Red"
    exit 1
} catch {
    Write-Log "ERROR: An unexpected error occurred. $_" -Color "Red"
    exit 1
}
