# ASD Essential Eight — Implementation Guidance

Per-control implementation notes using Microsoft 365, Azure, and common enterprise tooling. References technical documentation in this portfolio where relevant.

---

## Control 1: Application Control

### Recommended Tooling

| Tool | Scope | Notes |
|---|---|---|
| Windows Defender Application Control (WDAC) | Windows 10/11, Server 2016+ | Microsoft recommended; kernel-level enforcement |
| AppLocker | Windows 10/11 (limited) | Legacy; does not meet ML2+ in isolation |
| Microsoft Intune | Deployment vehicle | Deploy WDAC policies via Intune |

### Implementation Steps

**WDAC via Intune:**

1. Create a WDAC policy XML using the WDAC Wizard or PowerShell `New-CIPolicy`
2. Convert to binary: `ConvertFrom-CIPolicy -xmlFilePath policy.xml -BinaryFilePath policy.bin`
3. Deploy via Intune: Endpoint Security > Application Control > Windows Defender Application Control
4. Monitor compliance: Intune reports > Device compliance > WDAC enforcement

**Key policy rules for ML1:**
- Block execution from `%TEMP%`, `%APPDATA%`, `%USERPROFILE%\Downloads`
- Allow only publisher-signed or hash-approved applications

**Elevation to ML2:**
- Extend to internet-facing servers
- Add explicit DLL rules blocking loading from user-writable paths

---

## Control 2: Patch Applications

### Recommended Tooling

| Tool | Scope |
|---|---|
| Microsoft Intune | Windows application updates |
| Microsoft Endpoint Configuration Manager (MECM) | Enterprise software deployment |
| Qualys / Tenable Nessus | Vulnerability scanning |
| Renovate / Dependabot | Third-party software libraries (DevSecOps) |

### Implementation Steps

1. **Asset inventory:** Maintain an up-to-date software inventory (Intune > Devices > Software inventory)
2. **Vulnerability scanning:** Run weekly authenticated scans; export results for patching prioritisation
3. **Patching cadence:**
   - ML1: Critical CVEs patched within 30 days
   - ML2: Critical CVEs patched within 14 days; scanner confirms resolution
   - ML3: Critical CVEs patched within 48 hours; non-compliant devices blocked via Conditional Access
4. **Unsupported software:** Identify EOL applications via Intune software inventory; remove or replace

---

## Control 3: Configure Microsoft Office Macro Settings

### Recommended Tooling

| Tool | Method |
|---|---|
| Microsoft Intune | Administrative templates (ADMX) > Microsoft Office |
| Group Policy | Computer Configuration > Administrative Templates > Microsoft Office |
| Microsoft 365 Trust Center | Tenant-wide macro baseline |

### Implementation Steps

**Block internet-sourced file macros (ML1):**

Intune > Configuration Profiles > Administrative Templates > Microsoft Excel/Word/PowerPoint:
- Setting: "Block macros from running in Office files from the Internet" → **Enabled**

**Require macro signing (ML2):**

- Setting: "Trust access to VBA project object model" → **Disabled**
- Setting: "VBA Macro Notification Settings" → **Disable all except digitally signed macros**
- Establish an internal code-signing certificate via your enterprise PKI

**Trusted locations only (ML3):**

- Setting: "Disable all trusted locations" → **Enabled**
- Explicitly define approved UNC paths for macro-containing documents
- Remove all default trusted locations

---

## Control 4: User Application Hardening

### Browser Hardening

CIS benchmark policies for Chrome, Edge, and Firefox are documented in this portfolio:
- Chrome → `../../reference/endpoint-hardening/benchmarks/browsers/chrome/`
- Edge → `../../reference/endpoint-hardening/benchmarks/browsers/edge/`
- Firefox → `../../reference/endpoint-hardening/benchmarks/browsers/firefox/`

**Deployment via Microsoft Intune (MEM):**

Full browser deployment and policy configuration via MEM is documented in:
- `../../reference/identity-access/guides/`

**Key browser settings for ML1:**
- Enable Enhanced Safe Browsing
- Block mixed content (HTTP on HTTPS pages)
- Disable password manager (use enterprise password manager)
- Block third-party cookies
- Disable developer tools for standard users

**Advertisement blocking (ML1):**
Deploy a browser extension policy via Intune (Chrome/Edge) or Firefox ADMX to enforce an approved content-filtering extension.

### PowerShell Hardening (ML3)

Enable PowerShell Constrained Language Mode via WDAC policy. When WDAC is in enforcement mode, PowerShell automatically enters Constrained Language Mode on systems where the signing policy is enforced.

Enable script block logging for visibility:
```powershell
# Group Policy: Computer Configuration > Windows Settings > Administrative Templates
# Windows Components > Windows PowerShell
# Turn on Script Block Logging: Enabled
```

