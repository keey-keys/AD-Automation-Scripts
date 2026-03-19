# AD Automation Scripts

A collection of PowerShell scripts for Active Directory administration 
and Windows Server system management, built as part of a home lab 
simulating a K-12 school district IT environment.

## Lab Environment
- Windows Server 2022 (Domain Controller)
- Active Directory Domain Services
- DNS & DHCP Server Roles
- Simulated OU structure (Staff, Teachers, Students)
- Virtualized using UTM on macOS

## Scripts

### Find-InactiveAccounts.ps1
Queries Active Directory for enabled user accounts with no login 
activity in 90+ days. Outputs results to the console and saves 
a timestamped log file for admin review and cleanup.

**Use case:** End of school year account audits, offboarding cleanup

---

### Unlock-UserAccount.ps1
Accepts a username as a parameter, checks if the account is locked, 
unlocks it, and logs the action with a timestamp for compliance 
and audit trail purposes.

**Use case:** Daily helpdesk support, reduces time to resolution for 
locked account tickets

**Usage:**
```powershell
.\Unlock-UserAccount.ps1 -Username "jsmith"
```

---

### Monitor-DiskSpace.ps1
Scans all drives on the server and calculates usage percentage. 
Triggers a warning when any drive exceeds 80% capacity. 
All results are logged with timestamps for capacity planning.

**Use case:** Proactive server health monitoring, storage capacity planning

---

### Get-UserAuditReport.ps1
Generates a full CSV report of all Active Directory users including 
last login date, password status, account state, and OU location. 
Used for security audits and compliance reviews.

**Use case:** Monthly security audits, compliance reporting, 
identifying stale or misconfigured accounts

---

## Skills Demonstrated
- PowerShell scripting and task automation
- Active Directory user and account management
- System health monitoring and threshold alerting
- Audit trail logging for compliance
- Modular, reusable script design
- Parameter-based script inputs

## Related Projects
- [Server Maintenance Toolkit]((https://github.com/keey-keys/server-maintenance-toolkit)) — Bash-based 
Linux server maintenance automation including backups, 
disk monitoring, and log cleanup

## Author - Okikijesu Ogunyemi
Built as part of an ongoing home lab and IT portfolio while working 
as an IT Specialist and studying for Systems Administrator roles.
