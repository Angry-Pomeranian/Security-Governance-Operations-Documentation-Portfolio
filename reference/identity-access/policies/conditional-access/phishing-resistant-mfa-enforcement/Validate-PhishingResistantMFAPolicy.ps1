<#
.SYNOPSIS
    Validates the Phishing-Resistant MFA Enforcement Conditional Access policy in Entra ID.

.DESCRIPTION
    Connects to Microsoft Graph and searches for a Conditional Access policy targeting
    All cloud apps with phishing-resistant MFA authentication strength. Verifies policy
    state, authentication strength grant, break-glass exclusions, and included users scope.
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
$BreakGlassGroupName = "grp-break-glass-accounts"

# ── Connect ───────────────────────────────────────────────────────────────────
Write-Host "`n=== Phishing-Resistant MFA Enforcement CA Policy Validation ===" -ForegroundColor Cyan
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

# ── Find phishing-resistant MFA enforcement policy ────────────────────────────
$enforcementPolicy = $null
foreach ($policy in $allPolicies) {
    $apps = $policy.Conditions.Applications.IncludeApplications
    $grantStrength = $policy.GrantControls.AuthenticationStrength

    $targetsAllApps = $apps -contains "All"
    $hasPhishingResistant = $null -ne $grantStrength -and
        $grantStrength.DisplayName -match "Phishing.resistant"

    if ($targetsAllApps -and $hasPhishingResistant) {
        $enforcementPolicy = $policy
        break
    }
}

if ($null -eq $enforcementPolicy) {
    Write-Host "[FAIL] No CA policy found targeting All cloud apps with phishing-resistant MFA." -ForegroundColor Red
    Write-Host "       Expected: policy with IncludeApplications = All + AuthenticationStrength = Phishing-resistant MFA" -ForegroundColor Yellow
    Write-Host "       Create per: identity-access/policies/conditional-access/phishing-resistant-mfa-enforcement/README.md" -ForegroundColor Yellow
    Disconnect-MgGraph | Out-Null
    exit 1
}

Write-Host "[PASS] Found matching CA policy: '$($enforcementPolicy.DisplayName)'" -ForegroundColor Green

# ── Check 1: Policy state ─────────────────────────────────────────────────────
if ($enforcementPolicy.State -eq "enabled") {
    Write-Host "[PASS] Policy state: enabled (actively enforcing)" -ForegroundColor Green
} elseif ($enforcementPolicy.State -eq "enabledForReportingButNotEnforced") {
    Write-Host "[WARN] Policy state: report-only (monitoring but not enforcing)" -ForegroundColor Yellow
    Write-Host "       Advance to enforcement once registration coverage is sufficient." -ForegroundColor Yellow
} else {
    Write-Host "[FAIL] Policy state: $($enforcementPolicy.State) (disabled — not protecting the tenant)" -ForegroundColor Red
}

# ── Check 2: Authentication strength ─────────────────────────────────────────
$strength = $enforcementPolicy.GrantControls.AuthenticationStrength.DisplayName
if ($strength -match "Phishing.resistant") {
    Write-Host "[PASS] Authentication strength: $strength" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Authentication strength: '$strength' (expected: Phishing-resistant MFA)" -ForegroundColor Red
}

# ── Check 3: Included users ───────────────────────────────────────────────────
$includedUsers = $enforcementPolicy.Conditions.Users.IncludeUsers
$includedGroups = $enforcementPolicy.Conditions.Users.IncludeGroups

if ($includedUsers -contains "All") {
    Write-Host "[PASS] Included users: All users" -ForegroundColor Green
} elseif ($includedGroups -and $includedGroups.Count -gt 0) {
    Write-Host "[WARN] Included users: $($includedGroups.Count) group(s) only — not yet covering all users" -ForegroundColor Yellow
    Write-Host "       This is expected during phased rollout. Expand to All users when registration is complete." -ForegroundColor Yellow
} else {
    Write-Host "[WARN] Included users: cannot determine scope from this check" -ForegroundColor Yellow
}

# ── Check 4: Break-glass exclusion ────────────────────────────────────────────
$excludedGroups = $enforcementPolicy.Conditions.Users.ExcludeGroups
if ($excludedGroups -and $excludedGroups.Count -gt 0) {
    Write-Host "[PASS] Excluded groups configured: $($excludedGroups.Count) group(s)" -ForegroundColor Green
} else {
    Write-Host "[FAIL] No excluded groups. Break-glass accounts MUST be excluded from all CA policies." -ForegroundColor Red
}

# ── Check 5: Service account exclusion warning ────────────────────────────────
Write-Host "[INFO] Verify manually that service accounts and non-interactive accounts are excluded." -ForegroundColor Cyan
Write-Host "       Non-interactive accounts should use managed identities, not be subject to this CA policy." -ForegroundColor Cyan

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Validation Complete ===" -ForegroundColor Cyan
Write-Host "Rollout phases: Report-only → Pilot group → All users (per README.md)." -ForegroundColor Cyan
Write-Host "Portal path: Entra ID > Protection > Conditional Access > Policies" -ForegroundColor Cyan
Write-Host "Registration coverage: Entra ID > Protection > Authentication methods > User registration details" -ForegroundColor Cyan

Disconnect-MgGraph | Out-Null
