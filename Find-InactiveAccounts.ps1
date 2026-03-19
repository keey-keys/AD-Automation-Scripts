#Requires -Modules ActiveDirectory
#Requires -Version 5.1

<#
.SYNOPSIS
    Finds AD user accounts inactive for 90+ days.

.DESCRIPTION
    Queries Active Directory for enabled user accounts where LastLogonTimestamp
    indicates no login activity within the specified threshold. Uses the replicated
    LastLogonTimestamp attribute for accuracy across all domain controllers.
    Outputs results to console and saves a timestamped log file.

.PARAMETER DaysInactive
    Number of days of inactivity before an account is flagged. Default is 90.

.PARAMETER LogPath
    Directory path where the log file will be saved. Default is C:\Scripts\Logs.

.EXAMPLE
    .\Find-InactiveAccounts.ps1
    .\Find-InactiveAccounts.ps1 -DaysInactive 60 -LogPath "D:\Logs"
#>

param(
    [int]$DaysInactive = 90,
    [string]$LogPath = "C:\Scripts\Logs"
)

$LogFile = Join-Path $LogPath "InactiveAccounts_$(Get-Date -Format 'yyyy-MM-dd').txt"

# Create log directory if it doesn't exist
New-Item -Path $LogPath -ItemType Directory -Force | Out-Null

# Calculate cutoff using LastLogonTimestamp (replicates across all DCs)
# LastLogonDate is NOT replicated — do not use it for accurate results in multi-DC environments
$CutoffDate = (Get-Date).AddDays(-$DaysInactive)
$CutoffFileTime = $CutoffDate.ToFileTime()

Write-Host "Searching for accounts inactive since $CutoffDate..." -ForegroundColor Yellow

try {
    $InactiveUsers = Get-ADUser -Filter {
        Enabled -eq $true -and LastLogonTimestamp -lt $CutoffFileTime
    } -Properties LastLogonTimestamp, EmailAddress |
    Select-Object Name, SamAccountName, EmailAddress,
        @{Name = "LastLogon"; Expression = {
            if ($_.LastLogonTimestamp) {
                [datetime]::FromFileTime($_.LastLogonTimestamp)
            } else {
                "Never"
            }
        }},
        Enabled

    # Display results
    $InactiveUsers | Format-Table -AutoSize

    # Log results
    $Header = "Inactive Accounts Report - $(Get-Date) | Threshold: $DaysInactive days"
    $Header | Out-File -FilePath $LogFile
    $InactiveUsers | Out-File -FilePath $LogFile -Append

    Write-Host "Found $($InactiveUsers.Count) inactive accounts." -ForegroundColor Red
    Write-Host "Results saved to $LogFile" -ForegroundColor Green

} catch {
    Write-Host "ERROR: Failed to query Active Directory. $_" -ForegroundColor Red
    "$(Get-Date) - ERROR: $_" | Out-File -FilePath $LogFile -Append
    exit 1
}
