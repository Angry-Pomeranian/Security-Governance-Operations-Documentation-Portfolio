# Cisco Meraki API v1 — Implementation Guide

## Overview

The Cisco Meraki Dashboard API v1 provides RESTful access to the full Meraki management plane — organisations, networks, devices, clients, event logs, firewall rules, VLANs, and uplink status. This guide covers everything required to go from API key to a working integration: authentication, rate limiting, pagination, and the key endpoint patterns used in security operations.

**Base URI:** `https://api.meraki.com/api/v1`
**Format:** JSON over HTTPS
**Documentation:** https://developer.cisco.com/meraki/api-v1/

---

## Prerequisites

| Requirement | Notes |
|---|---|
| Meraki Dashboard access | Organisation Administrator or Network Administrator role |
| API key | Generated per user account — see below |
| Python 3.9+ | For the included `meraki_api_client.py` script |
| `requests` library | `pip install requests` |
| Organisation ID | Retrieved from the API or Dashboard URL |

---

## Step 1 — Enable API Access

1. Sign in to the Meraki Dashboard: `https://dashboard.meraki.com`
2. Navigate to **Organisation → Settings**
3. Scroll to **Dashboard API access**
4. Enable: **Enable access to the Cisco Meraki Dashboard API**
5. Save

---

## Step 2 — Generate an API Key

1. Click your username (top-right) → **My Profile**
2. Scroll to **API access**
3. Click **Generate new API key**
4. Copy the key immediately — it is only shown once
5. Store it in a secrets manager, environment variable, or vault — never in source code

**Least-privilege recommendation:** Create a dedicated service account with the minimum required role:

| Integration type | Required role |
|---|---|
| Read-only monitoring | Network Reader |
| Event log ingestion | Network Reader |
| Firewall rule updates (incident response) | Network Administrator |
| Full automation | Organisation Administrator |

---

## Step 3 — Authenticate API Requests

Every request must include the API key in the `X-Cisco-Meraki-API-Key` header:

```http
GET https://api.meraki.com/api/v1/organizations
X-Cisco-Meraki-API-Key: YOUR_API_KEY
Content-Type: application/json
```

**Python example:**

```python
import requests

MERAKI_BASE = "https://api.meraki.com/api/v1"
API_KEY = os.environ["MERAKI_API_KEY"]

session = requests.Session()
session.headers.update({
    "X-Cisco-Meraki-API-Key": API_KEY,
    "Content-Type": "application/json",
    "Accept": "application/json",
})

response = session.get(f"{MERAKI_BASE}/organizations")
response.raise_for_status()
orgs = response.json()
```

---

## Step 4 — Discover Organisation and Network IDs

Most API calls require an `organizationId` or `networkId`. Retrieve them programmatically:

**Get all organisations:**
```
GET /organizations
```

**Get networks in an organisation:**
```
GET /organizations/{organizationId}/networks
```

**Response example:**
```json
[
  {
    "id": "L_123456789",
    "organizationId": "123456",
    "name": "HQ Network",
    "timeZone": "Australia/Sydney",
    "tags": [],
    "type": "combined",
    "productTypes": ["appliance", "switch", "wireless"]
  }
]
```

---

## Step 5 — Rate Limiting

The Meraki API enforces rate limits to protect platform stability:

| Limit | Value |
|---|---|
| Default rate | 10 requests/second per organisation |
| Sustained burst | Short bursts above 10 req/s may be tolerated |
| Rate limit response | `429 Too Many Requests` |
| Retry guidance | Respect the `Retry-After` response header |

**429 handling pattern:**
```python
import time

def request_with_retry(session, method, url, max_retries=5, **kwargs):
    for attempt in range(max_retries):
        response = session.request(method, url, **kwargs)
        if response.status_code == 429:
            wait = int(response.headers.get("Retry-After", 2 ** attempt))
            print(f"Rate limited. Waiting {wait}s...")
            time.sleep(wait)
            continue
        response.raise_for_status()
        return response.json()
    raise RuntimeError(f"Max retries exceeded: {url}")
```

---

## Step 6 — Pagination

Meraki list endpoints return paginated results. Pagination is indicated via `Link` response headers — not via `page` query parameters.

**Headers:**
```
Link: <https://api.meraki.com/api/v1/networks/L_123/events?perPage=100&startingAfter=xxx>; rel=next
```

**Query parameters that control pagination:**

| Parameter | Description |
|---|---|
| `perPage` | Results per page. Max varies by endpoint; 1000 is common |
| `startingAfter` | Cursor for forward pagination (from previous response) |
| `endingBefore` | Cursor for backward pagination |

**Pagination loop:**
```python
def paginate(session, base_url, endpoint, params=None):
    results = []
    url = f"{base_url}{endpoint}"
    params = params or {}

    while url:
        response = session.get(url, params=params)
        response.raise_for_status()
        results.extend(response.json())

        link = response.headers.get("Link", "")
        url = None
        params = {}

        if "rel=next" in link:
            for part in link.split(","):
                if "rel=next" in part:
                    url = part.split(";")[0].strip().strip("<>")
                    break

    return results
```

---

