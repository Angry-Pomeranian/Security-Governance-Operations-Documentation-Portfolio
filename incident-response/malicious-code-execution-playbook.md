# Malicious Code Execution Playbook

**Scenario:** CrowdStrike Falcon or Microsoft Defender detects malicious or suspicious code execution on a corporate endpoint — including offensive tooling, script-based attacks, unsigned binary execution, process injection, or the presence of attacker frameworks (Kali Linux WSL, Metasploit, Cobalt Strike artefacts).

**Severity:** High–Critical
**Target containment time:** 30 minutes from detection

**ISO 27001:2022 Controls:** A.5.24 · A.5.25 · A.5.26 · A.5.27 · A.5.28 · A.8.7 · A.8.8 · A.8.16
**CIA Impact:** Confidentiality — High | Integrity — High | Availability — Medium

---

## 1. Detection

### Alert Triggers

| Source | Indicator |
|---|---|
| CrowdStrike Falcon | `Malware detected — execution blocked` |
| CrowdStrike Falcon | `Suspicious process: LSASS memory access` |
| CrowdStrike Falcon | `Lateral movement indicator — remote thread injection` |
| CrowdStrike Falcon | `Custom IOA — offensive tool execution` |
| Microsoft Sentinel | `Kali Linux WSL execution detected` (hunting rule) |
| Microsoft Defender | `Suspicious PowerShell execution` |
| Microsoft Defender | `Process hollowing — code injected into legitimate process` |
| Microsoft Sentinel | `DeviceProcessEvents: high-entropy child process from Office application` |
| User-reported | Endpoint behaving unusually — slowness, unexpected windows, processes |

### Key KQL — Offensive Tool Execution (Kali Linux / WSL)

```kql
DeviceProcessEvents
| where TimeGenerated > ago(24h)
| where ProcessCommandLine has_any (
    "kali", "wsl.exe", "bash.exe", "wsl --install",
    "nmap", "metasploit", "msfconsole", "msfvenom",
    "mimikatz", "procdump", "pwdump", "secretsdump"
  )
| project TimeGenerated, DeviceName, AccountName, InitiatingProcessFileName,
          FileName, ProcessCommandLine, FolderPath
| order by TimeGenerated desc
```

### Key KQL — Suspicious PowerShell Execution

```kql
DeviceProcessEvents
| where TimeGenerated > ago(24h)
| where FileName in~ ("powershell.exe", "pwsh.exe")
| where ProcessCommandLine has_any (
    "-EncodedCommand", "-enc ", "-ep bypass", "-ExecutionPolicy Bypass",
    "IEX", "Invoke-Expression", "DownloadString", "WebClient",
    "FromBase64String", "-nop", "-windowstyle hidden"
  )
| project TimeGenerated, DeviceName, AccountName, ProcessCommandLine,
          InitiatingProcessFileName, InitiatingProcessCommandLine
| order by TimeGenerated desc
```

### Key KQL — LSASS Credential Access

```kql
DeviceProcessEvents
| where TimeGenerated > ago(24h)
| where (FileName =~ "procdump.exe" and ProcessCommandLine contains "lsass")
    or (InitiatingProcessFileName !in~ ("lsass.exe", "MsMpEng.exe", "csrss.exe")
        and FileName =~ "lsass.exe" and ProcessCommandLine contains "minidump")
| project TimeGenerated, DeviceName, AccountName, FileName,
          ProcessCommandLine, InitiatingProcessFileName
```

### Key KQL — High-Entropy Child Processes from Office Applications

```kql
DeviceProcessEvents
| where TimeGenerated > ago(24h)
| where InitiatingProcessFileName in~ (
    "winword.exe", "excel.exe", "powerpnt.exe", "outlook.exe", "mspub.exe"
  )
| where FileName in~ (
    "cmd.exe", "powershell.exe", "wscript.exe", "cscript.exe",
    "mshta.exe", "regsvr32.exe", "rundll32.exe", "certutil.exe", "bitsadmin.exe"
  )
| project TimeGenerated, DeviceName, AccountName, InitiatingProcessFileName,
          FileName, ProcessCommandLine, FolderPath
| order by TimeGenerated desc
```

---

## 2. Triage

### Immediate Questions

1. Was the execution blocked or allowed by CrowdStrike/Defender?
2. What was the parent process — how was the malicious code spawned?
3. What user account was active on the endpoint at execution time?
4. Has the process attempted network connections? To what destinations?
5. Is the device a standard workstation, server, or privileged admin workstation (PAW)?
6. Are other devices in the organisation showing the same indicators?
7. Was this on a domain-joined device with access to shared file systems or AD?

### Log Sources to Review

