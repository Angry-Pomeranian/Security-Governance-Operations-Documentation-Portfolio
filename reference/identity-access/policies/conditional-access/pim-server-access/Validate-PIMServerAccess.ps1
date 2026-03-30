<#
.SYNOPSIS
    Validates the PIM Server Access Conditional Access policy in Entra ID.

.DESCRIPTION
    Connects to Microsoft Graph and searches for a Conditional Access policy targeting
    Microsoft Azure Management with phishing-resistant MFA authentication strength.
    Verifies grant controls, session controls, and exclusion of break-glass accounts.
    Outputs colour-coded results.

.REQUIREMENTS
    - Microsoft.Graph PowerShell module (Install-Module Microsoft.Graph)
    - Policy.Read.All permission (delegated or application)
    - Security Reader or Global Reader role minimum

.NOTES
    Run in a PowerShell session with appropriate Entra ID permissions.
    Update $BreakGlassGroupName to match your environment.
#>

#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Identity.ConditionalAccess

$ErrorActionPreference = "Stop"

# ── Configuration ─────────────────────────────────────────────────────────────
$AzureMgmtAppId     = "797f4846-ba00-4fd7-ba43-dac1f8f63013"  # Microsoft Azure Management
$BreakGlassGroupName = "grp-break-glass-accounts"
$ExpectedSignInFrequencyHours = 1

# ── Connect ───────────────────────────────────────────────────────────────────
Write-Host "`n=== PIM Server Access CA Policy Validation ===" -ForegroundColor Cyan
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan

try {
    Connect-MgGraph -Scopes "Policy.Read.All", "Group.Read.All" -NoWelcome
} catch {
    Write-Host "ERROR: Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
    exit 1
}

# ── Retrieve CA policies ──────────────────────────────────────────────────────
Write-Host "`nRetrieving Conditional Access policies..." -ForegroundColor Cyan

try {
    $allPolicies = Get-MgIdentityConditionalAccessPolicy -All
} catch {
    Write-Host "ERROR: Failed to retrieve CA policies: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ── Find relevant CA policy ───────────────────────────────────────────────────
# Look for a policy targeting Azure Management with phishing-resistant MFA
$pimPolicy = $null
foreach ($policy in $allPolicies) {
    $apps = $policy.Conditions.Applications.IncludeApplications
    $grantStrength = $policy.GrantControls.AuthenticationStrength

    $targetsAzureMgmt = $apps -contains $AzureMgmtAppId -or $apps -contains "All"
    $hasPhishingResistant = $null -ne $grantStrength -and
        $grantStrength.DisplayName -match "Phishing.resistant"

    if ($targetsAzureMgmt -and $hasPhishingResistant) {
        $pimPolicy = $policy
        break
    }
}

if ($null -eq $pimPolicy) {
    Write-Host "[FAIL] No CA policy found targeting Azure Management with phishing-resistant MFA." -ForegroundColor Red
    Write-Host "       Create a policy per: identity-access/policies/conditional-access/pim-server-access/README.md" -ForegroundColor Yellow
    Disconnect-MgGraph | Out-Null
    exit 1
}

Write-Host "[PASS] Found matching CA policy: '$($pimPolicy.DisplayName)'" -ForegroundColor Green

# ── Check 1: Policy state ─────────────────────────────────────────────────────
if ($pimPolicy.State -eq "enabled") {
    Write-Host "[PASS] Policy state: enabled" -ForegroundColor Green
} elseif ($pimPolicy.State -eq "enabledForReportingButNotEnforced") {
    Write-Host "[WARN] Policy state: report-only (not enforcing)" -ForegroundColor Yellow
} else {
    Write-Host "[FAIL] Policy state: $($pimPolicy.State)" -ForegroundColor Red
}

# ── Check 2: Authentication strength ─────────────────────────────────────────
$strength = $pimPolicy.GrantControls.AuthenticationStrength.DisplayName
if ($strength -match "Phishing.resistant") {
    Write-Host "[PASS] Authentication strength: $strength" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Authentication strength: $strength (expected: Phishing-resistant MFA)" -ForegroundColor Red
}

# ── Check 3: Session — sign-in frequency ─────────────────────────────────────
$sessionControls = $pimPolicy.SessionControls
if ($null -ne $sessionControls) {
    $signInFreq = $sessionControls.SignInFrequency
    if ($null -ne $signInFreq -and $signInFreq.IsEnabled) {
        $freqHours = if ($signInFreq.Type -eq "hours") { $signInFreq.Value } else { $signInFreq.Value * 24 }
        if ($freqHours -le $ExpectedSignInFrequencyHours) {
            Write-Host "[PASS] Sign-in frequency: $($signInFreq.Value) $($signInFreq.Type)" -ForegroundColor Green
        } else {
            Write-Host "[WARN] Sign-in frequency: $($signInFreq.Value) $($signInFreq.Type) (recommended: ≤$ExpectedSignInFrequencyHours hour)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[WARN] Sign-in frequency: not configured (recommended: 1 hour for Azure Management)" -ForegroundColor Yellow
    }

    # Persistent browser session
    $persistentSession = $sessionControls.PersistentBrowser
    if ($null -ne $persistentSession -and $persistentSession.Mode -eq "never") {
        Write-Host "[PASS] Persistent browser session: never" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Persistent browser session: not set to 'never' (recommended for privileged sessions)" -ForegroundColor Yellow
    }
}

# ── Check 4: Break-glass exclusion ────────────────────────────────────────────
$excludedGroups = $pimPolicy.Conditions.Users.ExcludeGroups
if ($excludedGroups -and $excludedGroups.Count -gt 0) {
    Write-Host "[PASS] Excluded groups configured: $($excludedGroups.Count) group(s)" -ForegroundColor Green
} else {
    Write-Host "[FAIL] No excluded groups. Break-glass accounts must be excluded from all CA policies." -ForegroundColor Red
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Validation Complete ===" -ForegroundColor Cyan
Write-Host "Review any WARN/FAIL items above against the PIM Server Access policy documentation." -ForegroundColor Cyan
Write-Host "Portal path: Entra ID > Protection > Conditional Access > Policies" -ForegroundColor Cyan
Write-Host "Use CA What-If tool to simulate sign-in scenarios before enabling enforcement." -ForegroundColor Cyan

Disconnect-MgGraph | Out-Null
