<#
.SYNOPSIS
    Validates the Microsoft Authenticator Authentication Methods policy in Entra ID.

.DESCRIPTION
    Connects to Microsoft Graph and retrieves the Microsoft Authenticator policy configuration.
    Verifies that number matching is enabled, contextual push information is configured,
    and the policy state is active. Outputs colour-coded results for each check.

.REQUIREMENTS
    - Microsoft.Graph PowerShell module (Install-Module Microsoft.Graph)
    - Policy.Read.All permission (delegated or application)
    - Authentication Administrator or Global Administrator role

.NOTES
    Run in a PowerShell session with appropriate Entra ID permissions.
#>

#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Identity.SignIns

$ErrorActionPreference = "Stop"

# ── Connect ───────────────────────────────────────────────────────────────────
Write-Host "`n=== Microsoft Authenticator Authentication Methods Policy Validation ===" -ForegroundColor Cyan
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan

try {
    Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome
} catch {
    Write-Host "ERROR: Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
    exit 1
}

# ── Retrieve Authenticator policy ─────────────────────────────────────────────
Write-Host "`nRetrieving Microsoft Authenticator policy..." -ForegroundColor Cyan

try {
    $authPolicy = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
        -AuthenticationMethodConfigurationId "MicrosoftAuthenticator"
} catch {
    Write-Host "ERROR: Failed to retrieve Authenticator policy: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

$props = $authPolicy.AdditionalProperties

# ── Check 1: Policy state ─────────────────────────────────────────────────────
if ($authPolicy.State -eq "enabled") {
    Write-Host "[PASS] Authenticator policy state: enabled" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Authenticator policy state: $($authPolicy.State) (expected: enabled)" -ForegroundColor Red
}

# ── Check 2: Feature settings ─────────────────────────────────────────────────
$featureSettings = $props["featureSettings"]

if ($null -ne $featureSettings) {
    # Number matching
    $numberMatchState = $featureSettings["numberMatchingRequiredState"]
    $nmEnabled = $null -ne $numberMatchState -and $numberMatchState["state"] -eq "enabled"
    if ($nmEnabled) {
        Write-Host "[PASS] Number matching: enabled" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Number matching: not enabled (required — prevents MFA fatigue attacks)" -ForegroundColor Red
    }

    # Display app information
    $displayAppState = $featureSettings["displayAppInformationRequiredState"]
    $appInfoEnabled = $null -ne $displayAppState -and $displayAppState["state"] -eq "enabled"
    if ($appInfoEnabled) {
        Write-Host "[PASS] Show application name in push: enabled" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Show application name in push: not enabled (recommended for context)" -ForegroundColor Yellow
    }

    # Display location information
    $displayLocationState = $featureSettings["displayLocationInformationRequiredState"]
    $locationEnabled = $null -ne $displayLocationState -and $displayLocationState["state"] -eq "enabled"
    if ($locationEnabled) {
        Write-Host "[PASS] Show geographic location in push: enabled" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Show geographic location in push: not enabled (recommended for context)" -ForegroundColor Yellow
    }
} else {
    Write-Host "[WARN] Feature settings not found — number matching and context may not be configured" -ForegroundColor Yellow
}

# ── Check 3: Included targets ─────────────────────────────────────────────────
$includedTargets = $authPolicy.IncludeTargets
if ($includedTargets -and $includedTargets.Count -gt 0) {
    Write-Host "[PASS] Included targets configured: $($includedTargets.Count) group(s)/All users" -ForegroundColor Green
    foreach ($target in $includedTargets) {
        $mode = $target.AdditionalProperties["authenticationMode"]
        Write-Host "       Target: $($target.Id) | Mode: $mode" -ForegroundColor Cyan
    }
} else {
    Write-Host "[WARN] No included targets — policy may not be scoped to any users" -ForegroundColor Yellow
}

# ── Check 4: Excluded targets ─────────────────────────────────────────────────
$excludedTargets = $authPolicy.ExcludeTargets
if ($excludedTargets -and $excludedTargets.Count -gt 0) {
    Write-Host "[PASS] Excluded targets configured: $($excludedTargets.Count) group(s)" -ForegroundColor Green
} else {
    Write-Host "[WARN] No excluded targets. Break-glass and service accounts should be excluded." -ForegroundColor Yellow
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Validation Complete ===" -ForegroundColor Cyan
Write-Host "Review any WARN/FAIL items above against the Authenticator policy documentation." -ForegroundColor Cyan
Write-Host "Portal path: Entra ID > Protection > Authentication methods > Microsoft Authenticator" -ForegroundColor Cyan

Disconnect-MgGraph | Out-Null
