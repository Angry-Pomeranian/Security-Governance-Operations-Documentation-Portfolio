# Cisco Meraki API — Operational Playbook

## Overview

This playbook defines step-by-step procedures for security operations involving the Meraki API. It covers the four primary operational scenarios: **network isolation**, **IP blocking**, **event log investigation**, and **client activity investigation**. Each procedure includes the API calls, Python client methods, and validation steps.

All procedures assume the `meraki_api_client.py` script is available and the environment is configured with valid credentials.

---

## Prerequisites

```bash
# Confirm environment is configured
python3 meraki_api_client.py --action list-orgs

# Expected: Organisation name and ID printed to stdout
```

Required environment variables:
- `MERAKI_API_KEY`
- `MERAKI_ORG_ID`
- `MERAKI_NETWORK_ID` (for network-specific operations)

---

## Procedure 1 — Network Isolation (VLAN Isolation)

**Trigger:** Active incident requiring containment of a network segment (e.g. ransomware spread, rogue device, confirmed intrusion).

**Impact:** All inbound and outbound traffic for the specified VLAN CIDR is blocked at the MX appliance. Contained devices retain DHCP leases but cannot communicate with other segments or the internet.

**SLA target:** Complete within 5 minutes of containment decision.

---

### Step 1.1 — Confirm the target VLAN

```bash
python3 meraki_api_client.py --action list-vlans --network-id L_XXXXXXXXX
```

Note the VLAN ID and CIDR of the segment to be isolated (e.g. `10.10.20.0/24`).

### Step 1.2 — Review current firewall rules (pre-change snapshot)

```bash
python3 meraki_api_client.py --action get-firewall-rules --network-id L_XXXXXXXXX \
    --output pre-isolation-rules.json
```

Save this file. It is required to **reverse the isolation**.

### Step 1.3 — Apply VLAN isolation

```bash
python3 meraki_api_client.py --action isolate-vlan \
    --network-id L_XXXXXXXXX \
    --cidr 10.10.20.0/24 \
    --comment "INCIDENT-2026-042: Ransomware containment"
```

This prepends two DENY rules to the ruleset:
1. `deny` all traffic **destined for** `10.10.20.0/24`
2. `deny` all traffic **sourced from** `10.10.20.0/24`

### Step 1.4 — Verify isolation is applied

```bash
python3 meraki_api_client.py --action get-firewall-rules --network-id L_XXXXXXXXX
```

Confirm the two INCIDENT rules appear at the **top** of the ruleset (rules are evaluated top-down; first match wins).

### Step 1.5 — Validate in Meraki Dashboard

- Navigate to: `Security & SD-WAN → Firewall`
- Confirm the two DENY rules are listed at position 1 and 2
- Check **Syslog** is enabled on both rules

### Step 1.6 — Document in incident ticket

Record:
- Time applied (UTC)
- VLAN CIDR isolated
- Incident ID referenced in rule comment
- Pre-change snapshot file name
- Approving SOC lead

---

### Reverting Isolation (Post-Incident)

```bash
# Restore rules from pre-change snapshot
python3 meraki_api_client.py --action restore-firewall-rules \
    --network-id L_XXXXXXXXX \
    --rules-file pre-isolation-rules.json
```

> Only reverse isolation after written approval from the incident lead and confirmation that the affected segment has been remediated.

---

## Procedure 2 — Block a Specific IP Address

**Trigger:** Known malicious IP address identified (threat intelligence hit, C2 beacon, brute-force source) requiring immediate firewall block.

**Impact:** All traffic sourced from the specified IP is dropped at the MX appliance. Syslog entry generated for every blocked packet.

---

### Step 2.1 — Validate the IP against threat intelligence

Before blocking, confirm the IP is not a legitimate internal or partner address:

```bash
# Check if IP is in any VLAN range
python3 meraki_api_client.py --action list-vlans --network-id L_XXXXXXXXX | grep -i "10\."

# Cross-reference against threat feed (manual step)
# Example: query VirusTotal, Shodan, or internal IOC list
```

### Step 2.2 — Apply the block rule

```bash
python3 meraki_api_client.py --action block-ip \
    --network-id L_XXXXXXXXX \
    --ip 198.51.100.42 \
    --comment "INCIDENT-2026-042: C2 beacon source - TI match"
```

### Step 2.3 — Verify the block

```bash
python3 meraki_api_client.py --action get-firewall-rules --network-id L_XXXXXXXXX | head -30
```

The DENY rule for `198.51.100.42/32` should appear at position 1.

### Step 2.4 — Monitor for continued attempts

```bash
python3 meraki_api_client.py --action get-events \
    --network-id L_XXXXXXXXX \
    --event-type firewall \
    --timespan 3600
```

Confirm the IP is generating `firewall` event entries indicating the block is active.

---

## Procedure 3 — Event Log Investigation

**Trigger:** Suspicious activity alert, SOC triage request, or threat hunt requiring network event context.

---

### Step 3.1 — Pull recent events (last 24 hours)