| Source | What to look for |
|---|---|
| CrowdStrike Falcon — Host Timeline | Full process tree, network connections, file writes, registry changes |
| CrowdStrike Falcon — Event Search | All events for the affected host in the ±2 hour window |
| Microsoft Sentinel — DeviceProcessEvents | Process chain, parent-child relationships |
| Microsoft Sentinel — DeviceNetworkEvents | Outbound connections from the affected process |
| Microsoft Sentinel — DeviceFileEvents | Files written or deleted during execution |
| Microsoft Entra ID — Sign-in logs | Was the user account active on another device simultaneously? |

### Severity Classification

| Condition | Severity |
|---|---|
| Confirmed ransomware or destructive malware | Critical — initiate ransomware playbook |
| LSASS dump or credential harvesting confirmed | Critical |
| Cobalt Strike, Metasploit, or C2 beacon detected | Critical |
| Lateral movement to additional hosts confirmed | Critical |
| Offensive tool present but no execution or network activity | High |
| Suspicious script execution, payload not yet identified | High |
| WSL / Kali tools installed by known user (insider risk indicator) | High |
| PowerShell with encoded command, no further activity | Medium |

---

## 3. Containment

### Network Contain the Endpoint — CrowdStrike Falcon

```powershell
# Requires CrowdStrike API access — use Falcon RTR or API module
# Network containment prevents all traffic except Falcon sensor communication

# Via Falcon console: Hosts > select host > Contain Host
# Via API (PowerShell CrowdStrike module):
Invoke-FalconCommand -Command "contain" -HostId "abc123deviceid456"
```

- [ ] Network-contain the endpoint in CrowdStrike Falcon immediately
- [ ] Do NOT reboot or power off — preserve volatile memory (running processes, network connections)
- [ ] Disable the affected user account in Entra ID pending investigation
- [ ] If domain-joined: reset the device's computer account password to prevent pass-the-hash reuse

```powershell
# Disable the user account in Entra ID
Connect-MgGraph -Scopes "User.ReadWrite.All"
$userId = (Get-MgUser -Filter "userPrincipalName eq 'j.smith@corp.onmicrosoft.com'").Id
Update-MgUser -UserId $userId -AccountEnabled:$false
Invoke-MgInvalidateUserRefreshToken -UserId $userId
```

### If Lateral Movement Is Suspected

- [ ] Identify all systems the user or device communicated with in the past 24 hours
- [ ] Cross-reference with Windows Event Logs (Event ID 4624, 4625, 4648) for remote logons
- [ ] Isolate additional hosts if lateral movement is confirmed
- [ ] Block the attacker's known IPs and domains at the firewall and Cisco Umbrella DNS layer

---

## 4. Investigation

### CrowdStrike Falcon — Event Search Queries (FQL)

```
// All process activity on the affected host in a 2-hour window
event_simpleName=ProcessRollup2
+ ComputerName="CORP-WS-0147"
+ timestamp>="2026-03-15T08:00:00Z"
+ timestamp<="2026-03-15T10:00:00Z"
| select ComputerName, UserName, ImageFileName, CommandLine, ParentImagePath, timestamp
| sort timestamp asc
```

```
// Network connections from the affected host
event_simpleName=NetworkConnectIP4
+ ComputerName="CORP-WS-0147"
+ timestamp>="2026-03-15T08:00:00Z"
| select ComputerName, UserName, LocalAddress, RemoteAddress, RemotePort, ImageFileName, timestamp
| sort timestamp asc
```

```
// Credential access indicators
event_simpleName IN (LsassCallerAudit, SuspiciousCredentialModuleLoad, CreateRemoteThread)
+ ComputerName="CORP-WS-0147"
+ timestamp>="2026-03-15T08:00:00Z"
| select event_simpleName, ComputerName, UserName, ImageFileName, CommandLine, timestamp
```

### CrowdStrike Falcon — Host Timeline

1. Navigate to **Investigate > Endpoint Activity > Hostname**
2. Enter the affected hostname: `CORP-WS-0147`
3. Set time range to cover the full incident window ± 2 hours
4. Filter by event types: Process, Network, File, Registry
5. Export timeline as CSV for evidence preservation

### File Artefact Analysis

If a suspicious file was written to disk:

| Step | Action |
|---|---|
| Hash the file (SHA256) | Compare against VirusTotal, CrowdStrike Threat Graph |
| Check the file path | `%TEMP%`, `%APPDATA%`, `C:\Users\Public\` are high-risk staging locations |
| Review file creation time | Compare against process execution time — was it dropped immediately before execution? |
| Static analysis | File type headers, embedded strings, PE imports (for executables) |
| CrowdStrike detection verdict | Check if the file hash is known malicious |

### Network Traffic Analysis — C2 Beaconing

```kql
DeviceNetworkEvents
| where TimeGenerated > ago(4h)
| where DeviceName == "CORP-WS-0147"
| where InitiatingProcessFileName !in~ ("chrome.exe", "msedge.exe", "outlook.exe", "svchost.exe")
| summarize
    ConnectionCount = count(),
    BytesSent = sum(SentBytes),
    FirstSeen = min(TimeGenerated),
    LastSeen = max(TimeGenerated)
    by RemoteIP, RemotePort, InitiatingProcessFileName
