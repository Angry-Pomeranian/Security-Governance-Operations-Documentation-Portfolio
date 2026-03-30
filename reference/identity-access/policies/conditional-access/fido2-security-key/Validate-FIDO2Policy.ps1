<#
.SYNOPSIS
    Validates the FIDO2 Security Key Authentication Methods policy in Entra ID.

.DESCRIPTION
    Connects to Microsoft Graph and retrieves the FIDO2 Authentication Methods policy.
    Verifies that the method is enabled, attestation is enforced, and the key restrictions
    allowlist contains the expected approved hardware AAGUIDs. Outputs colour-coded results.

.REQUIREMENTS
    - Microsoft.Graph PowerShell module (Install-Module Microsoft.Graph)
    - Policy.Read.All permission (delegated or application)
    - Authentication Administrator or Global Administrator role

.NOTES
    Run in a PowerShell session with appropriate Entra ID permissions.
#>

#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Identity.SignIns

$ErrorActionPreference = "Stop"

# ── Approved AAGUIDs ──────────────────────────────────────────────────────────
$ApprovedAAGUIDs = @(
    "2fc0579f-8113-47ea-b116-bb5a8db9202a",  # YubiKey 5 NFC
    "c1f9a0bc-1dd2-404a-b27f-8e29047a43fd",  # YubiKey 5C NFC
    "c5ef55ff-ad9a-4b9f-b580-adebafe026d0",  # YubiKey 5Ci
    "833b721a-ff5f-4d00-bb2e-bdda7ec3e0a3",  # Feitian ePass FIDO2
    "90a3ccdf-635c-4729-a248-9b709135078f"   # Microsoft Authenticator passkey
)

# ── Connect ───────────────────────────────────────────────────────────────────
Write-Host "`n=== FIDO2 Security Key Authentication Methods Policy Validation ===" -ForegroundColor Cyan
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan

try {
    Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome
} catch {
    Write-Host "ERROR: Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
    exit 1
}

# ── Retrieve FIDO2 policy ─────────────────────────────────────────────────────
Write-Host "`nRetrieving FIDO2 Authentication Methods policy..." -ForegroundColor Cyan

try {
    $fido2Policy = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration `
        -AuthenticationMethodConfigurationId "Fido2"
} catch {
    Write-Host "ERROR: Failed to retrieve FIDO2 policy: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
$props = $fido2Policy.AdditionalProperties

# ── Check 1: Policy state ─────────────────────────────────────────────────────
if ($fido2Policy.State -eq "enabled") {
    Write-Host "[PASS] FIDO2 policy state: enabled" -ForegroundColor Green
} else {
    Write-Host "[FAIL] FIDO2 policy state: $($fido2Policy.State) (expected: enabled)" -ForegroundColor Red
}

# ── Check 2: Self-service setup ───────────────────────────────────────────────
$selfService = $props["isSelfServiceRegistrationAllowed"]
if ($selfService -eq $true) {
    Write-Host "[PASS] Self-service registration: allowed" -ForegroundColor Green
} else {
    Write-Host "[WARN] Self-service registration: not allowed (users cannot register at mysecurityinfo)" -ForegroundColor Yellow
}

# ── Check 3: Attestation enforcement ─────────────────────────────────────────
$attestation = $props["isAttestationEnforced"]
if ($attestation -eq $true) {
    Write-Host "[PASS] Attestation enforcement: enabled" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Attestation enforcement: disabled (required for production — prevents uncertified keys)" -ForegroundColor Red
}

# ── Check 4: Key restrictions ─────────────────────────────────────────────────
$keyRestrictions = $props["keyRestrictions"]
if ($null -ne $keyRestrictions) {
    $restrictionType = $keyRestrictions["restrictionType"]
    $aaGuids = $keyRestrictions["aaGuids"]

    if ($restrictionType -eq "allow") {
        Write-Host "[PASS] Key restriction type: allowed list" -ForegroundColor Green

        if ($null -ne $aaGuids -and $aaGuids.Count -gt 0) {
            Write-Host "[PASS] AAGUID allowlist: $($aaGuids.Count) key(s) configured" -ForegroundColor Green

            # Cross-check approved AAGUIDs
            foreach ($approvedGuid in $ApprovedAAGUIDs) {
                if ($aaGuids -contains $approvedGuid) {
                    Write-Host "       [PASS] AAGUID present: $approvedGuid" -ForegroundColor Green
                } else {
                    Write-Host "       [WARN] AAGUID missing: $approvedGuid" -ForegroundColor Yellow
                }
            }

            # Flag any unrecognised AAGUIDs
            foreach ($guid in $aaGuids) {
                if ($ApprovedAAGUIDs -notcontains $guid) {
                    Write-Host "       [WARN] Unrecognised AAGUID in allowlist: $guid — verify this is an approved key" -ForegroundColor Yellow
                }
            }
        } else {
            Write-Host "[WARN] AAGUID allowlist is empty — all keys blocked or restriction not effective" -ForegroundColor Yellow
        }
    } elseif ($restrictionType -eq "block") {
        Write-Host "[WARN] Key restriction type: blocked list (consider switching to allowed list for tighter control)" -ForegroundColor Yellow
    } else {
        Write-Host "[WARN] Key restrictions not enforced — any FIDO2 key can be registered" -ForegroundColor Yellow
    }
} else {
    Write-Host "[WARN] Key restrictions not configured — any FIDO2 key can be registered" -ForegroundColor Yellow
}

# ── Check 5: Included targets ─────────────────────────────────────────────────
$includedTargets = $fido2Policy.IncludeTargets
if ($includedTargets -and $includedTargets.Count -gt 0) {
    Write-Host "[PASS] Included targets: $($includedTargets.Count) group(s)/All users" -ForegroundColor Green
} else {
    Write-Host "[WARN] No included targets — policy may not be scoped to any users" -ForegroundColor Yellow
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Validation Complete ===" -ForegroundColor Cyan
Write-Host "Review any WARN/FAIL items above against the FIDO2 policy documentation." -ForegroundColor Cyan
Write-Host "Portal path: Entra ID > Protection > Authentication methods > FIDO2 Security Key" -ForegroundColor Cyan
Write-Host "FIDO Alliance MDS: https://fidoalliance.org/metadata/" -ForegroundColor Cyan

Disconnect-MgGraph | Out-Null
