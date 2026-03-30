# DNS Layer Security Setup Guide — Cisco Umbrella

## Overview

This guide covers the step-by-step configuration for activating Cisco Umbrella DNS-layer security for a new network. It starts from a fresh Umbrella organisation and ends with a verified policy blocking malicious DNS queries.

---

## How Umbrella DNS Security Works

When Umbrella is configured as the DNS resolver:

1. A device issues a DNS query (e.g. `malware-host.com`)
2. The query is routed to Umbrella's resolvers (`208.67.222.222` / `208.67.220.220`) instead of the ISP or internal DNS
3. Umbrella looks up the domain against its threat intelligence database
4. If the domain is malicious: Umbrella returns either `NXDOMAIN` (domain does not exist) or the Umbrella block page IP (`146.112.61.104`)
5. If the domain is clean: Umbrella returns the real DNS answer and the connection proceeds normally
6. All queries are logged to the Umbrella reporting database for Activity Search

The DNS resolution happens before any TCP connection is made — traffic to malicious domains is stopped at the name resolution stage, not by inspecting packets.

---

## Umbrella Resolver IP Addresses

| Protocol | Primary | Secondary |
|---|---|---|
| IPv4 DNS | `208.67.222.222` | `208.67.220.220` |
| IPv6 DNS | `2620:119:35::35` | `2620:119:53::53` |
| DNS-over-HTTPS (DoH) | `https://doh.opendns.com/dns-query` | — |

Use the IPv4 resolvers for standard deployment. IPv6 resolvers are only needed if IPv6 is the primary transport.

---

## Step 1 — Register a Network Identity

Before changing DNS, register the network in Umbrella so queries can be attributed to the correct organisation.

1. Log in to `https://dashboard.umbrella.com`
2. Navigate to **Deployments → Core Identities → Networks**
3. Click **Add Network**
4. Configure:
   | Field | Value |
   |---|---|
   | Name | `[Site]-[City]-[IP]` (e.g. `HQ-Sydney-203.0.113.10`) |
   | IP Address | Public egress IP of the site |
   | Internal Network | Optional: internal CIDR (e.g. `10.0.0.0/8`) for traffic attribution |
5. Click **Save**

**Multiple sites:** Add one network identity per public IP. If a site uses NAT with multiple internal subnets behind one public IP, the internal network CIDR helps Umbrella attribute queries to the correct subnet for reporting.

