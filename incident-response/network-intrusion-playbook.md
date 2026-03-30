# Network Intrusion Playbook

**Scenario:** Suspicious or malicious network activity detected within the corporate environment — including DNS queries to known C2 infrastructure, Cisco Umbrella security event blocks, anomalous firewall traffic, lateral movement across network segments, or VPC flow log anomalies in AWS. Correlated via Microsoft Sentinel ingesting Cisco Umbrella, Palo Alto / FortiGate firewall logs, and VPC flow telemetry.

**Severity:** Medium–Critical (escalates based on confirmed lateral movement or data staging)
**Target containment time:** 1 hour from confirmed detection

**ISO 27001:2022 Controls:** A.5.24 · A.5.25 · A.5.26 · A.5.27 · A.5.28 · A.8.16 · A.8.20 · A.8.21 · A.8.22 · A.8.23
**CIA Impact:** Confidentiality — High | Integrity — High | Availability — High

---

## 1. Detection

### Alert Triggers

| Source | Indicator |
|---|---|
| Cisco Umbrella | `DNS request blocked — known C2 domain` |
| Cisco Umbrella | `DNS tunnelling detected` |
| Cisco Umbrella | `Repeated queries to DGA (domain generation algorithm) domains` |
| Microsoft Sentinel | Umbrella security event — category: `Malware`, `C2`, `Phishing` |
| Palo Alto / FortiGate | `Intrusion Prevention System — critical alert` |
| Palo Alto / FortiGate | `Outbound connection to threat-listed IP` |
| Palo Alto / FortiGate | `Policy violation — internal east-west traffic on unexpected port` |
| Microsoft Sentinel | Firewall log — sustained outbound beaconing pattern (regular interval, fixed byte size) |
| AWS VPC Flow | High-volume outbound to unknown external IP |
| Microsoft Sentinel | `Impossible travel — internal IP accessing resources from two network segments simultaneously` |
| CrowdStrike Falcon | `Network connection to suspicious IP from endpoint process` |

### Key KQL — Cisco Umbrella C2 and Malware Blocks

```kql
Cisco_Umbrella_dns_CL
| where TimeGenerated > ago(24h)
| where EventType_s == "dnslogs"
| where Action_s == "Blocked"
| where Categories_s has_any ("Malware", "Command and Control", "Phishing", "Botnet")
| summarize
    BlockCount = count(),
    AffectedDevices = make_set(InternalIp_s),
    Domains = make_set(Domain_s)
    by Categories_s, bin(TimeGenerated, 1h)
| order by BlockCount desc
```

### Key KQL — DNS Beaconing Pattern (Regular-Interval Queries)

```kql
Cisco_Umbrella_dns_CL
| where TimeGenerated > ago(6h)
| where Action_s == "Allowed"
| summarize
    QueryCount = count(),
    IntervalSeconds = round(totimespan(max(TimeGenerated) - min(TimeGenerated)) / QueryCount / 1s)
    by InternalIp_s, Domain_s
| where QueryCount > 20
| where IntervalSeconds between (25 .. 65) // regular beaconing interval ~30–60 seconds
| order by QueryCount desc
```

### Key KQL — Firewall East-West Lateral Movement

```kql
CommonSecurityLog
| where TimeGenerated > ago(24h)
| where DeviceVendor in ("Palo Alto Networks", "Fortinet")
| where DeviceAction != "deny"
| where SourceIP startswith "10." and DestinationIP startswith "10."
| where DestinationPort in (445, 135, 139, 5985, 5986, 22, 3389, 4444, 1433, 8080)
| summarize
    ConnectionCount = count(),
    TargetPorts = make_set(DestinationPort),
    TargetHosts = make_set(DestinationIP)
    by SourceIP, bin(TimeGenerated, 15m)
| where ConnectionCount > 20 or array_length(TargetHosts) > 5
| order by ConnectionCount desc
```

### Key KQL — Sustained Outbound Beaconing from a Single Host

