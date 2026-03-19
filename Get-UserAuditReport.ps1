#Requires -Modules ActiveDirectory
#Requires -Version 5.1

<#
.SYNOPSIS
    Generates a full Active Directory user audit report as a CSV.

.DESCRIPTION
    Exports all AD users with key attributes including last login date (using the
    replicated LastLogonTimestamp), password status, account state, and OU location.
    Used for security audits and compliance reviews.

.PARAMETER ReportPath
    Directory path where the CSV report will be saved. Default is C:\Scripts\Logs.

.EXAMPLE
    .\Get-UserAuditReport.ps1
    .\Get-UserAuditReport.ps1 -ReportPath "D:\Reports"
#>

param(
    [string]$ReportPath = "C:\Scripts\Logs"
)

$Timestamp = Get-Date -Format 'yyyy-MM-dd'
$CsvFile = Join-Path $ReportPath "UserAuditReport_$Timestamp.csv"

# Create report directory if it doesn't exist
New-Item -Path $ReportPath -ItemType Directory -Force | Out-Null

Write-Host "Generating user audit report..." -ForegroundColor Yellow

try {
    $Users = Get-ADUser -Filter * -Properties `
        DisplayName,
        EmailAddress,
        LastLogonTimestamp,
        PasswordLastSet,
        PasswordExpired,
        PasswordNeverExpires,
        Enabled,
        DistinguishedName -ErrorAction Stop

    $Report = $Users | Select-Object `
        Name,
        SamAccountName,
        DisplayName,
        EmailAddress,
        Enabled,
        # Use LastLogonTimestamp (replicated) instead of LastLogonDate (DC-local only)
        @{Name = "LastLogon"; Expression = {
            if ($_.LastLogonTimestamp) {
                [datetime]::FromFileTime($_.LastLogonTimestamp).ToString('yyyy-MM-dd HH:mm:ss')
            } else {
                "Never"
            }
        }},
        PasswordLastSet,
        PasswordExpired,
        PasswordNeverExpires,
        DistinguishedName

    $Report | Export-Csv -Path $CsvFile -NoTypeInformation

    Write-Host "Report saved to $CsvFile" -ForegroundColor Green
    Write-Host "Total users exported: $($Report.Count)" -ForegroundColor Cyan

} catch {
    Write-Host "ERROR: Failed to generate audit report. $_" -ForegroundColor Red
    exit 1
}
