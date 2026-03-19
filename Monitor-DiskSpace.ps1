# Monitor-DiskSpace.ps1
# Monitors disk usage and warns when threshold exceeded

$Threshold = 80  # Alert when disk is 80% full
$LogFile = "C:\Scripts\Logs\DiskSpace.txt"
New-Item -Path "C:\Scripts\Logs" -ItemType Directory -Force | Out-Null

$Disks = Get-PSDrive -PSProvider FileSystem

foreach ($Disk in $Disks) {

    # Skip disks with no size info
    if ($Disk.Used -eq $null -or $Disk.Free -eq $null) { continue }

    $TotalGB = [math]::Round(($Disk.Used + $Disk.Free) / 1GB, 2)
    $UsedGB = [math]::Round($Disk.Used / 1GB, 2)
    $FreeGB = [math]::Round($Disk.Free / 1GB, 2)
    $UsedPercent = [math]::Round(($Disk.Used / ($Disk.Used + $Disk.Free)) * 100, 1)

    $Status = if ($UsedPercent -ge $Threshold) { "WARNING" } else { "OK" }
    $Color = if ($Status -eq "WARNING") { "Red" } else { "Green" }

    $Message = "$(Get-Date) | Drive: $($Disk.Name) | Used: $UsedGB GB / $TotalGB GB ($UsedPercent%) | Status: $Status"
    
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $Message
}

Write-Host "`nResults saved to $LogFile" -ForegroundColor Cyan
