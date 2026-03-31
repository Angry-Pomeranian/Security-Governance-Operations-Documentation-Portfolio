# Case Study Security Event Investigation Methodology

A structured approach to investigating security alerts from SIEM and EDR platforms — from initial alert review through to threat determination, customer communication, and escalation decision.

This methodology reflects the operational workflow of a security operations function working with assigned customer environments, as practised in managed detection and response (MDR) engagements.

---

## Overview

```
Alert Received
      │
      ▼
 1. Initial Triage
      │
      ▼
 2. Log Source Verification
      │
      ▼
 3. Context Enrichment
      │
      ▼
 4. Threat Determination
      │
      ├── False Positive ──────────────────────► Document + Close
      │
      ├── Benign True Positive ─────────────────► Customer Notification (informational)
      │
      └── Malicious / Suspected Incident ───────► Escalation Decision
                                                       │
                                                  ▼
                                             Initiate Playbook
```

---

## Phase 1: Initial Triage

**Time target:** Complete within 15 minutes of alert receipt.

### Alert Review Checklist

- [ ] Read the full alert title, description, and rule logic
- [ ] Identify the affected entity (user, device, IP, application)
- [ ] Identify the alert source (Sentinel analytic rule, CrowdStrike, Defender, Proofpoint, etc.)
- [ ] Check the alert severity and confidence level
- [ ] Check if this alert has fired before for this entity (alert history)
- [ ] Check if there are correlated alerts open for the same entity at the same time

### Initial Severity Assessment

| Indicator | Suggested severity |
|---|---|
| Known-bad infrastructure (confirmed IOC) | High |
| Admin account or privileged service affected | High |
| Active data access or transfer observed | High |
| Anomalous behaviour with no clear benign explanation | Medium |
| Behaviour consistent with known admin tooling | Low |
| Repeated pattern for this user, previously investigated as benign | Low / False positive |

### Quick Reference: Common Noisy Alerts

| Alert | Common false positive cause | Verification step |
|---|---|---|
| Impossible travel | VPN exit nodes, cloud service proxies | Check IP reputation and ASN |
| Brute force success | Automated service account re-auth after password rotation | Check account type and service context |
| Anomalous sign-in | New device or location after travel | Confirm with user out-of-band if required |
| Mass file access | Backup job, antivirus scan, search indexer | Check process name in endpoint telemetry |
| DNS query to suspicious domain | CDN, ad network, legitimate SaaS | Check domain age, category, and resolution |

---

## Phase 2: Log Source Verification

Before drawing conclusions, confirm the data is reliable.

### Verification Questions

1. Is the data source actively ingesting? (Check last event timestamp in Sentinel)
2. Are there obvious data quality issues? (Duplicate events, missing fields, incorrect parsing)
3. Is the entity identifier correct? (UPN vs SAM account name vs email — confirm they match)
4. Is the timestamp in UTC and aligned with expected timezone?
5. Has the underlying detection rule been recently modified? (New rule = higher false positive rate)

### Sentinel Data Source Health Check (KQL)

```kql
// Check last ingest time per table
union withsource=TableName *
| summarize LastEvent = max(TimeGenerated) by TableName
| where LastEvent < ago(2h)
| order by LastEvent asc
```

```kql
// Check event volume anomaly for a specific source
SecurityEvent
| where TimeGenerated > ago(48h)
| summarize EventCount = count() by bin(TimeGenerated, 1h)
| render timechart
```

---

## Phase 3: Context Enrichment

Gather additional context before making a threat determination.

### Entity Context — User

| Data point | Source | Purpose |
|---|---|---|
| Job title and department | HR system / Entra ID | Does behaviour match role? |
| Manager | Entra ID | Escalation contact if needed |
| Recent access history | Sign-in logs | What is their baseline? |
| Device compliance state | Intune | Managed vs unmanaged device |
| Active incidents | SIEM / ticketing | Already under investigation? |
| Risk score | Entra ID Identity Protection | Elevated risk events? |

### Entity Context — Device

| Data point | Source | Purpose |
|---|---|---|
| Device owner | Intune / CrowdStrike | Who does this device belong to? |
| OS version and patch level | Intune | Vulnerable to known CVEs? |
| Last seen online | CrowdStrike | Still active? |
| Active processes at alert time | CrowdStrike Falcon telemetry | What was running? |
| Network connections at alert time | CrowdStrike Falcon | C2 communication? |
| Recent file system changes | CrowdStrike Falcon | Malware dropped? |

### Entity Context — IP Address

```kql
// Enrich IP with geolocation and threat intelligence
let SuspiciousIP = "x.x.x.x";
ThreatIntelligenceIndicator
| where NetworkIP == SuspiciousIP
| project TimeGenerated, ThreatType, Description, Confidence, ExpirationDateTime
```

