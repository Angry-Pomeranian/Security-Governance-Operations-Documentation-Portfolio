<#
.SYNOPSIS
    Validates that the Browser Extension Control policy is applied and approved extensions are present.

.DESCRIPTION
    Checks registry keys set by the Browser Extension Control – Windows 11 Intune policy.
    Verifies that:
      - Chrome force-installed extensions are registered
      - Edge force-installed extensions are registered
      - Firefox ADMX has been ingested (Windows SSO policy key present)
    Run on any managed device after the policy has been applied and a sync/reboot has completed.

.NOTES
    No admin privileges required for registry reads under HKLM Software\Policies.
    Run from PowerShell 5.1 or later.
#>

#Requires -Version 5.1

Write-Host "`n=== Browser Extension Policy Validation ===" -ForegroundColor Cyan
Write-Host "Device: $env:COMPUTERNAME | $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n" -ForegroundColor Cyan

# Expected extension IDs (Chrome Web Store IDs for approved extensions)
$approvedExtensionIds = @(
    "ddkjiahejlhfcafbddmgiahcphecmpfh"  # uBlock Origin Lite
    "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"  # Privacy Badger
    "jmnpibhfpmpfjhhkmpadlbgjnbhpjgnd"  # Osprey: Browser Protection
    "ihcjicgdanjaechkgeegckofjjedodee"  # Malwarebytes Browser Guard
    "bkdgflcldnnnapblkhphbgpggdiikppg"  # DuckDuckGo Search & Tracker Protection
    "nngceckbapebfimnlniiiahkandclblb"  # Bitwarden Password Manager
)

$results = @()

# --- Chrome ---
Write-Host "[ Chrome ]" -ForegroundColor White
$chromePath = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"
if (Test-Path $chromePath) {
    $chromeValues = (Get-ItemProperty -Path $chromePath).PSObject.Properties |
        Where-Object { $_.Name -match '^\d+$' } |
        ForEach-Object { ($_.Value -split ';')[0] }

    foreach ($id in $approvedExtensionIds) {
        if ($chromeValues -contains $id) {
            Write-Host "  [OK] Extension present: $id" -ForegroundColor Green
            $results += "Chrome:$id:OK"
        } else {
            Write-Host "  [MISSING] Extension not found: $id" -ForegroundColor Yellow
            $results += "Chrome:$id:MISSING"
        }
    }
} else {
    Write-Host "  [WARN] Chrome extension policy key not found — policy may not have applied yet." -ForegroundColor Yellow
    Write-Host "         Expected path: $chromePath" -ForegroundColor Gray
    $results += "Chrome:PolicyKey:MISSING"
}

# --- Edge ---
Write-Host "`n[ Microsoft Edge ]" -ForegroundColor White
$edgePath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist"
if (Test-Path $edgePath) {
    $edgeValues = (Get-ItemProperty -Path $edgePath).PSObject.Properties |
        Where-Object { $_.Name -match '^\d+$' } |
        ForEach-Object { ($_.Value -split ';')[0] }

    foreach ($id in $approvedExtensionIds) {
        if ($edgeValues -contains $id) {
            Write-Host "  [OK] Extension present: $id" -ForegroundColor Green
            $results += "Edge:$id:OK"
        } else {
            Write-Host "  [MISSING] Extension not found: $id" -ForegroundColor Yellow
            $results += "Edge:$id:MISSING"
        }
    }
} else {
    Write-Host "  [WARN] Edge extension policy key not found — policy may not have applied yet." -ForegroundColor Yellow
    Write-Host "         Expected path: $edgePath" -ForegroundColor Gray
    $results += "Edge:PolicyKey:MISSING"
}

# --- Firefox ADMX + SSO ---
Write-Host "`n[ Mozilla Firefox ]" -ForegroundColor White
$firefoxPath = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox"
if (Test-Path $firefoxPath) {
    Write-Host "  [OK] Firefox policy key present (ADMX ingested)" -ForegroundColor Green
    $ssoPath = "$firefoxPath\WindowsSSO"
    # WindowsSSO may be set as a DWORD value or via sub-key depending on ADMX version
    $ffProps = Get-ItemProperty -Path $firefoxPath -ErrorAction SilentlyContinue
    if ($ffProps.WindowsSSO -eq 1 -or (Test-Path $ssoPath)) {
        Write-Host "  [OK] Firefox Windows SSO policy enabled" -ForegroundColor Green
        $results += "Firefox:WindowsSSO:OK"
    } else {
        Write-Host "  [WARN] Firefox Windows SSO value not confirmed — check about:policies in Firefox" -ForegroundColor Yellow
        $results += "Firefox:WindowsSSO:UNCONFIRMED"
    }
} else {
    Write-Host "  [WARN] Firefox policy key not found — ADMX may not have been ingested yet." -ForegroundColor Yellow
    Write-Host "         Expected path: $firefoxPath" -ForegroundColor Gray
    Write-Host "         Note: Firefox ADMX ingestion requires a device reboot to take effect." -ForegroundColor Gray
    $results += "Firefox:PolicyKey:MISSING"
}

# --- Summary ---
$missing = $results | Where-Object { $_ -match ':MISSING$' }
$unconfirmed = $results | Where-Object { $_ -match ':UNCONFIRMED$' }

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
if ($missing.Count -eq 0 -and $unconfirmed.Count -eq 0) {
    Write-Host "[PASS] All browser extension policy checks passed." -ForegroundColor Green
} else {
    if ($missing.Count -gt 0) {
        Write-Host "[ACTION REQUIRED] $($missing.Count) missing item(s):" -ForegroundColor Yellow
        $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    }
    if ($unconfirmed.Count -gt 0) {
        Write-Host "[REVIEW] $($unconfirmed.Count) unconfirmed item(s) — verify manually:" -ForegroundColor Yellow
        $unconfirmed | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    }
    Write-Host "`nVerification steps:" -ForegroundColor Gray
    Write-Host "  Chrome: open chrome://policy and search for ExtensionInstallForcelist" -ForegroundColor Gray
    Write-Host "  Edge:   open edge://policy and search for ExtensionInstallForcelist" -ForegroundColor Gray
    Write-Host "  Firefox: open about:policies and confirm WindowsSSO and extension entries" -ForegroundColor Gray
    Write-Host "  Intune: Devices > Configuration profiles > Browser Extension Control > Device Status" -ForegroundColor Gray
}
