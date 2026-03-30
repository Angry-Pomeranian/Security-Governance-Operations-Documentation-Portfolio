<#
.SYNOPSIS
    Validates that the CIS Edge L1/L2 hardening policy is applied to this device.

.DESCRIPTION
    Checks registry keys under HKLM\SOFTWARE\Policies\Microsoft\Edge to confirm
    that the Edge CIS Level 1 and Level 2 Intune policy controls have been applied.

    Verified settings:
      - PasswordManagerEnabled       = 0  (password manager disabled)
      - SyncDisabled                 = 1  (browser sync blocked)
      - PasswordRevealEnabled        = 0  (password reveal button disabled)
      - SmartScreenEnabled           = 1  (Microsoft Defender SmartScreen active)
      - InPrivateModeAvailability    = 1  (InPrivate mode restricted to admin use)
      - ExtensionInstallBlocklist    contains * (default-deny for extensions)

    For full policy verification, use edge://policy in the browser.

.NOTES
    No admin privileges required for registry reads.
    Run from PowerShell 5.1 or later.
#>

#Requires -Version 5.1

Write-Host "`n=== Edge CIS L1/L2 Policy Validation ===" -ForegroundColor Cyan
Write-Host "Device: $env:COMPUTERNAME | $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n" -ForegroundColor Cyan

$edgePath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"

if (-not (Test-Path $edgePath)) {
    Write-Host "[FAIL] Edge policy registry key not found." -ForegroundColor Yellow
    Write-Host "       Expected: $edgePath" -ForegroundColor Gray
    Write-Host "       Policy has not been applied or the device has not synced." -ForegroundColor Gray
    Write-Host "`nTroubleshooting:" -ForegroundColor Gray
    Write-Host "  1. Intune portal: Devices > Configuration profiles > Edge CIS L1 and L2 > Device Status" -ForegroundColor Gray
    Write-Host "  2. Force sync: Settings > Accounts > Access work or school > Sync" -ForegroundColor Gray
    Write-Host "  3. Verify Edge is installed and up to date" -ForegroundColor Gray
    exit
}

$props = Get-ItemProperty -Path $edgePath -ErrorAction SilentlyContinue
$results = @()

function Test-PolicyValue {
    param(
        [string]$SettingName,
        [object]$ActualValue,
        [object]$ExpectedValue,
        [string]$Description
    )
    if ($null -eq $ActualValue) {
        Write-Host "  [WARN] $SettingName not set (expected: $ExpectedValue) — $Description" -ForegroundColor Yellow
        return "MISSING"
    } elseif ($ActualValue -eq $ExpectedValue) {
        Write-Host "  [OK]   $SettingName = $ActualValue — $Description" -ForegroundColor Green
        return "OK"
    } else {
        Write-Host "  [FAIL] $SettingName = $ActualValue (expected: $ExpectedValue) — $Description" -ForegroundColor Red
        return "FAIL"
    }
}

# --- Credential and password controls ---
Write-Host "[ Credential and Password Controls ]" -ForegroundColor White
$results += "PasswordManager:" + (Test-PolicyValue "PasswordManagerEnabled" $props.PasswordManagerEnabled 0 "Built-in password manager disabled")
$results += "PasswordReveal:"  + (Test-PolicyValue "PasswordRevealEnabled"   $props.PasswordRevealEnabled   0 "Password reveal button hidden")
$results += "AutofillAddress:" + (Test-PolicyValue "AutofillAddressEnabled"  $props.AutofillAddressEnabled  0 "Autofill for addresses disabled")

# --- Sync and data protection ---
Write-Host "`n[ Sync and Data Protection ]" -ForegroundColor White
$results += "SyncDisabled:"  + (Test-PolicyValue "SyncDisabled"  $props.SyncDisabled  1 "Browser sync blocked")
$results += "ImportPasswords:" + (Test-PolicyValue "ImportPasswordsEnabled" $props.ImportPasswordsEnabled 0 "Password import disabled")

# --- Security controls ---
Write-Host "`n[ Security Controls ]" -ForegroundColor White
$results += "SmartScreen:" + (Test-PolicyValue "SmartScreenEnabled"        $props.SmartScreenEnabled        1 "Microsoft Defender SmartScreen active")
$results += "SmartScreenPhishing:" + (Test-PolicyValue "SmartScreenPuaEnabled" $props.SmartScreenPuaEnabled 1 "SmartScreen for PUA/adware active")
$results += "SitePerProcess:" + (Test-PolicyValue "SitePerProcess"          $props.SitePerProcess            1 "Site isolation per process enabled")

# --- Profile and session controls ---
Write-Host "`n[ Profile and Session Controls ]" -ForegroundColor White
$results += "GuestMode:"    + (Test-PolicyValue "GuestModeEnabled"     $props.GuestModeEnabled     0 "Guest mode disabled")
$results += "InPrivate:"    + (Test-PolicyValue "InPrivateModeAvailability" $props.InPrivateModeAvailability 1 "InPrivate mode restricted")

# --- Extension management ---
Write-Host "`n[ Extension Management ]" -ForegroundColor White
$blocklistPath = "$edgePath\ExtensionInstallBlocklist"
if (Test-Path $blocklistPath) {
    $blocklistValues = (Get-ItemProperty -Path $blocklistPath).PSObject.Properties |
        Where-Object { $_.Name -match '^\d+$' } |
        ForEach-Object { $_.Value }

    if ($blocklistValues -contains '*') {
        Write-Host "  [OK]   ExtensionInstallBlocklist contains '*' (default-deny all extensions)" -ForegroundColor Green
        $results += "ExtensionBlocklist:OK"
    } else {
        Write-Host "  [WARN] ExtensionInstallBlocklist present but does not contain '*'" -ForegroundColor Yellow
        $results += "ExtensionBlocklist:PARTIAL"
    }
} else {
    Write-Host "  [WARN] ExtensionInstallBlocklist key not found — extensions may not be restricted" -ForegroundColor Yellow
    $results += "ExtensionBlocklist:MISSING"
}

# --- Summary ---
$failures = $results | Where-Object { $_ -match ':FAIL$' }
$missing  = $results | Where-Object { $_ -match ':MISSING$|:PARTIAL$' }

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
if ($failures.Count -eq 0 -and $missing.Count -eq 0) {
    Write-Host "[PASS] Edge CIS L1/L2 policy is correctly applied." -ForegroundColor Green
} else {
    if ($failures.Count -gt 0) {
        Write-Host "[FAIL] $($failures.Count) setting(s) have incorrect values:" -ForegroundColor Red
        $failures | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    }
    if ($missing.Count -gt 0) {
        Write-Host "[WARN] $($missing.Count) setting(s) missing or incomplete:" -ForegroundColor Yellow
        $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    }
    Write-Host "`nFull policy verification: open edge://policy in Edge and review all entries." -ForegroundColor Gray
    Write-Host "Intune: Devices > Configuration profiles > Edge CIS L1 and L2 > Per-setting status" -ForegroundColor Gray
}
