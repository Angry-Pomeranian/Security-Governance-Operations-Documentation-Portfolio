# DNS Bypass Prevention Guide — Cisco Umbrella

## Overview

Umbrella only protects DNS queries that route through its resolvers. If a user or device sends DNS queries to a different resolver — by changing DNS settings, using DNS-over-HTTPS (DoH) in a browser, or connecting to a VPN that overrides DNS — Umbrella is bypassed entirely.

This guide covers the firewall rules and configurations needed to prevent DNS bypass, ensuring all DNS traffic routes through Umbrella.

---

## Bypass Methods and Controls

| Bypass method | Description | Control |
|---|---|---|
| Manual DNS change | User changes system DNS to `8.8.8.8` or `1.1.1.1` | Firewall: block outbound port 53 to any IP except Umbrella |
| Browser DoH (Chrome, Firefox) | Browser uses its own DoH resolver, bypassing OS DNS | Block DoH resolver domains; or deploy enterprise policy |
| DNS-over-TLS (DoT) | DNS client sends queries over TCP 853 | Firewall: block outbound port 853 |
| VPN with full-tunnel DNS | VPN routes DNS through VPN provider's resolver | VPN split DNS configuration |
| Hosts file bypass | DNS not used — IP hardcoded in `/etc/hosts` or `C:\Windows\System32\drivers\etc\hosts` | Not controllable via DNS; use EDR/DLP for hosts file monitoring |

---

## Firewall Rules — Port 53 Enforcement

The core control: block all outbound DNS (UDP/TCP port 53) from internal networks to any IP **except** Umbrella's resolvers.

### Rule Set (Apply in Order)

**On your perimeter firewall (Cisco ASA, Fortinet, Palo Alto, pfSense, etc.):**

| Rule | Source | Destination | Port | Protocol | Action |
|---|---|---|---|---|---|
| 1 | Internal (10.0.0.0/8) | 208.67.222.222 | 53 | UDP/TCP | Allow |
| 2 | Internal (10.0.0.0/8) | 208.67.220.220 | 53 | UDP/TCP | Allow |
| 3 | Internal (10.0.0.0/8) | 2620:119:35::35 | 53 | UDP/TCP | Allow |
| 4 | Internal (10.0.0.0/8) | 2620:119:53::53 | 53 | UDP/TCP | Allow |
| 5 | Internal (10.0.0.0/8) | Internal DNS servers | 53 | UDP/TCP | Allow |
| 6 (Catch-all) | Internal (10.0.0.0/8) | Any | 53 | UDP/TCP | **Deny (Log)** |

**Log the deny rule** — the deny log will show which devices are attempting to use alternate DNS resolvers.

### Palo Alto — Example Security Policy

```
Rule name: Deny-DNS-Bypass
Source zone: Trust
Destination zone: Untrust
Source address: 10.0.0.0/8
Destination address: any (excluding Umbrella IPs — use negate with Umbrella address object)
Application: dns
Service: application-default
Action: Deny
Log: Yes
```

Create an address group `Umbrella-Resolvers` containing `208.67.222.222` and `208.67.220.220`, then set the Allow rule for DNS to destination = `Umbrella-Resolvers`.

### Fortinet FortiGate — Example Policy

```
config firewall policy
    edit 0
        set name "Allow-DNS-To-Umbrella"
        set srcintf "internal"
        set dstintf "wan1"
        set action accept
        set srcaddr "all"
        set dstaddr "Umbrella-Resolvers"    # Address group: 208.67.222.222, 208.67.220.220
        set service "DNS"
        set logtraffic all
    next
    edit 0
        set name "Block-DNS-Non-Umbrella"
        set srcintf "internal"
        set dstintf "wan1"
        set action deny
        set srcaddr "all"
        set dstaddr "all"
        set service "DNS"
        set logtraffic all
    next
end
```

### Windows Firewall via GPO (for host-level enforcement)

For environments without a central firewall, enforce DNS at the host:

```powershell
# Create GPO-deployed Windows Firewall rules via PowerShell (deploy via GPO startup script)

# Block outbound DNS to any IP except Umbrella (Windows Firewall)
netsh advfirewall firewall add rule `
    name="Block DNS - Non-Umbrella" `
    dir=out protocol=udp remoteport=53 `
    remoteip="0.0.0.0/0" action=block

# Allow DNS to Umbrella
netsh advfirewall firewall add rule `
    name="Allow DNS - Umbrella Primary" `
    dir=out protocol=udp remoteip="208.67.222.222" remoteport=53 action=allow

netsh advfirewall firewall add rule `
    name="Allow DNS - Umbrella Secondary" `
    dir=out protocol=udp remoteip="208.67.220.220" remoteport=53 action=allow
