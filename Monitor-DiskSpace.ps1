#Requires -Version 5.1

<#
.SYNOPSIS
    Monitors disk space usage and alerts when a threshold is exceeded.

.DESCRIPTION
    Scans all local drives on the server and calculates usage percentage.
    Logs a warning when any drive exceeds the specified threshold.
    All results are timestamped for capacity planning and trend analysis.

.PARAMETER Threshold
    Percentage of disk usage that triggers a WARNING. Default is 80.

.PARAMETER LogPath
    Directory path where the log file will be saved. Default is C:\Scripts\Logs.

.EXAMPLE
    .\Monitor-DiskSpace.ps1
    .\Monitor-DiskSpace.ps1 -Threshold 75 -LogPath "D:\Logs"
#>

param(
    [int]$Threshold = 80,
    [string]$LogPath = "C:\Scripts\Logs"
)

$LogFile = Join-Path $LogPath "DiskSpace_$(Get-Date -Format 'yyyy-MM-dd').txt"

# Create log directory if it doesn't exist
New-Item -Path $LogPath -ItemType Directory -Force | Out-Null

Write-Host "Checking disk space (warning threshold: $Threshold%)..." -ForegroundColor Yellow

try {
    $Disks = Get-PSDrive -PSProvider FileSystem -ErrorAction Stop

    foreach ($Disk in $Disks) {
        # Skip disks with no size info (e.g. mapped network drives with no stats)
        if ($null -eq $Disk.Used -or $null -eq $Disk.Free) { continue }

        $TotalGB    = [math]::Round(($Disk.Used + $Disk.Free) / 1GB, 2)
        $UsedGB     = [math]::Round($Disk.Used / 1GB, 2)
        $FreeGB     = [math]::Round($Disk.Free / 1GB, 2)
        $UsedPercent = [math]::Round(($Disk.Used / ($Disk.Used + $Disk.Free)) * 100, 1)

        $Status = if ($UsedPercent -ge $Threshold) { "WARNING" } else { "OK" }
        $Color  = if ($Status -eq "WARNING") { "Red" } else { "Green" }

        $Message = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | Drive: $($Disk.Name) | " +
                   "Used: $UsedGB GB / $TotalGB GB ($UsedPercent%) | Free: $FreeGB GB | Status: $Status"

        Write-Host $Message -ForegroundColor $Color
        Add-Content -Path $LogFile -Value $Message
    }

    Write-Host "`nResults saved to $LogFile" -ForegroundColor Cyan

} catch {
    Write-Host "ERROR: Failed to retrieve disk information. $_" -ForegroundColor Red
    "$(Get-Date) - ERROR: $_" | Out-File -FilePath $LogFile -Append
    exit 1
}