| where ConnectionCount > 5
| order by ConnectionCount desc
```

---

## 5. Eradication and Recovery

### Remediation Checklist

- [ ] Malicious files identified and quarantined or deleted (via CrowdStrike or Defender)
- [ ] Affected user account credentials rotated — password reset, MFA re-enrolled
- [ ] Computer account password reset (if domain-joined device)
- [ ] All known C2 IP addresses and domains blocked at firewall and Cisco Umbrella
- [ ] Network containment lifted only after clean bill of health confirmed
- [ ] Device reimaged if any of the following apply:
  - Rootkit or bootkit indicators
  - Persistent backdoor or scheduled task confirmed
  - LSASS dump confirmed — treat all credentials on the device as compromised

### Device Re-entry Criteria

Before releasing a device back to production:

- [ ] CrowdStrike Falcon showing no active detections or prevention events
- [ ] Full CIS benchmark scan passed (via `cis_batch_runner.py` or Intune compliance policy)
- [ ] All software patched to current — verify via Intune compliance report
- [ ] User re-enrolled in MFA
- [ ] Manager notified and sign-off obtained

---

## 6. Post-Incident

### Stakeholder Communication Template

> **Security Alert — Endpoint Incident: [Device Name] — [Date]**
>
> We detected and responded to a security event on [device name] used by [user]. Suspicious activity consistent with [malware / attacker tooling / unauthorised software] was identified at [time].
>
> **Actions taken:** The device was isolated from the network and is under investigation. [The user account has been temporarily suspended.] No confirmed spread to other systems at this time.
>
> **What you need to do:** [User] should not use this device until further notice. A replacement device will be arranged. All passwords used on this device should be treated as potentially compromised and changed immediately.

### Evidence to Preserve

| Artefact | Retention | Location |
|---|---|---|
| CrowdStrike Falcon detection report | 7 years | Incident evidence store |
| CrowdStrike Event Search export (CSV) | 7 years | Incident evidence store |
| Host timeline export | 7 years | Incident evidence store |
| Malicious file sample (quarantined) | Until investigation closed | Isolated malware vault |
| Sentinel KQL query exports | 7 years | Incident evidence store |
| Memory image (if acquired) | Until investigation closed | Forensic store |

### ISMS Obligations (ISO 27001:2022)

| Obligation | Control | Action |
|---|---|---|
| Record incident in information security incident register | A.5.27 | Log within 24 hours of detection with full timeline |
| Verify anti-malware controls were functioning at time of incident | A.8.7 | Document whether detection was preventive or detective |
| Assess whether a known vulnerability was exploited | A.8.8 | Cross-reference with current vulnerability scan results and patch status |
| Preserve evidence with chain-of-custody documentation | A.5.28 | Complete evidence log before any remediation activity |
| Assess whether a personal data breach occurred | A.5.26 | If credential dump or data access confirmed, initiate Privacy Act assessment |
| Conduct lessons-learned and update detection rules | A.5.27 | Review whether KQL rules or CrowdStrike custom IOAs require tuning |
| Report to senior management if Critical | A.5.26 | Immediate verbal notification; written summary within 24 hours |

### Lessons-Learned Review

- Was the endpoint patched to current OS and application versions at the time of compromise?
- Did CrowdStrike detect and prevent execution, or only alert after the fact?
- Was the malicious process whitelisted or did it abuse a legitimate signed binary (LOLBin)?
- Would application control (ASD Essential Eight Control 1) have blocked the execution?
- Was WSL or the Linux subsystem required for this user's role — if not, should it be disabled by policy?
- Did the detection rule fire in time to prevent credential theft, or only after LSASS access occurred?

---

## Related

- Ransomware response → [ransomware-response-playbook.md](ransomware-response-playbook.md)
- Account compromise (if credentials were harvested) → [account-compromise-playbook.md](account-compromise-playbook.md)
- CrowdStrike Falcon API modules → `../reference/automation/crowdstrike/`
- Kali Linux WSL hunting query → `../reference/sentinel/hunting/queries/kali/`
- Endpoint hardening benchmarks → `../reference/endpoint-hardening/benchmarks/`
- ASD Essential Eight — Application Control → `../compliance/asd-essential-eight/`
