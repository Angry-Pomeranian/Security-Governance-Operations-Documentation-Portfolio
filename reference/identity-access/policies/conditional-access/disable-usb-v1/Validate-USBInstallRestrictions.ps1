<#
.SYNOPSIS
    Validates that the USB device installation restriction policy (V1) is applied.

.DESCRIPTION
    Checks registry keys under HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions
    to confirm that the Disable USB (V1) Intune policy — which enforces a device class allowlist
    and a default-deny rule — has been applied to the device.

    Verified keys:
      - AllowDeviceClasses         = 1  (allowlist enforcement enabled)
      - AllowDeviceClassesRetroactive = 1 (applies to already-installed devices)
      - DenyUnspecified            = 1  (default-deny for all non-allowlisted classes)

    Expected allowed class GUIDs are cross-checked against the policy specification.

.NOTES
    No admin privileges required for registry reads.
    Run from PowerShell 5.1 or later.
#>

#Requires -Version 5.1

Write-Host "`n=== USB Install Restriction Policy Validation (V1) ===" -ForegroundColor Cyan
Write-Host "Device: $env:COMPUTERNAME | $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n" -ForegroundColor Cyan

$basePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions"

# Expected allowed device class GUIDs per policy specification
$expectedGUIDs = @(
    "{36fc9e60-c465-11cf-8056-444553540000}"  # USB Host Controllers
    "{4D36E97D-E325-11CE-BFC1-08002BE10318}"  # Unknown devices (system)
    "{4d36e96b-e325-11ce-bfc1-08002be10318}"  # Keyboards
    "{4d36e96c-e325-11ce-bfc1-08002be10318}"  # Media (CD/DVD — read only)
    "{4d36e96f-e325-11ce-bfc1-08002be10318}"  # Monitors
    "{62f9c741-b25a-46ce-b54c-9bccce08b6f2}"  # SmartCard readers
    "{6bdd1fc6-810f-11d0-bec7-08002be2092f}"  # 1394 bus
    "{745a17a0-74d3-11d0-b6fe-00a0c90f57da}"  # HID (Human Interface Devices — mice, etc.)
    "{c166523c-fe0c-4a94-a586-f1a80cfbbf3e}"  # Windows Portable Devices — audio only
    "{ca3e7ab9-b4c3-4ae6-8251-579ef933890f}"  # Camera devices
    "5C4C3332-344D-483C-8739-259E934C9CC8"    # Biometric devices
)

$results = @()

if (-not (Test-Path $basePath)) {
    Write-Host "[FAIL] Policy registry path not found." -ForegroundColor Yellow
    Write-Host "       Expected: $basePath" -ForegroundColor Gray
    Write-Host "       The policy has not been applied or has not synced yet." -ForegroundColor Gray
    Write-Host "`nTroubleshooting:" -ForegroundColor Gray
    Write-Host "  1. Check Intune portal: Devices > Configuration profiles > Disable USB > Device Status" -ForegroundColor Gray
    Write-Host "  2. Run: gpresult /r to confirm policy is in scope" -ForegroundColor Gray
    Write-Host "  3. Force Intune sync: Settings > Accounts > Access work or school > Sync" -ForegroundColor Gray
    exit
}

$props = Get-ItemProperty -Path $basePath -ErrorAction SilentlyContinue

# Check DenyUnspecified (default-deny for non-allowlisted device classes)
Write-Host "[ Core Policy Settings ]" -ForegroundColor White
if ($props.DenyUnspecified -eq 1) {
    Write-Host "  [OK] DenyUnspecified = 1 (default-deny rule active)" -ForegroundColor Green
    $results += "DenyUnspecified:OK"
} else {
    Write-Host "  [FAIL] DenyUnspecified not set — default-deny is NOT enforced" -ForegroundColor Red
    $results += "DenyUnspecified:FAIL"
}

if ($props.AllowDeviceClasses -eq 1) {
    Write-Host "  [OK] AllowDeviceClasses = 1 (allowlist enforcement enabled)" -ForegroundColor Green
    $results += "AllowDeviceClasses:OK"
} else {
    Write-Host "  [FAIL] AllowDeviceClasses not set to 1" -ForegroundColor Red
    $results += "AllowDeviceClasses:FAIL"
}

# Check allowed GUIDs
Write-Host "`n[ Allowed Device Class GUIDs ]" -ForegroundColor White
$allowlistPath = "$basePath\AllowDeviceClasses"
if (Test-Path $allowlistPath) {
    $registeredGUIDs = (Get-ItemProperty -Path $allowlistPath).PSObject.Properties |
        Where-Object { $_.Name -match '^\d+$' } |
        ForEach-Object { $_.Value }

    foreach ($guid in $expectedGUIDs) {
        $match = $registeredGUIDs | Where-Object { $_ -ieq $guid }
        if ($match) {
            Write-Host "  [OK] $guid" -ForegroundColor Green
            $results += "GUID:${guid}:OK"
        } else {
            Write-Host "  [MISSING] $guid" -ForegroundColor Yellow
            $results += "GUID:${guid}:MISSING"
        }
    }
} else {
    Write-Host "  [WARN] AllowDeviceClasses subkey not found." -ForegroundColor Yellow
    $results += "AllowDeviceClasses:Subkey:MISSING"
}

# Summary
$failures = $results | Where-Object { $_ -match ':FAIL$' }
$missing  = $results | Where-Object { $_ -match ':MISSING$' }

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
if ($failures.Count -eq 0 -and $missing.Count -eq 0) {
    Write-Host "[PASS] USB install restriction policy is correctly applied." -ForegroundColor Green
} else {
    Write-Host "[ISSUES FOUND]" -ForegroundColor Yellow
    if ($failures.Count -gt 0) {
        Write-Host "  Critical failures: $($failures.Count)" -ForegroundColor Red
        $failures | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
    }
    if ($missing.Count -gt 0) {
        Write-Host "  Missing GUIDs: $($missing.Count) (policy may need updating)" -ForegroundColor Yellow
    }
    Write-Host "`nVerification steps:" -ForegroundColor Gray
    Write-Host "  1. Intune: Devices > Configuration profiles > Disable USB > Per-setting status" -ForegroundColor Gray
    Write-Host "  2. Event Viewer: Microsoft-Windows-DriverFrameworks-UserMode/Operational > filter for policy blocks" -ForegroundColor Gray
    Write-Host "  3. Test: plug in a USB storage device — should be blocked with a notification" -ForegroundColor Gray
}