```

**Note:** Windows Firewall rule order for outbound: Allow rules take precedence over Block rules for the same port when using specific remote IP addresses. Verify behaviour on your target OS version.

---

## Blocking DNS-over-HTTPS (DoH)

Modern browsers use DoH to bypass OS DNS settings. The browsers use specific hardcoded DoH provider domains. Block these at the firewall to prevent browser DoH bypass.

### DoH Resolver Domains to Block

| Provider | DoH URL | IP(s) |
|---|---|---|
| Cloudflare | `cloudflare-dns.com`, `1dot1dot1dot1.cloudflare-dns.com` | `1.1.1.1`, `1.0.0.1` |
| Google | `dns.google`, `dns.google.com` | `8.8.8.8`, `8.8.4.4` |
| Quad9 | `dns.quad9.net` | `9.9.9.9`, `149.112.112.112` |
| Cisco Umbrella (DoH) | `doh.opendns.com` | `208.67.222.222` |
| NextDNS | `dns.nextdns.io` | Various |
| AdGuard | `dns.adguard.com` | Various |

**Add these domains to the Umbrella Global Block List** (Policies → Destination Lists → Global Block List). This blocks DNS-based resolution of DoH providers. Since DoH is accessed via HTTPS, blocking the DNS name prevents the browser from resolving the DoH endpoint.

Additionally, **block HTTPS (port 443) to known DoH resolver IPs** at the firewall:
| Source | Destination | Port | Action |
|---|---|---|---|
| Internal | `1.1.1.1`, `1.0.0.1` | 443 | Deny |
| Internal | `8.8.8.8`, `8.8.4.4` | 443 | Deny |
| Internal | `9.9.9.9`, `149.112.112.112` | 443 | Deny |

Note: blocking `8.8.8.8:443` also blocks Google HTTPS health checks on some platforms. Monitor for unexpected breakage.

### Browser Enterprise Policy — Disable DoH

**Chrome via Group Policy (ADMX):**
1. Download and apply Chrome ADMX templates
2. `Computer Configuration → Administrative Templates → Google Chrome → Allow DNS-Over-HTTPS`
3. Set to **Disabled**

Or via the Intune OMA-URI:
```
OMA-URI: ./Device/Vendor/MSFT/Policy/Config/Browser/AllowDnsOverHttps
Data type: Integer
Value: 0
```

**Firefox via enterprise policy** (`policies.json`):
```json
{
  "policies": {
    "DNSOverHTTPS": {
      "Enabled": false,
      "Locked": true
    }
  }
}
```

**Edge via Group Policy:**
1. Administrative Templates → Microsoft Edge → DNS-over-HTTPS
2. Set DNS-over-HTTPS mode: **off**

---

## Blocking DNS-over-TLS (DoT)

DNS-over-TLS uses TCP port 853. Block this at the perimeter:

| Source | Destination | Port | Protocol | Action |
|---|---|---|---|---|
| Internal | Any | 853 | TCP | Deny |

DoT is less commonly implemented in desktop browsers but is used by some mobile devices (Android Private DNS) and DNS clients.

---

## Preventing Hosts File Bypass

The hosts file (`C:\Windows\System32\drivers\etc\hosts` on Windows, `/etc/hosts` on macOS/Linux) can redirect domains to arbitrary IPs without using DNS at all. This cannot be controlled by DNS policy.

**Detection approach:**
- Use your EDR to monitor writes to the hosts file path
- Alert on any modification
- On Windows, restrict write permissions to the hosts file:
  ```cmd
  icacls "C:\Windows\System32\drivers\etc\hosts" /grant:r "Administrators:F" /deny "Users:W"
  ```

---

## Preventing VPN DNS Override

When a full-tunnel VPN is active, it routes all DNS to the VPN provider's DNS server, bypassing Umbrella. Options:

**Option 1 — Split DNS in VPN configuration:**
Configure the VPN to only route internal domain queries through the VPN tunnel, and use Umbrella for all external queries:
- In Cisco AnyConnect / Secure Client: configure DNS split exclude lists in the VPN profile
- In other VPN clients: configure per-domain DNS routing

**Option 2 — Cisco Secure Client with Umbrella module:**
Cisco Secure Client includes an Umbrella module that ensures DNS always routes to Umbrella regardless of VPN state. This is the cleanest solution for environments already using AnyConnect/Secure Client.

**Option 3 — Umbrella WARP-equivalent (SIG):**
Cisco Umbrella Secure Internet Gateway (SIG) with a cloud-delivered firewall can enforce DNS routing at the cloud level for VPN-connected users, independent of endpoint configuration.

---

## Verifying DNS Bypass Controls

After applying firewall rules, test from multiple device states:

**Test 1 — On-network, attempting bypass:**
```cmd
# Try to query Google's DNS directly (should be blocked)
nslookup google.com 8.8.8.8
```
Expected: timeout or connection refused.

**Test 2 — On-network, Umbrella DNS working:**
```cmd
nslookup -type=txt debug.opendns.com
```
Expected: returns org ID.

**Test 3 — Verify block rule is logging:**
After the test, check firewall logs for a blocked connection from your test machine to `8.8.8.8:53`. Confirm logging is working so bypass attempts are visible in your SIEM.

**Test 4 — DoH bypass attempt:**
In Chrome (with no enterprise policy applied), navigate to `chrome://settings/security`. If "Use secure DNS" is enabled with a custom provider, the browser is bypassing Umbrella DNS. After applying the browser enterprise policy, this option should be greyed out.

---

## Monitoring DNS Bypass Attempts

Configure your SIEM to alert on firewall deny events for outbound port 53 to non-Umbrella IPs:

**Sentinel KQL query — Blocked DNS bypass attempts:**
```kql
CommonSecurityLog
| where DeviceEventClassID == "deny" or Activity contains "Deny"
| where DestinationPort == 53
| where DestinationIP !in ("208.67.222.222", "208.67.220.220")
| summarize Attempts = count() by SourceIP, DestinationIP, bin(TimeGenerated, 1h)
| where Attempts > 5
| order by Attempts desc
```

Repeated bypass attempts from a single device may indicate:
- Malware attempting to contact C2 via direct DNS
- A user intentionally circumventing controls
- An application hardcoded to use a specific DNS resolver

---

## Related

- [DNS Layer Security Setup Guide](../deployment/dns-layer-security-setup-guide.md) — Initial DNS configuration.
- [Roaming Client Troubleshooting Guide](roaming-client-troubleshooting-guide.md) — Diagnosing why the roaming client may not be protecting a device.
- [Umbrella Reporting & Activity Search Guide](../reporting/umbrella-reporting-activity-search-guide.md) — Monitoring DNS activity in the Umbrella dashboard.
