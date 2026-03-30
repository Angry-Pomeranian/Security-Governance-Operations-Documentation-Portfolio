# Roaming Client Troubleshooting Guide — Cisco Umbrella

## Overview

This guide covers diagnosing and resolving the most common Umbrella Roaming Client states and behaviours. The roaming client status visible in the Umbrella dashboard reflects what the client last reported — understanding each state and its root cause is the key to efficient troubleshooting.

---

## Client Status Reference

| Status | Meaning | Action needed |
|---|---|---|
| **Protected** | Client is active and routing DNS through Umbrella | None |
| **Protected (On-Network)** | Client is on-network; corporate DNS is handling queries; roaming client is dormant | None — expected behaviour |
| **Inactive** | Client has not checked in for more than 24 hours | Investigate |
| **Unprotected** | Client is installed and active but DNS is not being routed through Umbrella | Investigate |
| **Unencrypted** | Client is routing DNS but not over an encrypted channel | Investigate |
| **Tampered** | Client executable or configuration has been modified | Investigate immediately |

---

## Status: Inactive

**Definition:** The device has not sent a heartbeat to Umbrella in more than 24 hours.

### Possible Causes and Fixes

**Cause 1 — Device is powered off or offline**
- Check if the device exists in your device management system and has been online recently
- If the device is genuinely off, no action needed — it will return to Active when powered on and network-connected

**Cause 2 — Client service is stopped**

Check Windows services:
```cmd
sc query OpenDNS_ERC_Service
```
Expected state: `RUNNING`. If `STOPPED`:
```cmd
sc start OpenDNS_ERC_Service
```

Or via PowerShell:
```powershell
Get-Service -Name "OpenDNS_ERC_Service" | Start-Service
```

Check the service is set to Automatic start:
```cmd
sc config OpenDNS_ERC_Service start= auto
```

**Cause 3 — Firewall blocking outbound HTTPS from the client**

The roaming client requires outbound HTTPS (port 443) to Umbrella registration endpoints. If a host-based firewall (Windows Defender Firewall, third-party endpoint security) is blocking this:

Endpoints the client needs to reach:
- `registration.uda.cisco.com` (port 443)
- `api.opendns.com` (port 443)
- `opendns.com` (port 443)
- `*.uda.cisco.com` (port 443)

Test connectivity from the device:
```powershell
Test-NetConnection -ComputerName "registration.uda.cisco.com" -Port 443
```
Expected: `TcpTestSucceeded: True`

If False: check host-based firewall rules and corporate proxy configuration.

**Cause 4 — OrgID mismatch (wrong installer used)**

