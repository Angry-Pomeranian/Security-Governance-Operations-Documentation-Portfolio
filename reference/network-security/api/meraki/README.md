# Cisco Meraki API v1

## Overview

The Cisco Meraki Dashboard API v1 is a RESTful API for programmatic management of Meraki network infrastructure — including MX security appliances (firewalls), MS switches, and MR wireless access points. It enables automation of network configuration, retrieval of event logs and telemetry, and programmatic enforcement of network access controls.

In this portfolio, the Meraki API is used for network security monitoring and automated incident response — specifically for VLAN isolation, IP blocking, event log ingestion, and client activity investigation.

**Base URI:** `https://api.meraki.com/api/v1`

---

## Contents

| File | Description |
|---|---|
| [implementation-guide.md](implementation-guide.md) | Step-by-step guide: API key setup, authentication, rate limiting, pagination, key endpoint patterns, integration approaches |
| [operational-playbook.md](operational-playbook.md) | Procedures for VLAN isolation, IP blocking, event investigation, client triage, and device inventory |
| [meraki_api_client.py](meraki_api_client.py) | Python CLI client — rate-limit handling, pagination, firewall rule management, VLAN isolation |
| [troubleshooting-guide.md](troubleshooting-guide.md) | Common errors (401, 403, 404, 429), firewall rule pitfalls, pagination issues, setup problems |
| [dashboard/](dashboard/) | Grafana dashboard JSON for Meraki security monitoring + setup guide |

---

## Quick Start

```bash
export MERAKI_API_KEY=your_key_here
export MERAKI_ORG_ID=123456
export MERAKI_NETWORK_ID=L_123456789

# List organisations
python3 meraki_api_client.py --action list-orgs

# Pull last 1 hour of events
python3 meraki_api_client.py --action get-events --timespan 3600

# Block a malicious IP (incident response)
python3 meraki_api_client.py --action block-ip --ip 198.51.100.42 --comment "INCIDENT-042: C2 beacon"

# Isolate a VLAN
python3 meraki_api_client.py --action isolate-vlan --cidr 10.10.20.0/24 --comment "INCIDENT-042: Containment"
```

---

## Portfolio Usage

| Use Case | Description |
|---|---|
| Network topology and inventory | Query organisations, networks, and device inventory programmatically for asset context during investigations |
| Event log retrieval | Pull network event logs (authentication failures, client associations, firewall hits) for SOC investigation and Sentinel ingestion |
| Client activity | Retrieve active client sessions and historical client data per device for lateral movement analysis |
| Automated firewall rule updates | Push updated L3 firewall rules to MX appliances as part of automated incident response (e.g. isolate a VLAN or block a source IP) |

---

## Key Endpoints

| Endpoint | Method | Purpose |
|---|---|---|
| `/organizations/{organizationId}/networks` | GET | List all networks in an organisation |
| `/networks/{networkId}/events` | GET | Retrieve network event logs (filterable by type, client, timespan) |
| `/networks/{networkId}/clients` | GET | List clients seen on a network |
| `/devices/{serial}/clients` | GET | Active clients currently connected to a specific device |
| `/networks/{networkId}/appliance/firewall/l3FirewallRules` | GET/PUT | Read or update L3 firewall rules on MX security appliances |
| `/networks/{networkId}/appliance/vlans` | GET | List VLANs configured on an appliance |
| `/organizations/{organizationId}/devices/statuses` | GET | Device online/offline status across the organisation |

---

## Authentication

All Meraki API requests are authenticated using an API key in the request header:

```
X-Cisco-Meraki-API-Key: <api-key>
```

API keys are generated per user in the Meraki Dashboard:
`Dashboard → [Username] → My Profile → API access → Generate new API key`

**Key scope:** API keys inherit the permissions of the generating user account. For least-privilege access, create a dedicated service account with read-only or network-admin role depending on the integration's requirements.

---

## Base URI

```
https://api.meraki.com/api/v1
```

All endpoints are relative to this base URI. Responses are JSON. Pagination is handled via `Link` headers for list endpoints.

---

## Reference

- Cisco Meraki API v1 documentation: https://developer.cisco.com/meraki/api-v1/

---

## Related

- [Network Security Overview](../../README.md) — 802.1X, ClearPass, Palo Alto, EDL, and Meraki architecture context.
- [Sentinel Network Queries](../../../../sentinel/queries/README.md) — KQL queries for network traffic analysis including firewall and Palo Alto log correlation.
- [Network Intrusion Playbook](../../../../../incident-response/network-intrusion-playbook.md) — Incident response for network intrusion scenarios including Meraki-based network isolation.
- [Meraki API v1 Reference](https://developer.cisco.com/meraki/api-v1/)