External enrichment sources:
- VirusTotal — IP reputation, passive DNS, related samples
- Shodan — exposed services on the IP
- WHOIS — registrar, organisation, allocation date
- AbuseIPDB — abuse reports

### Entity Context — Domain / URL

- Domain age (newly registered domains are higher risk)
- Registrar and registration details
- DNS resolution history (passive DNS)
- VirusTotal — associated malware, URLs, files
- Cisco Umbrella investigate — category and risk score

---

## Phase 4: Threat Determination

Based on triage and enrichment, classify the alert.

### Decision Framework

| Classification | Criteria | Action |
|---|---|---|
| **False positive** | Known benign behaviour; root cause fully explained; no attacker involvement | Close with documentation; tune rule if recurring |
| **Benign true positive** | Alert fired correctly, but activity is authorised (e.g., admin task) | Close; document; notify customer if useful |
| **Suspicious — monitor** | Insufficient data to confirm; no immediate risk indicators | Add to watchlist; monitor for 24–48 hours |
| **Suspected incident** | Unexplained activity with plausible malicious interpretation | Escalate; initiate relevant IR playbook |
| **Confirmed incident** | Malicious activity confirmed | Escalate; initiate playbook; notify customer immediately |

### Threat Determination Template

```
Alert: [Alert name]
Entity: [User/Device/IP]
Alert time: [UTC timestamp]
Investigation time: [Duration]

Log source verified: Yes / No
Data quality issues: [None / Describe]

Context summary:
- [Key finding 1]
- [Key finding 2]
- [Key finding 3]

Determination: [False positive / Benign TP / Suspicious / Suspected incident / Confirmed incident]
Confidence: [Low / Medium / High]

Rationale:
[2–3 sentences explaining the determination]

Next action: [Close / Monitor / Escalate / Initiate playbook]
```

---

## Phase 5: Customer Communication

### Communication Principles

- **Clarity over jargon** — explain what happened in plain language before technical detail
- **Action-oriented** — always answer: *what do you need to do?*
- **Proportionate** — match communication urgency to actual severity
- **Proactive** — notify before the customer asks, not after

### Communication Templates by Determination Type

**False positive — no action required:**

> We investigated an alert for [user/system] triggered on [date]. After reviewing [log sources], we determined this was a false positive caused by [root cause]. No malicious activity was identified. No action is required from you at this time.

**Benign true positive — informational:**

> We detected [event] for [user/system] on [date]. Investigation confirmed this was [authorised activity — e.g., administrative task by IT team]. This alert is now closed. We recommend [optional recommendation].

**Suspected or confirmed incident — action required:**

> We have identified a [severity] security event affecting [user/system]. [One sentence: what happened.] We have [containment actions taken]. We need you to [specific actions required from customer] by [timeframe].

> We will provide an update by [time]. If you have any immediate questions, contact us at [channel].

### Escalation Decision Tree

```
Is the activity malicious or confirmed as an active incident?
├── Yes ──► Is it contained?
│           ├── Yes ──► Notify customer; document in IR ticket
│           └── No  ──► Immediate escalation to senior analyst + customer call
└── No  ──► Is it suspicious with insufficient data?
            ├── Yes ──► Place under monitoring; set review reminder 24h
            └── No  ──► Close as false positive or benign TP; document
```

---

## Phase 6: Documentation

Every investigated alert — regardless of outcome — requires documentation.

### Minimum Documentation Standard

| Field | Required content |
|---|---|
| Alert ID | Reference from SIEM / ticketing system |
| Alert name | As generated by detection platform |
| Time | Alert time (UTC) + investigation start/close time |
| Entity | User, device, IP, or resource affected |
| Log sources reviewed | List all sources checked |
| Key findings | Bullet summary of what was found |
| Determination | Classification from Phase 4 |
| Actions taken | What was done (contain, notify, close, monitor) |
| Customer notified | Yes / No — method and time |
| Rule tuning required | Yes / No — if yes, link to tuning ticket |

### Detection Rule Improvement Feedback

When an alert generates a false positive, document:
- Why did the rule fire?
- What context would have prevented the false positive?
- Proposed tuning: adjust threshold, add exclusion, modify logic
- Submit to detection engineering for review

---

## Related

- Sentinel detection operations → [sentinel-detection-operations-foundation.md](sentinel-detection-operations-foundation.md)
- Account compromise playbook → `../../incident-response/account-compromise-playbook.md`
- Ransomware response playbook → `../../incident-response/ransomware-response-playbook.md`
- Phishing investigation playbook → `../../incident-response/phishing-investigation-playbook.md`
- Data exfiltration playbook → `../../incident-response/data-exfiltration-response-playbook.md`
