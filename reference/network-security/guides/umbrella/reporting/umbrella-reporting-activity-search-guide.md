# Umbrella Reporting & Activity Search Guide

## Overview

Cisco Umbrella provides several reporting surfaces: the Overview dashboard, Activity Search, scheduled reports, and the Top Identities / Top Destinations views. This guide explains how to navigate each, how to interpret findings, and how to present security data to non-technical clients.

---

## Reporting Architecture

Umbrella logs every DNS query processed by the organisation. All logs are available for 30 days in the standard plan (longer in Enterprise/SIG). The logging pipeline:

```
DNS query → Umbrella resolver → Policy evaluation → Log entry
                                     ↓
                            Reporting → Activity Search
                                     ↓
                           Overview Dashboard (aggregated)
                                     ↓
                         Scheduled Reports (email delivery)
```

---

## The Overview Dashboard

**Location:** Reporting → Overview

The Overview dashboard provides a real-time summary of DNS activity across the organisation.

### Dashboard Sections

**Total Requests:**
The total count of DNS queries processed in the selected time range. Provides a baseline for the client's normal query volume. An unusual spike may indicate:
- DNS-based C2 beaconing (rapid high-volume queries to a domain)
- A misconfigured application making excessive DNS queries
- A new large device group added to Umbrella coverage

**Security — Threats Blocked:**
Queries blocked by security categories (malware, phishing, C2, cryptomining). Key metrics:

| Metric | What it tells you |
|---|---|
| Total security blocks | Overall threat exposure volume |
| Top blocked security domains | Specific malicious domains being queried |
| Block trend over time | Whether threat activity is increasing |

**Content — Policy Blocks:**
Queries blocked by content category policy (adult content, gambling, social media, etc.). Useful for compliance reporting and demonstrating policy enforcement.

**Activity by Identity:**
Breaks down query volume by roaming client, network identity, or AD user. Use this to identify the identities generating the most traffic (useful for anomaly detection).

### Time Range Selection

Use the time range picker (top right) to focus on:
- Last 1 hour — real-time incident investigation
- Last 24 hours — daily review
- Last 7 days — weekly health check
- Last 30 days — monthly reporting period

---

## Activity Search

**Location:** Reporting → Activity Search

Activity Search is the most powerful investigative tool in Umbrella. It allows filtered queries against the full DNS log.

### Running a Search

1. **Reporting → Activity Search**
2. Set the time range
3. Apply filters:

| Filter | Description | Example use |
|---|---|---|
| Identity | Filter by specific roaming computer, network, or AD user | Investigate a specific user's browsing activity |
| Domain | Search for queries to a specific domain | Find all devices that queried a suspicious domain |
| Action | Filter by Allow / Block | Show only blocked queries |
| Category | Filter by security or content category | Show all C2 queries blocked this week |
| Policy Name | Filter by which policy applied | Audit what the Default Policy is allowing |

### Key Activity Search Columns

| Column | Meaning |
|---|---|
| Timestamp | When the DNS query occurred |
| Identity | Which device/user/network made the query |
| Domain | The domain queried |
| Action | Allow / Block |
| Blocked Category | The category that caused the block (if blocked) |
| Destination List | If a destination list caused the action |
| Policy | Which Umbrella policy applied |
| Public IP | Source public IP of the query |

### Pivoting in Activity Search

Activity Search supports pivoting — click on a domain name or identity to filter the view instantly:
- Click a domain → see all identities that queried that domain
- Click an identity → see all domains that identity has queried
- Click a category → see all domains blocked in that category

Use pivoting during incident investigation to rapidly understand scope: "Which other devices queried this domain?" → click the domain → filter by Action = All → see every identity that resolved it.

---

## Top Reports

**Location:** Reporting → Overview → (individual report widgets)

### Top Security Domains

Shows the domains most frequently blocked by security categories. These are domains Umbrella's threat intelligence has classified as malicious and that your users or devices are repeatedly querying.

**What to look for:**
- A single domain appearing many times from multiple identities → potentially a widespread phishing campaign or malware present on multiple devices
- A single domain appearing many times from one identity → potential malware C2 on a specific device; investigate that device

### Top Identities

Shows which identities (roaming clients, networks, users) generate the most DNS traffic, the most blocks, or the most security-category hits.

**What to look for:**
- An identity with an abnormally high security block rate → the user may be engaging with risky sites, or malware on their device is making DNS queries
- An identity appearing on the Top Threats list that is a server (servers should not have a high threat rate) → potential compromise

### Top Blocked Categories

Shows which content and security categories are generating the most blocks. Useful for:
- Demonstrating ROI to clients ("Umbrella blocked 1,200 malware queries this month")
- Identifying whether a specific category is generating excessive false positives (if the top blocked category is "Newly Seen Domains" and users are frequently complaining about blocks, consider moving it from Block to Warn)

---

## Scheduled Reports

**Location:** Reporting → Reports → Scheduled Reports

Umbrella can automatically generate and email weekly or monthly summary reports.

### Setting Up a Scheduled Report

