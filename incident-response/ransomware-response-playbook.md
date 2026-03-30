# Ransomware Response Playbook

**Scenario:** Ransomware deployment — file encryption events, ransom note creation, lateral movement by ransomware operators, or pre-ransomware indicators such as credential dumping and living-off-the-land binaries.

**Severity:** Critical
**Target containment time:** 30 minutes from confirmed detection

---

## 1. Detection

### Alert Triggers

| Source | Indicator |
|---|---|
| CrowdStrike Falcon | `Ransomware — mass file encryption detected` |
| CrowdStrike Falcon | `Credential access — LSASS process read` |
| CrowdStrike Falcon | `Lateral movement — PsExec / WMI remote execution` |
| Microsoft Sentinel | `Multiple file rename/delete events on file shares` |
| Microsoft Sentinel | `Volume shadow copy deletion (vssadmin delete shadows)` |
| Microsoft Sentinel | `RDP brute force success followed by lateral movement` |
| Microsoft Defender | `Ransomware behavior detected and blocked` |
| User-reported | `Files have strange extensions` / `Ransom note on desktop` |

### Key KQL — Volume Shadow Copy Deletion

```kql
SecurityEvent
| where TimeGenerated > ago(24h)
| where EventID == 4688
| where CommandLine has_any ("vssadmin", "wbadmin", "bcdedit", "wmic shadowcopy")
| where CommandLine has_any ("delete", "resize", "recoveryenabled no")
| project TimeGenerated, Computer, Account, CommandLine
```

### Key KQL — Mass File Rename Events (Pre-Encryption Indicator)

```kql
StorageFileLogs
| where TimeGenerated > ago(1h)
| where OperationName == "RenameFile"
| summarize RenameCount = count() by CallerIpAddress, bin(TimeGenerated, 5m)
| where RenameCount > 100
```

### Key KQL — Lateral Movement via PsExec/WMI

```kql
SecurityEvent
| where EventID in (4624, 4648)
| where LogonType in (3, 10)
| join kind=inner (
    SecurityEvent
    | where EventID == 4688
    | where CommandLine has_any ("psexec", "wmic", "winrm", "powershell -encoded")
) on Computer
| project TimeGenerated, Account, Computer, CommandLine
```

---

## 2. Triage

### Immediate Questions

1. Is encryption actively in progress or has it completed?
2. Which hosts are affected? Single endpoint or domain-wide?
3. Has lateral movement occurred? Are domain controllers involved?
4. What entry point was used? (RDP, phishing, exposed service, VPN?)
5. Are backups intact and air-gapped from the affected environment?

### Scope Assessment

| Indicator | Implication |
|---|---|
| Single host, encryption limited | Contained — isolate and recover |
| Multiple hosts, same subnet | Active spreading — network segment isolation required |
| Domain controller involved | Critical — attacker likely has full domain control |
| Backups deleted or encrypted | Severe — recovery timeline significantly extended |
| Ransom note found | Encryption complete or in progress |

### Pre-Ransomware Indicators (Dwell Time)

Ransomware operators typically dwell for 1–21 days before detonation. Look for:

- Cobalt Strike or Metasploit beacon activity
- Mass credential dumping (LSASS, SAM, NTDS.dit access)
- Reconnaissance commands (net user, net group, nltest, ping sweeps)
- Data staging and exfiltration prior to encryption (double extortion)
- Group Policy modification or scheduled task creation

---

## 3. Containment

### Immediate Actions (within 15–30 minutes)

**Do not shut down systems before capturing volatile evidence (memory, running processes) unless encryption is actively spreading.**

- [ ] Isolate affected hosts — disable network adapters or move to quarantine VLAN
- [ ] In CrowdStrike Falcon: Network Contain affected hosts
- [ ] Disable affected user accounts (likely compromised credentials used for lateral movement)
- [ ] Block the attacker's C2 infrastructure at perimeter firewall and DNS (Cisco Umbrella)
- [ ] Disable RDP and SMB on perimeter if exploited as entry point
- [ ] Notify management and engage external IR support if required

### Network Containment (Segment, Do Not Shut Down)

Prefer isolation over shutdown — shutdown destroys volatile memory evidence.

```
Quarantine VLAN: Move affected hosts to an isolated segment with no internal routing
Firewall rule: Block all outbound traffic from quarantine VLAN except to IR tooling
DNS sinkhole: Block identified C2 domains at Cisco Umbrella
```

### Backup Verification

