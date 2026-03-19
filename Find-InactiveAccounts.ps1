# Find-InactiveAccounts.ps1
# Finds AD accounts inactive for 90+ days

$DaysInactive = 90
$CutoffDate = (Get-Date).AddDays(-$DaysInactive)
$LogFile = "C:\Scripts\Logs\InactiveAccounts.txt"

# Create log directory if it doesn't exist
New-Item -Path "C:\Scripts\Logs" -ItemType Directory -Force | Out-Null

Write-Host "Searching for accounts inactive since $CutoffDate" -ForegroundColor Yellow

$InactiveUsers = Get-ADUser -Filter {
    LastLogonDate -lt $CutoffDate -and Enabled -eq $true
} -Properties LastLogonDate, EmailAddress |
Select-Object Name, SamAccountName, LastLogonDate, Enabled

# Display results
$InactiveUsers | Format-Table -AutoSize

# Log results
$InactiveUsers | Out-File -FilePath $LogFile

Write-Host "Found $($InactiveUsers.Count) inactive accounts" -ForegroundColor Red
Write-Host "Results saved to $LogFile" -ForegroundColor Green