If the client was installed from a generic installer (not the one downloaded from the client's specific Umbrella organisation), the embedded OrgID will be wrong and the client cannot register.

Check the OrgID in the registry:
```cmd
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\OpenDNS\ERC" /v ORG_ID
```

Compare this to the OrgID in Umbrella (Admin → Account Management). If they do not match, uninstall and reinstall using the correct installer from the client's org.

---

## Status: Unprotected

**Definition:** The Umbrella Roaming Client is running but DNS queries are not being routed through Umbrella.

### Possible Causes and Fixes

**Cause 1 — Another application is overriding DNS**

Security software (EDR agents, VPN clients, other DNS filtering tools) can override the DNS configuration set by the Umbrella client.

Check current DNS resolvers on Windows:
```cmd
ipconfig /all | findstr "DNS Servers"
```

Expected (when roaming client is protecting): DNS servers should show `127.0.0.1` (localhost — the roaming client intercepts locally) or Umbrella IPs `208.67.222.222`.

If you see different IPs (e.g. `1.1.1.1`, `8.8.8.8`, or your VPN's DNS), another application has taken control. Common culprits:
- Cisco AnyConnect VPN (splits DNS when connected)
- Palo Alto GlobalProtect
- CrowdStrike Falcon
- Windows Subsystem for Linux (WSL) DNS isolation

**Fix for VPN conflicts:** The Umbrella roaming client and VPN clients often conflict. The recommended solution is to use Cisco Secure Client with the Umbrella module rather than the standalone roaming client, as this integrates natively with the VPN.

**Cause 2 — Split tunnel VPN not configured for Umbrella**

When a VPN with full tunnel is active, all DNS queries go through the VPN's DNS server, not Umbrella. This is by design — the corporate DNS server (reachable via VPN) handles queries.

If the intent is to have Umbrella protect VPN-connected devices too:
- Configure split DNS in the VPN: exclude Umbrella resolver queries from the VPN tunnel
- Or use Cisco Secure Client with the Umbrella module, which handles this automatically

**Cause 3 — macOS Full Disk Access not granted**

On macOS, the roaming client requires Full Disk Access to intercept DNS at the system level. Without it, the client runs but cannot redirect DNS queries.

**Fix:**
- Manually: System Settings → Privacy & Security → Full Disk Access → add `Cisco Umbrella Roaming Client`
- Via MDM: Deploy a PPPC profile as described in the [Roaming Client Mass Deployment Guide](../deployment/roaming-client-mass-deployment-guide.md)

**Cause 4 — Network extension not approved (macOS)**

macOS requires explicit user or MDM approval for network extensions. Without this, the Umbrella client's DNS proxy cannot function.

**Fix:** Deploy a system extension policy via MDM:
```xml
<key>AllowedExtensions</key>
<dict>
    <key>com.opendns.osx.RoamingClient</key>
    <array>
        <string>com.opendns.osx.RoamingClientExtension</string>
    </array>
</dict>
```

---

## Status: Unencrypted

**Definition:** The roaming client is routing DNS queries, but not using DNS-over-HTTPS (DoH) encryption.

### Possible Causes and Fixes

**Cause 1 — Intelligent Proxy certificate not trusted**

When SSL inspection is enabled, the roaming client uses DoH to Umbrella. If the Cisco root certificate is not installed and trusted, the DoH connection fails and the client falls back to unencrypted DNS.

**Fix:** Deploy the Cisco root certificate — see [Cisco Root Certificate Deployment Guide](../deployment/cisco-root-certificate-deployment-guide.md).

**Cause 2 — DoH blocked at the firewall**

Some corporate firewalls inspect HTTPS traffic and block connections to `doh.opendns.com`. If the DoH endpoint is blocked, the client falls back to plain DNS.

**Fix:** Ensure `doh.opendns.com` on port 443 is allowed through the firewall for devices using the roaming client.

**Cause 3 — Older client version (pre-DoH support)**

Clients older than the minimum version supporting DoH will always show as Unencrypted. Check the client version in the dashboard against Cisco's minimum recommended version.

**Fix:** Update the client to the current version via Intune, JAMF, or GPO software update policy.

---

## Wrong Policy Applying

**Symptom:** A user or device is getting blocked by the wrong policy, or is not getting the expected policy.

### Diagnosis

1. **Policy Tester:** Policies → Management → Policy Tester — test the domain against the identity
2. Note: which policy matched, the policy position, and the reason
3. If the wrong policy matched: check what identities are assigned to each policy

### Common Scenarios

**Scenario A — Roaming client identity has no policy assigned:**
The roaming computer appears in the dashboard as "Protected" but gets the Default Policy rather than the expected policy.

Fix: Assign the device (or the "All Roaming Computers" group) to the intended policy via Policies → [Policy] → Policy Identities.

**Scenario B — On-network device gets roaming policy, not network policy:**
A device in the office has the roaming client installed. The roaming client detects it is "on network" and should deactivate, letting the network DNS handle queries. But if the on-network detection fails (the client cannot detect the internal DNS resolver), it stays active and applies the roaming policy.

**On-network detection:** The roaming client detects it is on the corporate network by looking for an internal DNS server that responds to a specific probe query. If the internal DNS does not respond correctly (e.g. split DNS, custom resolver) the client does not deactivate.

Fix: Configure the **On-Network Detection** GUID in the roaming client settings. The client will probe for a specific DNS TXT record you publish on your internal DNS:
1. In Umbrella: Deployments → Roaming Computers → On-Network Detection
2. Copy the GUID provided
3. Create a TXT record on your internal DNS: `{GUID}.onnetwork.cisco.com TXT "on-network"`
4. The client will query this record; if it resolves, the client considers itself on-network and deactivates

---

## Captive Portal Conflicts

**Symptom:** Users on hotel/airport Wi-Fi cannot load the captive portal login page — the Umbrella client is blocking the redirect.

**Why this happens:** Captive portals use DNS hijacking to redirect users to their login page. The Umbrella client intercepts DNS queries and routes them to Umbrella, which returns the real DNS answer rather than the portal's redirect — so the portal never appears.

**Fix options:**

**Option 1 — Captive portal detection (automatic):**
Modern versions of the Umbrella Roaming Client include captive portal detection. When a captive portal is detected (HTTPS connectivity to a known endpoint fails), the client temporarily suspends DNS interception to allow the captive portal login to complete. Verify this is enabled in the client configuration.

**Option 2 — User-initiated bypass:**
The roaming client system tray icon (Windows) or menu bar icon (macOS) includes a "Pause Protection" option. Users can pause for a configurable period (default 15 minutes) to complete captive portal login. This is acceptable for brief interruptions.

**Option 3 — Exclude captive portal detection IPs:**
Some captive portal systems use specific destination IPs for their redirect. These can be added to an Umbrella bypass rule, but this approach is impractical for roaming users who encounter different portals.

---

## Cisco Secure Client Migration Issues

When migrating from the legacy Umbrella Roaming Client to Cisco Secure Client:

| Issue | Symptom | Fix |
|---|---|---|
| Dual installation | Both clients appear in Deployments list | Secure Client installer should auto-remove legacy client; if not, manually uninstall legacy client via Intune/GPO |
| Old entries not cleaning up | Inactive legacy client entries remain in dashboard | Inactive entries auto-expire after 30 days; filter dashboard view to Active only |
| Secure Client Umbrella module not activating | Device shows in Secure Client but no Umbrella status | Check that the Umbrella module is included in the Secure Client profile; re-download profile from Umbrella Admin → Integrations |
| Policy not applied after migration | Device shows Protected but gets Default Policy | Re-assign the device to the intended policy; the Secure Client identity is separate from the legacy roaming client identity |

---

## Diagnostic Commands Reference

### Windows

```cmd
:: Check roaming client service status
sc query OpenDNS_ERC_Service

:: Check DNS resolvers currently in use
ipconfig /all | findstr "DNS Servers"

:: Check OrgID
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\OpenDNS\ERC" /v ORG_ID

:: Test connectivity to Umbrella registration
Test-NetConnection -ComputerName registration.uda.cisco.com -Port 443

:: Verify Umbrella is resolving DNS
nslookup -type=txt debug.opendns.com

:: Check roaming client logs
type "C:\ProgramData\Cisco\Umbrella\logs\umbrella.log" | more
```

### macOS

```bash
# Check Umbrella launch daemon
launchctl list | grep -i opendns

# Check current DNS configuration
scutil --dns | grep -A5 "resolver #1"

# Verify Umbrella resolution
dig -t TXT debug.opendns.com

# Check roaming client log
tail -f /Library/Logs/Cisco/Umbrella/umbrellaagent.log
```

---

## Related

- [Roaming Client Mass Deployment Guide](../deployment/roaming-client-mass-deployment-guide.md) — Deployment procedures.
- [Cisco Root Certificate Deployment Guide](../deployment/cisco-root-certificate-deployment-guide.md) — Certificate trust required for DoH / SSL inspection.
- [Unexpected Blocks Troubleshooting Guide](unexpected-blocks-troubleshooting-guide.md) — Troubleshooting policy blocks.
- [Policy Management and Precedence Guide](../administration/policy-management-and-precedence-guide.md) — Understanding which policy applies to a device.