- [ ] Confirm backup systems are online and have not been encrypted
- [ ] Take an offline snapshot of backups immediately
- [ ] Verify backup integrity — confirm a recent restore point is viable

---

## 4. Investigation

### Evidence to Collect

| Evidence | Method | Priority |
|---|---|---|
| Memory dump (volatile) | CrowdStrike RTR / WinPmem | Immediate |
| Running processes at time of detection | CrowdStrike Falcon telemetry | Immediate |
| Network connections at time of detection | CrowdStrike Falcon telemetry | Immediate |
| Windows Event Logs (Security, System, PowerShell) | Export via RTR | High |
| Prefetch files | Indicates executed binaries | High |
| Scheduled tasks and services | Persistence mechanisms | High |
| NTDS.dit / SAM (if DC affected) | Credential extraction evidence | High |
| Ransom note content | Identifies ransomware family | Medium |

### Ransomware Family Identification

Identify the ransomware family to assess:
- Known decryptors available?
- Known TTPs for this group?
- Double extortion / data leak threat?

Resources: ID Ransomware (upload encrypted file sample or ransom note), CISA advisories, CrowdStrike Adversary Intelligence.

### Determine Entry Point

| Common entry points | Investigation approach |
|---|---|
| Phishing email | Proofpoint TAP logs, email headers, attachment sandbox results |
| RDP brute force | Windows Security EventID 4625 (failures) + 4624 (success) |
| Vulnerable public-facing service | Check CVEs against asset inventory, web access logs |
| Supply chain / software | Identify unusual software recently installed |
| Valid credentials (prior compromise) | Cross-reference with account compromise investigation |

---

## 5. Eradication and Recovery

### Eradication Steps

- [ ] Identify and remove all ransomware binaries and dropped payloads
- [ ] Remove scheduled tasks, services, and registry run keys added by attacker
- [ ] Remove any backdoors or C2 agents (Cobalt Strike beacons, etc.)
- [ ] Reset credentials for all accounts that had access to affected systems
- [ ] Reset the krbtgt account password (twice, 10 hours apart) if domain controller was affected
- [ ] Patch the exploited vulnerability or misconfiguration used as entry point

### Recovery Sequence

Recover systems in priority order:
1. Domain controllers (if affected)
2. Core infrastructure (DNS, DHCP, PKI)
3. Business-critical servers
4. User workstations

For each system:
- [ ] Restore from verified clean backup (taken before dwell period)
- [ ] Verify backup integrity before connecting to network
- [ ] Apply all outstanding patches before returning to production
- [ ] Re-enrol in CrowdStrike and Microsoft Defender
- [ ] Monitor for 72 hours before declaring recovery complete

---

## 6. Post-Incident

### Regulatory Notification

Consider notification obligations:
- **Australian Privacy Act (APP 11)** — if personal data was exfiltrated, the Notifiable Data Breaches scheme may apply (OAIC notification within 30 days of becoming aware)
- **ASX-listed organisations** — material incidents may require continuous disclosure
- **Critical infrastructure operators** — SOCI Act obligations apply

### Customer Communication Template

> **Summary:** A ransomware incident was detected on [date] affecting [scope — X hosts / specific systems]. Encryption was [contained within / spread across] [description of scope]. Backups were [verified intact / affected — describe].
>
> **Containment actions:** Network isolation applied to [X] hosts. Attacker C2 blocked at perimeter. Affected accounts disabled.
>
> **Recovery status:** [X]% of systems restored from backup. Estimated full recovery: [date/timeframe].
>
> **Entry point:** [phishing / RDP / vulnerability] — patching/remediation in progress.
>
> **Data exfiltration:** [No evidence found / Exfiltration of [data type] confirmed — notification obligations being assessed.]

### Documentation Requirements

- [ ] Full timeline from initial compromise to detection to containment
- [ ] Affected host and data inventory
- [ ] Evidence log with chain of custody
- [ ] Entry point confirmed and remediated
- [ ] Regulatory obligations assessed and actioned
- [ ] Recovery validation results

### Lessons-Learned Review

- What was the dwell time between initial access and detection?
- Were pre-ransomware indicators visible but not alerted on?
- Were MFA and least privilege applied to the exploited account/system?
- Were backup systems sufficiently isolated from production?
- Did Conditional Access or network segmentation limit lateral movement?

---

## Related

- Account compromise → [account-compromise-playbook.md](account-compromise-playbook.md)
- Data exfiltration → [data-exfiltration-response-playbook.md](data-exfiltration-response-playbook.md)
- CrowdStrike automation → `../reference/automation/crowdstrike/`