---

## Control 5: Restrict Administrative Privileges

### Recommended Tooling

| Tool | Purpose |
|---|---|
| Microsoft Entra ID | Admin role management, PIM |
| Microsoft Entra Privileged Identity Management (PIM) | JIT admin access |
| Conditional Access | Enforce MFA, PAW requirement for admin sign-in |
| Microsoft Intune | Privileged Access Workstation (PAW) device configuration |

### Implementation Steps

**Separate admin accounts (ML1):**
- Provision dedicated admin accounts separate from daily-use accounts
- Admin accounts: no mailbox, no internet access, no non-admin software
- Naming convention: `adm-firstname.lastname@domain.com`

**No internet access from admin accounts (ML2):**
- Conditional Access: If user role is Directory Role and device is not PAW-compliant → Block
- Alternatively, admin accounts are restricted by Group Policy from launching browsers

**JIT access via PIM (ML3):**
1. Entra ID > Privileged Identity Management > Azure AD Roles
2. Set all privileged roles (Global Admin, Security Admin, etc.) as "Eligible" not "Active"
3. Configure: Maximum activation duration 4 hours, require justification and MFA
4. Enable access reviews quarterly

---

## Control 6: Patch Operating Systems

### Implementation Steps

**Windows patching via Intune:**
1. Intune > Devices > Windows > Update Rings
2. Create update rings for:
   - Pilot group (deferred 0 days — immediate)
   - Standard group (deferred 7 days)
   - Deadline enforcement: 14 days for quality updates, 30 days for feature updates
3. Report: Monitor update compliance via Intune reports

**RHEL / Linux patching:**
- `dnf check-update` + `dnf update` on scheduled cron job
- Or via Ansible playbook for fleet management
- Track CVE remediation via subscription manager: `subscription-manager repos --enable rhel-*-rpms`

**Non-compliant device enforcement (ML3):**
Conditional Access policy: If device compliance state is non-compliant → Block access to all cloud apps.

This ensures unpatched devices cannot authenticate to Microsoft 365, Azure, or other integrated services.

---

## Control 7: Multi-Factor Authentication

This is the most thoroughly documented control in this portfolio.

### Implementation References

| Document | Content |
|---|---|
| `../../reference/identity-access/guides/` | MFA deployment, passwordless rollout (WHFB, Passkey, TAP) |
| `../../reference/identity-access/policies/` | Conditional Access policies enforcing MFA |

### Maturity Pathway

**ML1 — MFA for remote access and cloud:**
- Conditional Access: Require MFA for all users signing in from outside the corporate network
- Register all users for Microsoft Authenticator app

**ML2 — MFA for all internet-facing services:**
- Conditional Access: Require MFA for all cloud app sign-ins (no network exclusion)
- Extend to VPN, remote desktop gateway, and all SaaS

**ML3 — Phishing-resistant MFA:**
- Deploy Windows Hello for Business (WHFB) — documented in identity-access/guides/
- Register FIDO2 hardware keys for privileged accounts
- Conditional Access: Authentication strength policy → require phishing-resistant MFA for admin roles
- Passkey deployment for non-Windows or BYOD scenarios — documented in identity-access/guides/

---

## Control 8: Regular Backups

### Recommended Tooling

| Tool | Scope |
|---|---|
| Veeam Backup and Replication | On-premises and cloud workloads |
| Microsoft Azure Backup | Azure VMs, SQL, file shares |
| Microsoft 365 Backup | Exchange, SharePoint, OneDrive |
| Immutable Azure Blob Storage | Archive target with WORM policy |

### Implementation Steps

**Daily backup cadence (ML1):**
- Configure Veeam jobs for all critical workloads — daily incremental, weekly full
- Back up to a separate storage target (not on the same server or VLAN)
- Veeam security configuration → `../../reference/endpoint-hardening/`

**Offline / offsite storage (ML1):**
- Configure Veeam Scale-Out Backup Repository with an offsite capacity tier (Azure Blob or tape)
- Ensure backup credentials are separate from production domain accounts

**Immutable backups (ML3):**
- Enable Azure Blob immutability policy (time-based retention lock)
- Set minimum retention: 30 days; lock the policy to prevent modification
- Verify: Attempt deletion of a protected blob — operation must fail

**Backup restoration testing:**
- ML2: Test restoration of at least one workload per quarter
- ML3: Quarterly documented restoration test; record RTO and RPO achieved
- Use a separate restore environment — do not restore to production for testing

---

## Related

| Document | Content |
|---|---|
| [maturity-assessment-template.md](maturity-assessment-template.md) | Assessment template |
| [README.md](README.md) | Essential Eight overview and maturity model |
| [../nist-csf/README.md](../nist-csf/README.md) | NIST CSF cross-mapping |
