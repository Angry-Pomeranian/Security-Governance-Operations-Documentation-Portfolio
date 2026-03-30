# Auditor Summary

**Google Chrome CIS Level 1 and Level 2 Hardening Policy**

## Policy Objective

This policy implements **CIS Benchmark Level 1 and Level 2 security controls** for Google Chrome on Windows 10 and later devices. Its primary objective is to reduce the risk of credential compromise, data leakage, and malicious browser-based activity while maintaining enterprise usability.

The policy enforces a **secure by default browser posture** for managed endpoints and is deployed as a pilot group prior to organisation-wide rollout. Findings from the pilot are used to validate compatibility before expanding the scope.

---

## Scope and Applicability

**In Scope:**
- Google Chrome (stable channel) on Windows 10 and later
- Managed enterprise endpoints enrolled in Intune
- Extension installation and browser feature controls
- Privacy, telemetry, and network security settings

**Out of Scope:**
- Personal devices (BYOD) not enrolled in Intune
- Chrome managed via Group Policy (on-prem GPO) rather than Intune
- Chrome on macOS or Linux (separate policy required)
- Guest or kiosk Chrome profiles

---

## Control Coverage Summary

### Security and Network Controls

**Control intent:** Enforce secure network behaviour and prevent credential-related attacks.

**Key controls enforced:**
- Safe Browsing always active in standard protection mode
- Certificate Transparency enforcement active (legacy CAs, URL-based exceptions disabled)
- Third-party software injection blocking enabled
- Site isolation required for every site (mitigates Spectre-class attacks)
- WebUSB API access blocked (prevents rogue USB HID attacks via browser)
- Mixed content (HTTP on HTTPS pages) blocked with no user override

**Risk addressed:** Man-in-the-browser attacks, certificate bypass, Spectre exploitation, WebUSB device takeover

---

### Privacy and Data Collection Controls

**Control intent:** Prevent unsanctioned data flows from managed devices to Google's infrastructure.

**Key controls enforced:**
- Cross-origin HTTP authentication prompts disabled (prevents credential relay)
- Global HTTP auth cache disabled
- Import of autofill, homepage, and search engines from previous browsers disabled
- DNS interception checks enabled
- Lookalike domain warnings enabled (cannot be suppressed)
- Background app continuation blocked when Chrome is closed
- Incognito mode retained (excluded from Level 2 lockdown per usability feedback)

**Risk addressed:** Data exfiltration, credential harvesting, shadow IT via browser sync

---

### Extension and Update Controls

**Control intent:** Prevent unauthorised extension installation and ensure timely security updates.

**Key controls enforced:**
- Component updates for Chrome enabled (ensures security components auto-update)
- Update notifications enforced (18-hour relaunch window — `64800000ms`)
- Chrome variation feature flags enabled (allows Microsoft-coordinated A/B security feature rollout)
- Extension allowlist and force-install list managed separately via the Browser Extension Control policy

**Risk addressed:** Extension-based malware, unpatched browser vulnerabilities, outdated security components

---

### Proxy and Network Settings

**Control intent:** Route traffic through the enterprise proxy for inspection and control.

**Key controls enforced:**
- Proxy settings enforced as system proxy (`ProxyMode: system`)
- HSTS bypass list disabled (ensures HSTS enforcement cannot be circumvented)
- Origins excluded from insecure origin restrictions: disabled

**Risk addressed:** Proxy bypass, direct egress without inspection, HSTS stripping attacks

---

## CIS Level Coverage

| Control Domain | Level 1 | Level 2 |
|---|---|---|
| Safe Browsing | Enhanced mode enforced | N/A (same) |
| Extension management | Force-install approved extensions | Default-deny all unapproved |
| Password manager | Disabled | Disabled |
| Certificate validation | Online OCSP checks disabled (performance) | Require for local trust anchors |
| WebUSB / Web Bluetooth | WebUSB blocked | Web Bluetooth also restricted |
| Incognito mode | Permitted | Restricted per environment decision |
| Site isolation | Required | Required |
| Mixed content | Block all | Block all |

---

## Verification

**In Chrome (`chrome://policy`):**
- Search `SafeBrowsingProtectionLevel` → expect value `1` (standard protection)
- Search `ExtensionInstallBlocklist` → expect `*` (all extensions blocked unless on allowlist)
- Search `PasswordManagerEnabled` → expect `false`
- Search `WebUsbAllowDevicesForUrls` / `DefaultWebUsbGuardSetting` → expect `2` (block)
- Search `ProxyMode` → expect `system`

**Via Intune:**
- Devices → Configuration profiles → **MEM – Win10+ – Chrome CIS L1 & L2** → Device Status: `Succeeded`
- Per-setting status: review any settings showing `Error` or `Not applicable`

**Via registry:**
```
HKLM\SOFTWARE\Policies\Google\Chrome
```
Confirm key values match the policy settings table in the README.

---

## Risk Register Summary

| Control Category | Risk Level if Not Enforced | Priority |
|---|---|---|
| Safe Browsing | High — direct phishing/malware exposure | P1 |
| Extension control | High — supply chain via browser | P1 |
| Password manager disabled | High — credential exposure if browser compromised | P1 |
| Site isolation | High — cross-origin data leakage | P1 |
| Certificate transparency | Medium — forged cert acceptance | P2 |
| Mixed content blocking | Medium — session hijacking via HTTP injection | P2 |
| Proxy enforcement | Medium — inspection bypass | P2 |
| Telemetry/data collection | Low — privacy, not direct attack vector | P3 |

---

## Related

- [Chrome CIS L1/L2 Policy Configuration](README.md)
- [CIS Google Chrome Benchmark v3.0.0](../../../../../endpoint-hardening/benchmarks/browsers/chrome/)
- [Browser Extension Control Policy](../browser-extensions/README.md)
- [Edge CIS Policy — Auditor Summary](../mem-win10-edge-cis/auditor-summary.md)
