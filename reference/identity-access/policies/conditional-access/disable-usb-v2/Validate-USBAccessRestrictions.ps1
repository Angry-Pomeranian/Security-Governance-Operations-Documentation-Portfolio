<#
.SYNOPSIS
    Validates that the USB removable storage access restriction policy (V2) is applied.

.DESCRIPTION
    Checks registry keys under HKLM\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices
    to confirm that the Disable USB (V2) Intune policy — which denies read/write access to all
    removable storage and Windows Portable Device (WPD) classes — has been applied.

    Verified settings:
      - Generic removable storage (GUID {53f5630d-...}): Deny_Read, Deny_Write
      - WPD devices (GUID {6AC27878-...}):               Deny_Read, Deny_Write
      - All removable storage classes (default key):     Deny_All

.NOTES
    No admin privileges required for registry reads.
    Run from PowerShell 5.1 or later.
#>

#Requires -Version 5.1

Write-Host "`n=== USB Access Restriction Policy Validation (V2) ===" -ForegroundColor Cyan
Write-Host "Device: $env:COMPUTERNAME | $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n" -ForegroundColor Cyan

$basePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices"

# Device class GUIDs per policy specification
$removableStorageGUID = "{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}"  # Generic removable storage
$wpdGUID              = "{6AC27878-A6FA-4155-BA85-F98F491D4F33}"   # Windows Portable Devices

$results = @()

if (-not (Test-Path $basePath)) {
    Write-Host "[FAIL] Policy registry path not found." -ForegroundColor Yellow
    Write-Host "       Expected: $basePath" -ForegroundColor Gray
    Write-Host "       The policy has not been applied or has not synced yet." -ForegroundColor Gray
    Write-Host "`nTroubleshooting:" -ForegroundColor Gray
    Write-Host "  1. Check Intune portal: Devices > Configuration profiles > Disable USB (V2) > Device Status" -ForegroundColor Gray
    Write-Host "  2. Run: gpresult /r to confirm policy is in scope for this device/user" -ForegroundColor Gray
    Write-Host "  3. Force Intune sync: Settings > Accounts > Access work or school > Sync" -ForegroundColor Gray
    exit
}

function Test-StorageRestriction {
    param(
        [string]$GuidPath,
        [string]$Label
    )
    $fullPath = Join-Path $basePath $GuidPath
    Write-Host "[ $Label ]" -ForegroundColor White
    Write-Host "  Path: $fullPath" -ForegroundColor Gray

    if (-not (Test-Path $fullPath)) {
        Write-Host "  [WARN] Key not found — class-specific restriction may not be set" -ForegroundColor Yellow
        return "MISSING"
    }

    $keyProps = Get-ItemProperty -Path $fullPath -ErrorAction SilentlyContinue
    $denyRead  = $keyProps.Deny_Read
    $denyWrite = $keyProps.Deny_Write
    $status = "OK"

    if ($denyRead -eq 1) {
        Write-Host "  [OK] Deny_Read  = 1" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Deny_Read not set to 1 (value: $denyRead)" -ForegroundColor Red
        $status = "FAIL"
    }

    if ($denyWrite -eq 1) {
        Write-Host "  [OK] Deny_Write = 1" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Deny_Write not set to 1 (value: $denyWrite)" -ForegroundColor Red
        $status = "FAIL"
    }

    return $status
}

# Check generic removable storage
$r1 = Test-StorageRestriction -GuidPath $removableStorageGUID -Label "Generic Removable Storage ($removableStorageGUID)"
$results += "RemovableStorage:$r1"

Write-Host ""

# Check WPD (Windows Portable Devices)
$r2 = Test-StorageRestriction -GuidPath $wpdGUID -Label "Windows Portable Devices ($wpdGUID)"
$results += "WPD:$r2"

# Check top-level Deny_All (set by "All Removable Storage classes: Deny all access" policy)
Write-Host "`n[ All Removable Storage — Default Deny ]" -ForegroundColor White
$baseProps = Get-ItemProperty -Path $basePath -ErrorAction SilentlyContinue
if ($baseProps.Deny_All -eq 1) {
    Write-Host "  [OK] Deny_All = 1 (all removable storage classes blocked)" -ForegroundColor Green
    $results += "DenyAll:OK"
} else {
    Write-Host "  [INFO] Deny_All not set at root key — class-specific restrictions are in effect" -ForegroundColor Gray
    $results += "DenyAll:NOT_SET"
}

# Summary
$failures = $results | Where-Object { $_ -match ':FAIL$' }
$missing  = $results | Where-Object { $_ -match ':MISSING$' }

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
if ($failures.Count -eq 0 -and $missing.Count -eq 0) {
    Write-Host "[PASS] USB removable storage access restriction policy is correctly applied." -ForegroundColor Green
} else {
    if ($failures.Count -gt 0) {
        Write-Host "[FAIL] $($failures.Count) restriction(s) not enforced:" -ForegroundColor Red
        $failures | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    }
    if ($missing.Count -gt 0) {
        Write-Host "[WARN] $($missing.Count) class-specific key(s) not found:" -ForegroundColor Yellow
        $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    }
    Write-Host "`nVerification steps:" -ForegroundColor Gray
    Write-Host "  1. Intune: Devices > Configuration profiles > Disable USB (V2) > Per-setting status" -ForegroundColor Gray
    Write-Host "  2. Test: connect a USB drive — file explorer should not show the drive" -ForegroundColor Gray
    Write-Host "  3. Run gpresult /h gpresult.html to see all applied policies" -ForegroundColor Gray
    Write-Host "  4. Check USB exclusion group membership for exceptions" -ForegroundColor Gray
}