1. **Reporting → Reports → Scheduled Reports → Add**
2. Configure:
   | Field | Value |
   |---|---|
   | Report name | `[ClientName] Monthly Security Summary` |
   | Report type | Executive Summary (for clients) or Detailed Security Report (for admin review) |
   | Frequency | Weekly / Monthly |
   | Delivery day | First day of the month (for monthly) |
   | Recipients | Client's IT contact email and/or MSP account manager |
3. Click **Save**

**Available scheduled report types:**
| Report | Content |
|---|---|
| Executive Summary | High-level block counts, top threats, trend graphs — suitable for client non-technical stakeholders |
| Security Activity | Detailed security category blocks, top malicious domains |
| Content Activity | Content filter blocks by category |
| Bandwidth | DNS query volume and top destinations (useful for identifying data exfiltration patterns) |

---

## Presenting Findings to Clients

When presenting Umbrella data to non-technical clients, focus on outcomes and risk, not raw numbers.

### Monthly Security Review — Suggested Format

**1. Headline metric:**
> "Umbrella processed [X] DNS queries from your organisation this month and blocked [Y] queries to malicious or policy-violating destinations."

**2. Threats stopped:**
> "Of the [Y] blocked queries, [Z] were in the highest-risk categories — malware, phishing, and command-and-control."

Show the Top Security Domains graph — point out the most frequently blocked domain and what it was classified as.

**3. Activity anomalies (if any):**
If any identities showed unusually high security activity:
> "We noticed [Device X] made [N] queries to domains classified as malware this month. We investigated and [found malware / confirmed false positive / took action]."

**4. DNS bypass attempts (if tracked):**
If you are logging firewall deny events for port 53:
> "Our firewall logs show [N] attempts to bypass Umbrella by querying alternate DNS resolvers. These were blocked at the firewall."

**5. Recommendations:**
Based on what you found:
- Are there categories that should move from "Log" to "Block"?
- Are there users with high security activity who need training?
- Are there stale allow list entries to review?

---

## Activity Search — Incident Investigation Workflow

When a security incident is suspected or reported, use Activity Search as the starting point for DNS-layer investigation.

### Scenario: User Reports Possible Phishing Click

1. **Activity Search** → filter by: Identity = [user], last 24 hours, Action = All
2. Look for queries to domains that were blocked (phishing/malware category) and also any that were allowed — the user may have clicked a link before Umbrella's threat intelligence updated
3. If you find a suspicious allowed domain: look up in Talos to check current classification
4. **Pivot:** click the suspicious domain → filter all identities → see if other users queried it
5. If multiple users queried it: check if TRAP (if using Proofpoint) auto-pulled the email, or alert the security team for broader response

### Scenario: Suspected Malware C2 Beaconing

DNS beaconing characteristics:
- High volume of queries to the same domain in short intervals
- Domain has a random-looking subdomain (DGA — Domain Generation Algorithm): `a8f3k1.malware-c2.com`
- Domain classified as "malware" or "C2" but also some queries got through before classification

1. **Activity Search** → filter by: Category = Command and Control Callbacks, last 7 days
2. Look for domains with high query volume from a single identity
3. Note the first time the domain appeared in logs — this is the earliest possible infection time
4. **Pivot** to the identity — see all their activity around the same time
5. Check if the domain also appeared as "Allowed" before the block was applied — if so, the device may have communicated with C2 before Umbrella blocked it; escalate to incident response

### Sentinel Integration

If Umbrella is integrated with Microsoft Sentinel (via the Cisco Umbrella data connector), DNS logs are available for cross-correlation:

```kql
// Find Umbrella-blocked domains queried by multiple devices
Cisco_Umbrella_dns_CL
| where Action_s == "blocked"
| where UrlCategory_s contains "malware" or UrlCategory_s contains "phishing"
| summarize DeviceCount = dcount(ExternalIp_s), QueryCount = count() by Domain_s
| where DeviceCount > 3
| order by QueryCount desc
```

---

## Exporting Data

### CSV Export from Activity Search

1. Run an Activity Search query with the desired filters
2. Click **Export → CSV** (top right of results)
3. Maximum export: 10,000 rows per export; use a narrow time range for large environments

### API-Based Export

For automated log export (e.g. daily export to SIEM or long-term storage):

```bash
# Export Activity Search results via Umbrella Reporting API
curl -X GET \
  "https://reports.api.umbrella.com/v2/organizations/{orgId}/activity?from=-1days&limit=10000&offset=0" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json"
```

Use the Umbrella Reporting API key (Admin → API Keys → Reporting) with the `reports:read` scope.

---

## Related

- [Policy Management and Precedence Guide](../administration/policy-management-and-precedence-guide.md) — Policy Tester for investigating specific block events.
- [Unexpected Blocks Troubleshooting Guide](../troubleshooting/unexpected-blocks-troubleshooting-guide.md) — Using Activity Search to confirm resolution.
- [Active Directory Integration Guide](../administration/active-directory-integration-guide.md) — Required for user-level attribution in reports.
- Sentinel Cisco Umbrella connector — `../../../../../sentinel/Manual/Cisco/Umbrella/`
