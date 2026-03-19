# Get-UserAuditReport.ps1
# Generates full AD user audit report and exports to CSV

$ReportPath = "C:\Scripts\Logs\UserAuditReport.csv"
New-Item -Path "C:\Scripts\Logs" -ItemType Directory -Force | Out-Null

Write-Host "Generating user audit report..." -ForegroundColor Yellow

Get-ADUser -Filter * -Properties `
    DisplayName, `
    EmailAddress, `
    LastLogonDate, `
    PasswordLastSet, `
    PasswordExpired, `
    Enabled, `
    DistinguishedName |
Select-Object `
    Name, `
    SamAccountName, `
    Enabled, `
    LastLogonDate, `
    PasswordLastSet, `
    PasswordExpired, `
    DistinguishedName |
Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host "Report saved to $ReportPath" -ForegroundColor Green
Write-Host "Total users:" (Get-ADUser -Filter *).Count -ForegroundColor Cyan
