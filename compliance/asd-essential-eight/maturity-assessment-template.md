# ASD Essential Eight — Maturity Assessment Template

Use this template to assess an organisation's current maturity level against the ASD Essential Eight. For each control, record the current state, evidence reviewed, gaps identified, and recommended actions.

**Assessment date:** _______________
**Assessor:** _______________
**Organisation / environment:** _______________
**Target maturity level:** _______________ (recommended minimum: ML2)

---

## How to Use This Template

1. Review the maturity criteria for each control in [README.md](README.md)
2. Interview relevant technical and operational staff
3. Review configuration evidence (screenshots, exports, policy documents)
4. Record the current maturity level based on observed evidence — not stated intent
5. Document gaps and assign remediation owners and timeframes

**Maturity levels:**

| Code | Level | Meaning |
|---|---|---|
| ML0 | Not implemented | Control is absent or only partially in place |
| ML1 | Basic | Mitigates commodity threats |
| ML2 | Intermediate | Mitigates targeted moderate-capability attacks |
| ML3 | Advanced | Mitigates targeted high-capability attacks |

---

## Control 1: Application Control

**Current maturity:** ML___

### Evidence Reviewed

| Evidence item | Source | Date |
|---|---|---|
| | | |
| | | |

### Current State

_Describe what application control is currently implemented, on which systems, and using which technology (e.g., AppLocker, WDAC, Intune)._

### Gap Analysis

| Requirement | Met? | Notes |
|---|---|---|
| Application control on workstations | Yes / Partial / No | |
| Execution blocked from user-writable paths | Yes / Partial / No | |
| Application control on internet-facing servers (ML2) | Yes / Partial / No | |
| DLL execution blocked from user-writable paths (ML2) | Yes / Partial / No | |
| All servers covered; MS block rules applied (ML3) | Yes / Partial / No | |

### Recommendations

| Priority | Recommendation | Owner | Due |
|---|---|---|---|
| | | | |

---

## Control 2: Patch Applications

**Current maturity:** ML___

### Evidence Reviewed

| Evidence item | Source | Date |
|---|---|---|
| | | |

### Current State

_Describe the current patching cadence, tooling (e.g., MECM, Intune, WSUS), and whether unsupported software has been identified and removed._

### Gap Analysis

| Requirement | Met? | Notes |
|---|---|---|
| Critical patches applied within one month (ML1) | Yes / Partial / No | |
| Unsupported applications removed (ML2) | Yes / Partial / No | |
| Critical patches applied within two weeks (ML2) | Yes / Partial / No | |
| Automated vulnerability scanning in place (ML2) | Yes / Partial / No | |
| Critical patches applied within 48 hours (ML3) | Yes / Partial / No | |

### Recommendations

| Priority | Recommendation | Owner | Due |
|---|---|---|---|
| | | | |

---

## Control 3: Configure Microsoft Office Macro Settings

**Current maturity:** ML___

### Evidence Reviewed

| Evidence item | Source | Date |
|---|---|---|
| | | |

### Current State

_Describe current macro policy (blocked by default, allowed with signing, allowed from specific locations), and the configuration method (Group Policy, Intune, M365 Admin)._

### Gap Analysis

| Requirement | Met? | Notes |
|---|---|---|
| Macros blocked for internet-sourced files (ML1) | Yes / Partial / No | |
| Only signed macros permitted (ML2) | Yes / Partial / No | |
| Antivirus scanning of macros enabled (ML2) | Yes / Partial / No | |
| Macros only from trusted managed locations (ML3) | Yes / Partial / No | |

### Recommendations

| Priority | Recommendation | Owner | Due |
|---|---|---|---|
| | | | |

---

## Control 4: User Application Hardening

**Current maturity:** ML___

### Evidence Reviewed

| Evidence item | Source | Date |
|---|---|---|
| | | |

### Current State

_Describe browser hardening configuration, extension controls, and any application-layer restrictions currently applied._

### Gap Analysis

| Requirement | Met? | Notes |
|---|---|---|
| Browser security settings hardened (ML1) | Yes / Partial / No | |
| Web advertisements blocked (ML1) | Yes / Partial / No | |
| IE11 disabled (ML2) | Yes / Partial / No | |
| JScript blocked in Internet Zone (ML2) | Yes / Partial / No | |
| PowerShell constrained language mode (ML3) | Yes / Partial / No | |
| Command-line process creation auditing (ML3) | Yes / Partial / No | |

### Recommendations

| Priority | Recommendation | Owner | Due |
|---|---|---|---|
| | | | |

---

## Control 5: Restrict Administrative Privileges

**Current maturity:** ML___

### Evidence Reviewed

| Evidence item | Source | Date |
|---|---|---|
| | | |

