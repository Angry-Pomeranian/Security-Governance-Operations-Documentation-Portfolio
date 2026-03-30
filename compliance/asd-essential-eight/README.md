# ASD Essential Eight — Overview

The **Australian Signals Directorate (ASD) Essential Eight** is a prioritised set of eight mitigation strategies designed to protect organisations against the most common cyber threats. Compliance is recommended or mandated for most Australian government entities and is widely adopted across the private sector.

---

## Maturity Model

The Essential Eight uses a four-level maturity model:

| Level | Description |
|---|---|
| **ML0** | Not implemented, or only partially implemented |
| **ML1** | Mitigates commodity-level threats (opportunistic attackers, malware, phishing) |
| **ML2** | Mitigates targeted attacks by adversaries with moderate capability |
| **ML3** | Mitigates targeted attacks by adversaries with high capability |

The ASD recommends organisations achieve **ML2 as a minimum baseline** across all eight controls, with **ML3 for MFA** applying to internet-facing services and privileged accounts.

---

## The Eight Controls

### 1. Application Control

**Objective:** Prevent execution of unapproved or malicious programs.

| Maturity | Requirement |
|---|---|
| ML1 | Application control on workstations — prevent execution from user-writable paths |
| ML2 | Application control on internet-facing servers; block DLL execution from user-writable paths |
| ML3 | Application control on all servers; Microsoft recommended block rules applied |

Relevant portfolio content:
- CIS benchmark controls for Windows → `../../reference/endpoint-hardening/benchmarks/`
- Endpoint hardening scripts → `../../reference/endpoint-hardening/scripts/`

---

### 2. Patch Applications

**Objective:** Remediate vulnerabilities in applications within defined timeframes.

| Maturity | Requirement |
|---|---|
| ML1 | Critical patches applied within one month |
| ML2 | Critical patches applied within two weeks; unsupported apps removed |
| ML3 | Critical patches applied within 48 hours; automated scanning in place |

Relevant portfolio content:
- CIS browser benchmarks (Chrome, Edge, Firefox) → `../../reference/endpoint-hardening/benchmarks/browsers/`

---

### 3. Configure Microsoft Office Macro Settings

**Objective:** Prevent macro-based malware from executing.

| Maturity | Requirement |
|---|---|
| ML1 | Macros blocked from internet-sourced Office files |
| ML2 | Only signed macros permitted; macro antivirus scanning enabled |
| ML3 | Only macros from trusted, internally managed locations permitted |

Implementation approach: Microsoft Intune policy → Intune > Device Configuration > Windows > Administrative Templates > Microsoft Office > Security Settings.

---

### 4. User Application Hardening

**Objective:** Harden browsers and office applications against exploitation.

| Maturity | Requirement |
|---|---|
| ML1 | Browser security settings hardened; web advertisements blocked |
| ML2 | Internet Explorer 11 disabled; JScript blocked in Zone 3; .NET Framework 3.5 blocked |
| ML3 | PowerShell constrained language mode; command-line process creation auditing |

Relevant portfolio content:
- CIS Chrome benchmark → `../../reference/endpoint-hardening/benchmarks/browsers/chrome/`
- CIS Edge benchmark → `../../reference/endpoint-hardening/benchmarks/browsers/edge/`
- CIS Firefox benchmark → `../../reference/endpoint-hardening/benchmarks/browsers/firefox/`
- Browser deployment via MEM → `../../reference/identity-access/guides/`

---

### 5. Restrict Administrative Privileges

**Objective:** Limit the scope of damage from compromised admin credentials.

| Maturity | Requirement |
|---|---|
| ML1 | Admin privileges only for tasks requiring them; separate admin accounts |
| ML2 | No internet browsing from admin accounts; privileged access workstations (PAW) |
| ML3 | Just-in-time (JIT) admin access; admin activity logged and reviewed |

Relevant portfolio content:
- Conditional Access policies → `../../reference/identity-access/policies/`
- Account compromise playbook → `../../incident-response/account-compromise-playbook.md`

---

### 6. Patch Operating Systems

**Objective:** Remediate OS vulnerabilities within defined timeframes.

| Maturity | Requirement |
|---|---|
| ML1 | Critical OS patches applied within one month; unsupported OS replaced |
| ML2 | Critical patches applied within two weeks; automated vulnerability scanning |
| ML3 | Critical patches applied within 48 hours; assets without patches blocked from network |

Relevant portfolio content:
- CIS Windows benchmark → `../../reference/endpoint-hardening/benchmarks/`
- CIS RHEL 9 benchmark → `../../reference/endpoint-hardening/benchmarks/`

---

### 7. Multi-Factor Authentication

**Objective:** Prevent credential-based account takeover for internet-facing services and privileged access.

| Maturity | Requirement |
|---|---|
| ML1 | MFA for all remote access and cloud service logins |
| ML2 | MFA for all internet-facing services and privileged accounts |
| ML3 | Phishing-resistant MFA (FIDO2 hardware key, Windows Hello for Business, or Passkey) for all users |

Relevant portfolio content — this is one of the strongest areas in this portfolio:
- MFA deployment guide → `../../reference/identity-access/guides/`
- Passwordless (WHFB, Passkey, TAP) → `../../reference/identity-access/guides/`
- Conditional Access policies (MFA enforcement) → `../../reference/identity-access/policies/`

---

### 8. Regular Backups

**Objective:** Ensure data can be recovered following a ransomware or destructive attack.

| Maturity | Requirement |
|---|---|
| ML1 | Important data backed up daily; backups stored offline or offsite |
| ML2 | Backups tested for restoration; privileged access required to delete backups |
| ML3 | Backups stored in an immutable state; restoration tested quarterly |

Relevant portfolio content:
- Veeam security configuration → `../../reference/endpoint-hardening/`
- Ransomware response → `../../incident-response/ransomware-response-playbook.md`

---

## Related Documents

| Document | Purpose |
|---|---|
| [maturity-assessment-template.md](maturity-assessment-template.md) | Structured assessment template for evaluating an organisation against ML0–ML3 |
| [implementation-guidance.md](implementation-guidance.md) | Per-control implementation notes with Microsoft 365 and Azure tooling |
| [../nist-csf/README.md](../nist-csf/README.md) | NIST CSF cross-mapping |