**Dynamic public IPs:** See [Handling Dynamic IPs](#appendix-a-handling-dynamic-public-ips) below.

---

## Step 2 — Configure DNS on the Internal DNS Server

The preferred method is to configure your internal DNS server (Windows DNS, BIND, Unbound) to forward queries to Umbrella, rather than changing DNS on each client device. This provides:
- Centralised control
- Single point of change for future updates
- Preserves internal DNS resolution for `.local` and internal zones

### Windows DNS Server — Forwarder Configuration

1. Open **DNS Manager** on the domain controller
2. Right-click the server name → **Properties** → **Forwarders** tab
3. Remove existing forwarders
4. Add: `208.67.222.222` and `208.67.220.220`
5. Uncheck **Use root hints if no forwarders are available** (prevents fallback to ISP DNS)
6. Click **OK**

**For split DNS:** Only forward external zones to Umbrella. Configure conditional forwarders for internal zones to point to internal DNS servers:
- Internal zone (`corp.local`): forward to internal DC
- All other zones: forward to Umbrella

### Windows DNS Server — Root Hints (fallback prevention)

If the DNS server has root hints configured and forwarders are unavailable, Windows DNS will fall back to root hints (bypassing Umbrella). To prevent this:
1. In DNS Manager → server properties → **Advanced** tab
2. Check **Disable recursion (also disables forwarders)** — only appropriate if this server is strictly a forwarder, not a resolver
3. Alternatively: firewall port 53 outbound to any IP except `208.67.222.222` and `208.67.220.220` on the DNS server (see [DNS Bypass Prevention Guide](../troubleshooting/dns-bypass-prevention-guide.md))

### BIND / Unbound — Forwarder Configuration

**BIND `named.conf` example:**
```
options {
    forwarders {
        208.67.222.222;
        208.67.220.220;
    };
    forward only;
};
```

**Unbound `unbound.conf` example:**
```
forward-zone:
    name: "."
    forward-addr: 208.67.222.222
    forward-addr: 208.67.220.220
```

---

## Step 3 — Configure DNS on Network Devices (Alternative Method)

If you cannot configure the internal DNS server, configure DNS resolvers directly on routers or DHCP servers.

### Router/Firewall DHCP — Change DNS Offered to Clients

In most firewall/router web interfaces:
1. Navigate to DHCP settings
2. Change DNS Server 1: `208.67.222.222`
3. Change DNS Server 2: `208.67.220.220`
4. Apply / save
5. Renew DHCP leases on client devices (`ipconfig /renew` on Windows)

**Note:** If clients have static DNS configured, DHCP DNS changes will not apply to them. Check for static DNS on servers and workstations.

---

## Step 4 — Verify DNS Is Routing Through Umbrella

From a machine inside the network:

```
nslookup -type=txt debug.opendns.com
```

Expected output:
```
Server:   208.67.222.222
Address:  208.67.222.222#53

Non-authoritative answer:
debug.opendns.com  text = "server 12.fra"
debug.opendns.com  text = "flags 40 0 1000 ..."
debug.opendns.com  text = "id 7654321"
debug.opendns.com  text = "source 203.0.113.10:52318"
debug.opendns.com  text = "ecs ..."
```

| Field to check | Expected value |
|---|---|
| `id` | Matches your Umbrella org ID (Admin → Account Management) |
| `source` | The client site's public IP |
| Server address | `208.67.222.222` or `208.67.220.220` |

If the `id` field does not match your org ID, the network identity registration (Step 1) has not matched this IP — re-check the registered IP.

---

## Step 5 — Test a Known-Bad Domain

Verify Umbrella is enforcing the default policy:

```
nslookup internetbadguys.com 208.67.222.222
```

Expected output:
```
Non-authoritative answer:
Name:    internetbadguys.com
Address: 146.112.61.104    ← Umbrella block page IP
```

`146.112.61.104` is the Umbrella block page. If you see this IP, the policy is blocking correctly.

If you see the real IP of the test domain, the domain may not be in Umbrella's block list — use a confirmed-malicious test domain from your security team, or test a domain you have manually blocked in a destination list.

---

## Step 6 — Verify Activity Appears in the Dashboard

1. **Reporting → Activity Search**
2. Set the time range to **Last 1 Hour**
3. Filter by **Identity** = the network identity name you created
4. You should see DNS queries appearing within a few minutes of the DNS pointing change

If no activity appears after 15 minutes:
- Re-check the DNS configuration on the internal DNS server
- Run `nslookup -type=txt debug.opendns.com` again to confirm resolver is Umbrella
- Check that the DNS server's outbound port 53 is not blocked by a firewall rule

---

## Step 7 — Configure the Default Policy

1. **Policies → Management → DNS Policies → Default Policy → Edit**
2. Confirm the following security categories are set to **Block**:
   | Category | Recommended action |
   |---|---|
   | Malware | Block |
   | Phishing | Block |
   | Command and Control Callbacks | Block |
   | Cryptomining | Block |
   | Dynamic DNS | Block or Log (review first) |
   | Newly Seen Domains | Log initially, move to Block after 2 weeks review |
3. Leave content filtering categories at your client's required settings (Adult Content, Gambling, etc.)
4. **Save and Apply**

---

## Step 8 — Run the Policy Tester

Confirm the policy is applying as expected for specific domains:

1. **Policies → Management → Policy Tester**
2. Enter:
   | Field | Value |
   |---|---|
   | Domain | A domain you have blocked or that falls in a blocked category |
   | Identity | Select the network identity or a roaming client |
3. Click **Test**
4. The result shows: which policy applied, the action (Block/Allow), the reason (category, destination list), and the policy order position

Use the Policy Tester whenever a user reports an unexpected block — it shows exactly why a domain was blocked and by which policy.

---

## Appendix A — Handling Dynamic Public IPs

If the client's public IP changes (residential/SMB ISP without a static IP):

**Option 1 — Umbrella Dynamic IP Updater:**
- Download from **Deployments → Roaming Computers → Roaming Client → Umbrella Dynamic IP Updater**
- Install on a Windows server or desktop that is always on
- The updater runs as a service, checks the public IP every 30 minutes, and updates the Umbrella network identity automatically

**Option 2 — API update via cron:**
Use the Umbrella Management API to update the network identity IP:
```bash
# Update network identity IP via Umbrella API
curl -X PUT "https://management.api.umbrella.com/v1/organizations/{orgId}/networks/{networkId}" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"ipAddress": "'"$(curl -s https://api.ipify.org)"'"}'
```
Schedule with cron every 30 minutes.

**Option 3 — Roaming client only (no network identity):**
Skip network identity entirely and rely solely on the Umbrella Roaming Client on all devices. This works for organisations where all devices are laptops/desktops with the client installed, but does not cover printers, IoT devices, or servers that cannot run the client.

---

## Appendix B — DNS over HTTPS (DoH) Considerations

Modern browsers (Chrome, Firefox, Edge) have built-in DoH support and may bypass your network DNS configuration to use their own DoH resolvers (e.g. Cloudflare `1.1.1.1`, Google `8.8.8.8`). This bypasses Umbrella entirely for browser-initiated DNS.

To prevent DoH bypass: see [DNS Bypass Prevention Guide](../troubleshooting/dns-bypass-prevention-guide.md).

---

## Related

- [New Client Onboarding Checklist](new-client-onboarding-checklist.md) — Full onboarding sequence.
- [Roaming Client Mass Deployment Guide](roaming-client-mass-deployment-guide.md) — Extending protection to off-network devices.
- [DNS Bypass Prevention Guide](../troubleshooting/dns-bypass-prevention-guide.md) — Enforcing DNS routing at the firewall level.
- [Policy Management and Precedence Guide](../administration/policy-management-and-precedence-guide.md) — Policy structure and ordering.