## Step 7 — Key Endpoint Patterns

### Organisation inventory

```
GET /organizations
GET /organizations/{orgId}/networks
GET /organizations/{orgId}/devices
GET /organizations/{orgId}/devices/statuses
GET /organizations/{orgId}/uplinks/statuses
```

### Network event logs

```
GET /networks/{networkId}/events

Query parameters:
  timespan         = seconds (max 604800 — 7 days)
  perPage          = up to 1000
  includedEventTypes[] = filter by type (e.g. "vpn_connectivity_change", "association", "disassociation")
  excludedEventTypes[] = exclude event types
  clientMac        = filter by client MAC address
  deviceSerial     = filter by device serial
```

**Common event types for security operations:**

| Event Type | Trigger |
|---|---|
| `association` | Client associated to wireless AP |
| `disassociation` | Client disconnected |
| `auth` | 802.1X authentication |
| `vpn_connectivity_change` | Site-to-site VPN state change |
| `firewall` | L3 firewall rule hit |
| `arp_table_change` | ARP table entry change (rogue device detection) |
| `port_status` | Switch port up/down |
| `dhcp_lease` | DHCP lease granted/expired |

### Client investigation

```
GET /networks/{networkId}/clients?timespan=86400&perPage=1000
GET /networks/{networkId}/clients/{clientId}
GET /devices/{serial}/clients
```

### Firewall rule management

```
GET  /networks/{networkId}/appliance/firewall/l3FirewallRules
PUT  /networks/{networkId}/appliance/firewall/l3FirewallRules
```

**L3 rule schema:**
```json
{
  "comment": "Block malicious IP",
  "policy": "deny",
  "protocol": "any",
  "srcPort": "Any",
  "srcCidr": "198.51.100.1/32",
  "destPort": "Any",
  "destCidr": "Any",
  "syslogEnabled": true
}
```

> **Warning:** `PUT /l3FirewallRules` replaces the **entire ruleset**. Always `GET` the current rules first and prepend your new rule to the existing list.

### VLAN management

```
GET /networks/{networkId}/appliance/vlans
GET /networks/{networkId}/appliance/vlans/{vlanId}
PUT /networks/{networkId}/appliance/vlans/{vlanId}
```

---

## Step 8 — Error Handling Reference

| HTTP Status | Meaning | Action |
|---|---|---|
| `200 OK` | Success | Process response body |
| `201 Created` | Resource created | Process response body |
| `204 No Content` | Success, no body | No action needed |
| `400 Bad Request` | Malformed request or invalid parameters | Check request body/params against API docs |
| `401 Unauthorized` | Invalid or missing API key | Verify `X-Cisco-Meraki-API-Key` header |
| `403 Forbidden` | Authenticated but insufficient permissions | Check account role |
| `404 Not Found` | Resource does not exist | Verify organisation/network/device IDs |
| `429 Too Many Requests` | Rate limit hit | Back off using `Retry-After` header |
| `500 Internal Server Error` | Meraki platform error | Retry with exponential backoff; escalate if persistent |

---

## Step 9 — Environment Configuration

Store credentials in environment variables, never in code:

```bash
# .env (add to .gitignore)
MERAKI_API_KEY=your_api_key_here
MERAKI_ORG_ID=123456
MERAKI_NETWORK_ID=L_123456789
```

```python
import os
from dotenv import load_dotenv

load_dotenv()

API_KEY    = os.environ["MERAKI_API_KEY"]
ORG_ID     = os.environ["MERAKI_ORG_ID"]
NETWORK_ID = os.environ["MERAKI_NETWORK_ID"]
```

For Azure-hosted integrations, use **Key Vault references** or **Managed Identity** instead of `.env` files.

---

## Step 10 — Integration Patterns

### 1. Direct polling (cron/scheduled task)

```
Python script → Meraki API → local JSON/CSV export
```
Suitable for: inventory snapshots, scheduled event exports, ad hoc investigations.

### 2. Streaming to Sentinel (recommended for SOC)

```
Azure Function (timer trigger) → Meraki API → Log Analytics Workspace (Custom Table)
```
- Azure Function polls `/networks/{networkId}/events` every 5 minutes
- Events forwarded to Log Analytics using the **Data Collection API**
- KQL queries and analytics rules consume events in Sentinel

### 3. Webhook-based (real-time)

```
Meraki Dashboard → Webhook → Azure Function / API endpoint → processing
```
Meraki supports webhooks for alerting. Configure at:
`Dashboard → Network-wide → Alerts → Webhook servers`

Available alert types: device up/down, client VPN connect/disconnect, rogue AP detection, SSID availability.

---

## Related

- [Python Client Script](meraki_api_client.py) — Full client with rate limiting, pagination, and security operations functions.
- [Operational Playbook](operational-playbook.md) — Step-by-step procedures for network isolation, IP blocking, and event investigation.
- [Troubleshooting Guide](troubleshooting-guide.md) — Common errors and remediation steps.
- [Dashboard](dashboard/README.md) — Grafana dashboard for Meraki security monitoring.
- [Network Security Overview](../../README.md) — 802.1X, Palo Alto, and Meraki architecture context.