```kql
CommonSecurityLog
| where TimeGenerated > ago(4h)
| where DeviceVendor in ("Palo Alto Networks", "Fortinet")
| where DeviceAction != "deny"
| where DestinationIP !startswith "10." and DestinationIP !startswith "192.168." and DestinationIP !startswith "172."
| summarize
    ConnectionCount = count(),
    BytesOut = sum(SentBytes),
    FirstSeen = min(TimeGenerated),
    LastSeen = max(TimeGenerated)
    by SourceIP, DestinationIP, DestinationPort, ApplicationProtocol
| where ConnectionCount > 30
| order by ConnectionCount desc
```

### Key KQL — VPC Flow — Outbound Spike (AWS)

```kql
AWSVPCFlow
| where TimeGenerated > ago(2h)
| where FlowDirection == "egress"
| where Action == "ACCEPT"
| summarize BytesOut = sum(Bytes), FlowCount = count()
    by SrcAddr, DstAddr, DestinationPort
| where BytesOut > 50000000 // > 50MB in 2 hours
| order by BytesOut desc
```

---

## 2. Triage

### Immediate Questions

1. Which internal host(s) are generating the suspicious traffic?
2. Is the destination IP/domain a known C2, malware family, or threat-listed infrastructure?
3. Is there an active endpoint detection on the affected host (CrowdStrike alert)?
4. Is the traffic encrypted (HTTPS, DNS-over-HTTPS) or plaintext — can the payload be inspected?
5. Is this a single host or is the pattern appearing across multiple devices (worm-like spread)?
6. What process on the endpoint is generating the network traffic?
7. Are the affected hosts in a critical network segment — servers, PAWs, OT/SCADA, cloud-connected?

### Log Sources to Review

| Source | What to look for |
|---|---|
| Cisco Umbrella | DNS category, full resolution history for the domain, proxy logs if available |
| Palo Alto / FortiGate | Full session detail — source, destination, bytes, application, IPS alert detail |
| CrowdStrike Falcon | Process responsible for the network connection on the endpoint |
| Microsoft Sentinel — DeviceNetworkEvents | Process-to-IP mapping for the affected endpoint |
| AWS VPC Flow | Session-level egress detail — port, bytes, source/destination |
| WHOIS / VirusTotal | Threat classification of the destination IP and domain |

### Severity Classification

| Condition | Severity |
|---|---|
| Active C2 communication confirmed — beacon pattern with data egress | Critical |
| Lateral movement across multiple internal hosts | Critical |
| Ransomware pre-staging indicators — SMB enumeration + large internal transfers | Critical |
| Firewall IPS Critical alert — confirmed exploit attempt | High |
| DNS to known malware domain — blocked but query volume high | High |
| Single host making DNS queries to suspicious-but-uncategorised domain | Medium |
| Policy violation — unexpected port, no active malicious indicator | Medium |

---

## 3. Containment

### Endpoint-Level Containment

- [ ] Network-contain the affected endpoint in CrowdStrike Falcon immediately if endpoint is identified

```powershell
# CrowdStrike network containment via API
Invoke-FalconCommand -Command "contain" -HostId "<device-id>"
```

- [ ] If endpoint is unknown: block the source IP at the firewall and create a VLAN isolation rule

### DNS-Level Containment — Cisco Umbrella

- [ ] Add the malicious domain to the Cisco Umbrella **Security Block List** (custom block):
  1. Navigate to **Deployments > Core Identities > Internal Networks**
  2. Go to **Policies > Policy Components > Destination Lists**
  3. Add the domain to the **Block** destination list applied to the affected network identity

- [ ] If DNS tunnelling is confirmed: block the affected internal IP from making DNS queries externally via Umbrella policy

### Firewall Containment — Palo Alto / FortiGate

- [ ] Create an emergency block rule for the destination IP (both ingress and egress):