```bash
python3 meraki_api_client.py --action get-events \
    --network-id L_XXXXXXXXX \
    --timespan 86400 \
    --output events-$(date +%Y%m%d).json
```

### Step 3.2 — Filter by event type

**Authentication failures:**
```bash
python3 meraki_api_client.py --action get-events \
    --network-id L_XXXXXXXXX \
    --event-type auth \
    --timespan 3600
```

**VPN connectivity changes:**
```bash
python3 meraki_api_client.py --action get-events \
    --network-id L_XXXXXXXXX \
    --event-type vpn_connectivity_change \
    --timespan 86400
```

**DHCP leases (new device detection):**
```bash
python3 meraki_api_client.py --action get-events \
    --network-id L_XXXXXXXXX \
    --event-type dhcp_lease \
    --timespan 86400
```

### Step 3.3 — Filter events by client MAC address

```bash
python3 meraki_api_client.py --action get-events \
    --network-id L_XXXXXXXXX \
    --client-mac aa:bb:cc:dd:ee:ff \
    --timespan 86400
```

### Step 3.4 — Export events for Sentinel ingestion

```bash
python3 meraki_api_client.py --action get-events \
    --network-id L_XXXXXXXXX \
    --timespan 604800 \
    --output meraki-events-weekly.json

# Forward to Log Analytics (requires az CLI and workspace configuration)
python3 meraki_api_client.py --action forward-to-sentinel \
    --events-file meraki-events-weekly.json
```

### Step 3.5 — Correlate in Sentinel

KQL query to find clients that changed networks rapidly (lateral movement indicator):

```kql
MerakiEvents_CL
| where TimeGenerated > ago(24h)
| where EventType_s in ("association", "disassociation")
| summarize
    Networks = dcount(NetworkId_s),
    Events = count()
    by ClientMac_s, bin(TimeGenerated, 1h)
| where Networks > 2
| order by Events desc
```

---

## Procedure 4 — Client Activity Investigation

**Trigger:** Suspected compromised device, lateral movement investigation, or rogue device detection.

---

### Step 4.1 — Look up a client by MAC address or IP

```bash
python3 meraki_api_client.py --action find-client \
    --network-id L_XXXXXXXXX \
    --mac aa:bb:cc:dd:ee:ff
```

Returns: client ID, description, IP address, VLAN, associated AP, usage statistics.

### Step 4.2 — Get full client history

```bash
python3 meraki_api_client.py --action get-events \
    --network-id L_XXXXXXXXX \
    --client-mac aa:bb:cc:dd:ee:ff \
    --timespan 604800 \
    --output client-history.json
```

### Step 4.3 — List all clients currently on a device

```bash
python3 meraki_api_client.py --action device-clients \
    --serial Q2KN-XXXX-XXXX
```

### Step 4.4 — Check for unusual data usage (top clients)

```bash
python3 meraki_api_client.py --action get-clients \
    --network-id L_XXXXXXXXX \
    --timespan 86400 | sort -k usage
```

High usage by an unexpected device may indicate data exfiltration.

### Step 4.5 — Isolate a specific client (VLAN-level)

If a specific device's IP is known and assigned to an isolated VLAN, use Procedure 1 (VLAN isolation). If the device is on a shared VLAN:

1. Identify the device's VLAN CIDR
2. Evaluate whether other devices on the VLAN are affected
3. If isolation would impact other users, block the specific device IP only (Procedure 2)

---

## Procedure 5 — Device Inventory and Status Audit

**Trigger:** Periodic asset review, onboarding/offboarding, or post-incident asset enumeration.

---

### Step 5.1 — Export full device inventory

```bash
python3 meraki_api_client.py --action list-devices \
    --org-id 123456 \
    --output inventory-$(date +%Y%m%d).json
```

### Step 5.2 — Check for offline devices

```bash
python3 meraki_api_client.py --action device-statuses \
    --org-id 123456 | grep offline
```

Persistent offline devices may indicate:
- Device failure
- Network connectivity loss
- Physical removal (potential theft or tampering)

### Step 5.3 — Check uplink status

```bash
python3 meraki_api_client.py --action uplink-statuses \
    --org-id 123456
```

Multiple uplink failures in a short window may indicate upstream network issues or a DDoS targeting network infrastructure.

---

## Change Management Notes

All API-driven firewall rule changes are:

1. **Logged** — Meraki Dashboard logs all API-initiated changes under `Organisation → Change log`
2. **Attributed** — Changes are attributed to the API key owner's account
3. **Reversible** — Always capture a pre-change snapshot before modifying rules
4. **Documented** — Reference an incident or change ticket ID in the rule `comment` field

**Change log path:** `Dashboard → Organisation → Change log → filter by "API"`

---

## Related

- [Python Client Script](meraki_api_client.py) — Client used in all procedures above.
- [Implementation Guide](implementation-guide.md) — Authentication, rate limiting, pagination details.
- [Troubleshooting Guide](troubleshooting-guide.md) — Error codes and remediation.
- [Network Intrusion Playbook](../../../../../incident-response/network-intrusion-playbook.md) — Full incident response playbook referencing network isolation.
