# Unlock-UserAccount.ps1
# Unlocks a locked AD user account and logs the action

param(
    [Parameter(Mandatory=$true)]
    [string]$Username
)

$LogFile = "C:\Scripts\Logs\UnlockLog.txt"
New-Item -Path "C:\Scripts\Logs" -ItemType Directory -Force | Out-Null

# Check if user exists
$User = Get-ADUser -Identity $Username -Properties LockedOut, LastLogonDate

if ($null -eq $User) {
    Write-Host "User $Username not found" -ForegroundColor Red
    exit
}

# Check if actually locked
if ($User.LockedOut) {
    Unlock-ADAccount -Identity $Username
    $Message = "$(Get-Date) - Unlocked account: $Username"
    Write-Host $Message -ForegroundColor Green
    Add-Content -Path $LogFile -Value $Message
} else {
    Write-Host "Account $Username is not locked" -ForegroundColor Yellow
}