### Current State

_Describe how administrative access is managed — separate admin accounts, admin account review cadence, privileged access workstation usage, JIT access tooling._

### Gap Analysis

| Requirement | Met? | Notes |
|---|---|---|
| Admin access restricted to tasks requiring it (ML1) | Yes / Partial / No | |
| Separate admin accounts in use (ML1) | Yes / Partial / No | |
| No internet access from admin accounts (ML2) | Yes / Partial / No | |
| Admin access reviewed quarterly (ML2) | Yes / Partial / No | |
| JIT admin access implemented (ML3) | Yes / Partial / No | |
| Privileged access workstations (PAW) in use (ML3) | Yes / Partial / No | |

### Recommendations

| Priority | Recommendation | Owner | Due |
|---|---|---|---|
| | | | |

---

## Control 6: Patch Operating Systems

**Current maturity:** ML___

### Evidence Reviewed

| Evidence item | Source | Date |
|---|---|---|
| | | |

### Current State

_Describe current OS patching cadence, tooling, coverage (servers vs workstations), and whether unsupported OS versions exist in the environment._

### Gap Analysis

| Requirement | Met? | Notes |
|---|---|---|
| Critical OS patches applied within one month (ML1) | Yes / Partial / No | |
| Unsupported OS versions removed (ML1) | Yes / Partial / No | |
| Critical patches applied within two weeks (ML2) | Yes / Partial / No | |
| Automated vulnerability scanning (ML2) | Yes / Partial / No | |
| Critical patches applied within 48 hours (ML3) | Yes / Partial / No | |
| Unpatched assets blocked from network (ML3) | Yes / Partial / No | |

### Recommendations

| Priority | Recommendation | Owner | Due |
|---|---|---|---|
| | | | |

---

## Control 7: Multi-Factor Authentication

**Current maturity:** ML___

### Evidence Reviewed

| Evidence item | Source | Date |
|---|---|---|
| | | |

### Current State

_Describe current MFA coverage — which services, which user populations, which authentication methods (SMS, TOTP, push, FIDO2). Note any Conditional Access policies enforcing MFA._

### Gap Analysis

| Requirement | Met? | Notes |
|---|---|---|
| MFA for all remote access and cloud logins (ML1) | Yes / Partial / No | |
| MFA for all internet-facing services (ML2) | Yes / Partial / No | |
| MFA for all privileged accounts (ML2) | Yes / Partial / No | |
| Phishing-resistant MFA for all users (ML3) | Yes / Partial / No | |
| Phishing-resistant MFA for all admins (ML3) | Yes / Partial / No | |

**Notes on phishing-resistant methods:** FIDO2 hardware keys, Windows Hello for Business, and Passkeys meet ML3. SMS OTP and push notifications do not.

### Recommendations

| Priority | Recommendation | Owner | Due |
|---|---|---|---|
| | | | |

---

## Control 8: Regular Backups

**Current maturity:** ML___

### Evidence Reviewed

| Evidence item | Source | Date |
|---|---|---|
| | | |

### Current State

_Describe backup cadence, storage locations (online, offline, offsite, immutable), retention periods, and when backups were last successfully tested._

### Gap Analysis

| Requirement | Met? | Notes |
|---|---|---|
| Important data backed up daily (ML1) | Yes / Partial / No | |
| Backups stored offline or offsite (ML1) | Yes / Partial / No | |
| Backup restoration tested (ML2) | Yes / Partial / No | |
| Privileged access required to delete backups (ML2) | Yes / Partial / No | |
| Backups stored in immutable state (ML3) | Yes / Partial / No | |
| Restoration tested quarterly (ML3) | Yes / Partial / No | |

### Recommendations

| Priority | Recommendation | Owner | Due |
|---|---|---|---|
| | | | |

---

## Assessment Summary

| Control | Current ML | Target ML | Gap | Priority |
|---|---|---|---|---|
| 1. Application Control | ML | ML | | |
| 2. Patch Applications | ML | ML | | |
| 3. Office Macro Settings | ML | ML | | |
| 4. User Application Hardening | ML | ML | | |
| 5. Restrict Administrative Privileges | ML | ML | | |
| 6. Patch Operating Systems | ML | ML | | |
| 7. Multi-Factor Authentication | ML | ML | | |
| 8. Regular Backups | ML | ML | | |

### Overall Assessment

_Provide a summary of the organisation's overall Essential Eight posture, key risks, and the recommended remediation priorities._

### Remediation Roadmap

| Priority | Control | Recommendation | Owner | Target date |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

---

*Assessment based on ASD Essential Eight Maturity Model. Reference: Australian Signals Directorate — Essential Eight Maturity Model.*
