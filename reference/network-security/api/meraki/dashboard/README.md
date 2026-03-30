# Meraki Security Operations Dashboard — Grafana

## Overview

`meraki-security-dashboard.json` is a Grafana dashboard export for Cisco Meraki network security monitoring. It provides visibility across five areas:

| Panel group | What it shows |
|---|---|
| Organisation Overview | Device online/offline counts, total events, firewall deny hits, active client count |
| Event Timeline | Stacked bar chart of event types over time, event type distribution pie chart |
| Firewall & Security | Top blocked source IPs table (with gauge), firewall deny events time series |
| Client Activity | Top clients by data usage, association/disassociation events over time |
| Device Health | Full device status table with online/offline colour coding |

---

## Prerequisites

| Requirement | Notes |
|---|---|
| Grafana 10.0+ | Self-hosted or Grafana Cloud |
| InfluxDB 1.x or 2.x (or compatible TSDB) | Used as the data source (`MERAKI_DS`) |
| Data collection script | The `meraki_api_client.py` script (or Azure Function equivalent) must poll the Meraki API and write metrics to your TSDB |

---

## Data Pipeline

The dashboard expects event and metric data written to a time-series database. The recommended collection pattern:

```
meraki_api_client.py  →  InfluxDB  →  Grafana
(scheduled every 5min)    (local or cloud)  (dashboard)
```

**Minimum required measurements:**

| Measurement | Key fields |
|---|---|
| `meraki_events` | `time`, `event_type`, `network_id`, `network_name`, `src_ip`, `dest_ip`, `client_mac`, `rule_comment` |
| `meraki_clients` | `time`, `client_mac`, `ip`, `description`, `vlan`, `manufacturer`, `network_id`, `usage_bytes` |
| `meraki_device_status` | `time`, `serial`, `name`, `model`, `status`, `network_id`, `wan1_ip`, `last_reported_at` |

---

## Setup Steps

### 1. Configure the data source

1. In Grafana: **Connections → Data sources → Add data source**
2. Select **InfluxDB** (or your TSDB of choice)
3. Set the data source UID to `MERAKI_DS` — this must match the UID in the dashboard JSON, or update all panel queries after import
4. Configure connection details and click **Save & test**

### 2. Import the dashboard

1. In Grafana: **Dashboards → Import**
2. Click **Upload dashboard JSON file**
3. Select `meraki-security-dashboard.json`
4. Select the `MERAKI_DS` data source when prompted
5. Click **Import**

### 3. Start data collection

Run the collection script on a scheduled basis (cron or Azure Function timer trigger):

```bash
# Cron example — every 5 minutes
*/5 * * * * python3 /opt/meraki/meraki_api_client.py \
    --action get-events --network-id $MERAKI_NETWORK_ID \
    --timespan 300 --output /tmp/meraki-events.json \
    && python3 /opt/meraki/forward_to_influxdb.py --input /tmp/meraki-events.json
```

---

## Dashboard Variables

Two template variables are available in the top navigation bar:

| Variable | Description |
|---|---|
| `network` | Filter all panels to a specific network (or All) |
| `event_type` | Filter event panels to a specific event type (or All) |

---

## Alerts

Recommended Grafana alerts to configure on top of this dashboard:

| Alert | Condition | Suggested threshold |
|---|---|---|
| Device offline | `meraki_device_status.status = 'offline'` | Any device offline > 5 minutes |
| Firewall spike | `meraki_events` firewall event count | > 100 in 5 minutes |
| New client detected | Unknown MAC in `meraki_clients` | Any unknown manufacturer + no prior history |
| High bandwidth client | `usage_bytes` per client | > 1 GB in 1 hour |

---

## Related

- [Python Client Script](../meraki_api_client.py) — Data collection script that feeds this dashboard.
- [Implementation Guide](../implementation-guide.md) — Meraki API authentication and endpoint reference.
- [Operational Playbook](../operational-playbook.md) — Response procedures when dashboard alerts fire.