```
# Palo Alto — add to Block-C2-IPs security policy (or equivalent)
# Via CLI:
set address C2-IP-[date] ip-netmask <malicious-ip>/32
set security policy-rule Emergency-Block-C2 destination [C2-IP-[date]]
                         action deny

# FortiGate — add to address object and firewall policy
config firewall address
  edit "C2-Block-[date]"
    set subnet <malicious-ip> 255.255.255.255
  next
end
```

- [ ] Notify network team to review adjacent firewall policies for any overlapping allow rules

---

## 4. Investigation

### Identify the Affected Process (Endpoint)

```kql
// Map network connection back to the process that generated it
DeviceNetworkEvents
| where TimeGenerated > ago(4h)
| where DeviceName == "CORP-WS-0147"
| where RemoteIP == "<malicious-ip>"
| project TimeGenerated, DeviceName, InitiatingProcessFileName,
          InitiatingProcessCommandLine, InitiatingProcessParentFileName,
          RemoteIP, RemotePort, RemoteUrl
```

### Full DNS Resolution History for the Domain

```kql
Cisco_Umbrella_dns_CL
| where TimeGenerated > ago(30d)
| where Domain_s == "suspicious-domain.tld"
    or Domain_s endswith ".suspicious-domain.tld"
| summarize
    QueryCount = count(),
    Requestors = make_set(InternalIp_s),
    FirstSeen = min(TimeGenerated),
    LastSeen = max(TimeGenerated)
    by Domain_s, Action_s
| order by QueryCount desc
```

### Lateral Movement Reconstruction

```kql
// Track which internal IPs the suspect host communicated with
CommonSecurityLog
| where TimeGenerated > ago(6h)
| where SourceIP == "<affected-host-ip>"
| where DestinationIP startswith "10."
| distinct DestinationIP, DestinationPort, ApplicationProtocol
| order by DestinationPort asc
```

Cross-reference the above against Active Directory:

```powershell
# Resolve internal IPs to hostnames for each lateral movement target
$IPs = @("10.1.1.50", "10.1.1.51", "10.1.1.52")
foreach ($IP in $IPs) {
    [System.Net.Dns]::GetHostEntry($IP).HostName
}
```

### Destination IP / Domain Threat Intelligence

For each suspicious IP or domain identified:

| Check | Tool |
|---|---|
| IP/domain reputation | VirusTotal, Microsoft Defender Threat Intelligence |
| Passive DNS — what else resolves to this IP | SecurityTrails, RiskIQ |
| WHOIS — registration date, registrar | WHOIS lookup — recently registered = higher risk |
| ASN / hosting provider | Identify bulletproof hosting, known malware infrastructure providers |
| Known malware family | Cross-reference against Cisco Talos, AlienVault OTX |

---

## 5. Eradication and Recovery

### Remediation Checklist

- [ ] All C2 domains and IPs blocked at DNS (Umbrella) and firewall layers
- [ ] Affected endpoint(s) fully reimaged or confirmed clean via CrowdStrike scan
- [ ] Firewall IPS signatures updated to latest version
- [ ] Cisco Umbrella intelligence feed confirmed current — re-run DNS audit
- [ ] All internal hosts that communicated with the affected endpoint reviewed for secondary infection
- [ ] Network segmentation reviewed — confirm C2 traffic could not have crossed into server/OT segment
- [ ] AWS Security Groups reviewed — ensure no overly permissive outbound rules remain

### Network Segmentation Review

Post-incident, validate that the correct network controls are in place:

| Control | Expected State |
|---|---|
| Server segment isolated from user workstations | No direct workstation-to-server traffic on non-standard ports |
| Internet-facing DMZ isolated from internal LAN | No direct DMZ-to-internal-host communication |
| OT/SCADA network (if applicable) air-gapped from IT | No IT-OT bridging without explicit firewall policy |
| AWS VPC flow logging enabled on all VPCs | All traffic logged to CloudWatch, forwarded to Sentinel |
| Cisco Umbrella enforced for all DNS — no DNS bypass | All internal DNS resolvers point to Umbrella forwarder |

