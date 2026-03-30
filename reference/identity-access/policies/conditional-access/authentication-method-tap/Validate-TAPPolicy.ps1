<#
.SYNOPSIS
    Validates the Temporary Access Pass (TAP) Authentication Methods policy in Entra ID.

.DESCRIPTION
    Connects to Microsoft Graph and retrieves the TAP Authentication Methods policy configuration.
    Checks that TAP is enabled, one-time use is enforced, and lifetime settings are within
    expected ranges. Outputs colour-coded results for each check.

.REQUIREMENTS
    - Microsoft.Graph PowerShell module (Install-Module Microsoft.Graph)
    - Policy.Read.All permission (delegated or application)
    - Authentication Administrator or Global Administrator role

.NOTES
    Run in a PowerShell session with appropriate Entra ID permissions.
#>

#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Identity.SignIns

$ErrorActionPreference = "Stop"

# ── Expected values ───────────────────────────────────────────────────────────
$ExpectedState          = "enabled"
$ExpectedOneTimeUse     = $true
$MaxAllowedLifetime     = 480   # minutes — upper bound from policy
$MinAllowedLifetime     = 10    # minutes — lower bound from policy
$ExpectedDefaultLifetime = 60   # minutes

# ── Connect ───────────────────────────────────────────────────────────────────
Write-Host "`n=== TAP Authentication Methods Policy Validation ===" -ForegroundColor Cyan
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan

try {
    Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome
} catch {
    Write-Host "ERROR: Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
    exit 1
}

# ── Retrieve TAP policy ───────────────────────────────────────────────────────
Write-Host "`nRetrieving TAP Authentication Methods policy..." -ForegroundColor Cyan

try {
    $tapPolicy = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
        -AuthenticationMethodConfigurationId "TemporaryAccessPass"
} catch {
    Write-Host "ERROR: Failed to retrieve TAP policy. Ensure Policy.Read.All scope is granted: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ── Check 1: Policy state ─────────────────────────────────────────────────────
$state = $tapPolicy.State
if ($state -eq $ExpectedState) {
    Write-Host "[PASS] TAP policy state: $state" -ForegroundColor Green
} else {
    Write-Host "[FAIL] TAP policy state: $state (expected: $ExpectedState)" -ForegroundColor Red
}

# ── Check 2: One-time use ─────────────────────────────────────────────────────
$additionalProperties = $tapPolicy.AdditionalProperties
$isUsableOnce = $additionalProperties["isUsableOnce"]

if ($isUsableOnce -eq $ExpectedOneTimeUse) {
    Write-Host "[PASS] One-time use: $isUsableOnce" -ForegroundColor Green
} else {
    Write-Host "[WARN] One-time use: $isUsableOnce (expected: $ExpectedOneTimeUse)" -ForegroundColor Yellow
    Write-Host "       TAP should be configured as one-time use to prevent replay attacks." -ForegroundColor Yellow
}

# ── Check 3: Default lifetime ─────────────────────────────────────────────────
$defaultLifetime = $additionalProperties["defaultLifetimeInMinutes"]
if ($null -ne $defaultLifetime) {
    if ($defaultLifetime -le 60) {
        Write-Host "[PASS] Default lifetime: $defaultLifetime minutes" -ForegroundColor Green
    } elseif ($defaultLifetime -le 120) {
        Write-Host "[WARN] Default lifetime: $defaultLifetime minutes (recommended: ≤60)" -ForegroundColor Yellow
    } else {
        Write-Host "[FAIL] Default lifetime: $defaultLifetime minutes (expected: ≤60)" -ForegroundColor Red
    }
} else {
    Write-Host "[WARN] Default lifetime: not set (will use Entra default)" -ForegroundColor Yellow
}

# ── Check 4: Minimum lifetime ─────────────────────────────────────────────────
$minimumLifetime = $additionalProperties["minimumLifetimeInMinutes"]
if ($null -ne $minimumLifetime) {
    if ($minimumLifetime -ge $MinAllowedLifetime) {
        Write-Host "[PASS] Minimum lifetime: $minimumLifetime minutes" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Minimum lifetime: $minimumLifetime minutes (policy floor: $MinAllowedLifetime)" -ForegroundColor Yellow
    }
}

# ── Check 5: Maximum lifetime ─────────────────────────────────────────────────
$maximumLifetime = $additionalProperties["maximumLifetimeInMinutes"]
if ($null -ne $maximumLifetime) {
    if ($maximumLifetime -le $MaxAllowedLifetime) {
        Write-Host "[PASS] Maximum lifetime: $maximumLifetime minutes" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Maximum lifetime: $maximumLifetime minutes (policy ceiling: $MaxAllowedLifetime)" -ForegroundColor Red
    }
}

# ── Check 6: Excluded groups ──────────────────────────────────────────────────
$excludedTargets = $tapPolicy.ExcludeTargets
if ($excludedTargets -and $excludedTargets.Count -gt 0) {
    Write-Host "[PASS] Excluded targets configured: $($excludedTargets.Count) group(s)" -ForegroundColor Green
} else {
    Write-Host "[WARN] No excluded targets set. Break-glass and service accounts should be excluded." -ForegroundColor Yellow
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Validation Complete ===" -ForegroundColor Cyan
Write-Host "Review any WARN/FAIL items above against the TAP policy documentation." -ForegroundColor Cyan
Write-Host "Portal path: Entra ID > Protection > Authentication methods > Temporary Access Pass" -ForegroundColor Cyan

Disconnect-MgGraph | Out-Null