---

## 6. Post-Incident

### Stakeholder Communication Template

> **Network Security Incident — [Date]**
>
> Our monitoring detected unusual network traffic originating from [host name / IP range] at [time]. The traffic was consistent with [C2 communication / malware DNS queries / lateral movement] and has been blocked.
>
> **Actions taken:** The affected device was isolated from the network. The malicious destination [domain/IP] has been blocked at the DNS and firewall layers across the organisation. No evidence of data exfiltration has been confirmed at this time — investigation is ongoing.
>
> **What you need to do:** Users on [affected VLAN / department] may experience [brief service disruption / network speed impact] during [timeframe] while we verify the scope of the incident. No action is required from end users.

### Evidence to Preserve

| Artefact | Retention | Location |
|---|---|---|
| Firewall session logs for incident window | 7 years | Incident evidence store |
| Cisco Umbrella DNS query export | 7 years | Incident evidence store |
| CrowdStrike network event export | 7 years | Incident evidence store |
| AWS VPC flow log extracts | 7 years | Incident evidence store |
| Firewall IPS alert detail | 7 years | Incident evidence store |
| PCAP (if available from firewall or TAP) | Until investigation closed | Forensic store |
| Threat intelligence report for C2 domain/IP | 7 years | Incident evidence store |

### ISMS Obligations (ISO 27001:2022)

| Obligation | Control | Action |
|---|---|---|
| Record incident in information security incident register | A.5.27 | Log within 24 hours; include all affected hosts, IPs, and actions taken |
| Verify network monitoring controls were operating as designed | A.8.16 | Confirm Cisco Umbrella, firewall logging, and Sentinel ingestion were active during the incident |
| Assess whether network segmentation controls failed | A.8.22 | Document whether the intrusion crossed segment boundaries — raise corrective action if so |
| Verify network service security controls were effective | A.8.21 | Assess whether firewall policies and IPS signatures were current and appropriately scoped |
| Preserve evidence with chain-of-custody documentation | A.5.28 | Document all log exports and forensic collections before any remediation |
| Assess whether a personal data breach occurred | A.5.26 | If confirmed data egress involved personal data, initiate Privacy Act breach assessment |
| Conduct lessons-learned and update detection rules | A.5.27 | Review KQL detection queries, Umbrella policies, and IPS signatures — update as required |
| Report to senior management if Critical | A.5.26 | Immediate verbal notification; written summary within 24 hours |

### Lessons-Learned Review

- Did Cisco Umbrella block the DNS query at first request, or did multiple connections succeed before blocking?
- Was the Sentinel Umbrella connector ingesting data in real time, or was there a delay?
- Was the affected host patched — could a known vulnerability have facilitated the initial intrusion?
- Did the firewall IPS detect the C2 traffic pattern — if not, are IPS signatures current?
- Was network segmentation effective — did the intrusion stay in a single segment or cross boundaries?
- Could DNS-over-HTTPS (DoH) have bypassed Umbrella inspection — is DoH blocked at the firewall level?
- If AWS VPC was involved — was VPC flow logging and GuardDuty enabled on the affected account?

---

## Related

- Malicious code execution (endpoint layer) → [malicious-code-execution-playbook.md](malicious-code-execution-playbook.md)
- Data exfiltration response → [data-exfiltration-response-playbook.md](data-exfiltration-response-playbook.md)
- Cloud account compromise (AWS layer) → [cloud-account-compromise-playbook.md](cloud-account-compromise-playbook.md)
- Cisco Umbrella GUI guide → `../reference/network-security/guides/cisco-umbrella-gui-guide.md`
- Network security reference → `../reference/network-security/`
- Sentinel Cisco Umbrella workbook → `../reference/sentinel/workbooks/cisco/`
- AWS VPC Flow and GuardDuty → `../reference/sentinel/manual/aws/`
