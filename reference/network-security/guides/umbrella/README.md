# Cisco Umbrella — Operations Guide Suite

## Overview

This suite covers operational procedures for Cisco Umbrella DNS-layer security. Guides are split by purpose: deployment and onboarding, administration, troubleshooting, and reporting.

The official Cisco Umbrella documentation covers individual features well. These guides fill the practical gaps: MSP multi-tenant onboarding, mass roaming client deployment, policy precedence confusion, and troubleshooting client states that the vendor docs assume you will never encounter.

---

## Guides

### Deployment & Onboarding

| Guide | Purpose |
|---|---|
| [New Client Onboarding Checklist](deployment/new-client-onboarding-checklist.md) | End-to-end setup sequence: DNS pointing, network identities, policy creation, roaming client deployment, certificate push, and go-live verification |
| [DNS Layer Security Setup Guide](deployment/dns-layer-security-setup-guide.md) | Step-by-step initial config from MX record orientation to first policy test |
| [Roaming Client Mass Deployment Guide](deployment/roaming-client-mass-deployment-guide.md) | Intune and GPO deployment to Windows and Mac at scale |
| [Cisco Root Certificate Deployment Guide](deployment/cisco-root-certificate-deployment-guide.md) | GPO (Windows), MDM (Mac), Chrome, Firefox, and Chromebook certificate trust deployment |

### Administration

| Guide | Purpose |
|---|---|
| [Policy Management and Precedence Guide](administration/policy-management-and-precedence-guide.md) | Creating policies, identity types, policy ordering, and Policy Tester walkthrough |
| [Destination Lists Guide](administration/destination-lists-guide.md) | Allow lists, block lists, bulk import/export, and when to use each |
| [Active Directory Integration Guide](administration/active-directory-integration-guide.md) | Connector setup, user/group identity mapping, and why users go missing from reports |

### Troubleshooting

| Guide | Purpose |
|---|---|
| [Roaming Client Troubleshooting Guide](troubleshooting/roaming-client-troubleshooting-guide.md) | Inactive, Unprotected, Unencrypted, wrong policy applying, captive portal conflicts, Secure Client migration |
| [Unexpected Blocks Troubleshooting Guide](troubleshooting/unexpected-blocks-troubleshooting-guide.md) | Policy Tester walkthrough, destination list review, category dispute process |
| [DNS Bypass Prevention Guide](troubleshooting/dns-bypass-prevention-guide.md) | Firewall rules to prevent circumvention via DoH/DoT and alternate DNS resolvers |

### Reporting

| Guide | Purpose |
|---|---|
| [Reporting & Activity Search Guide](reporting/umbrella-reporting-activity-search-guide.md) | Dashboard reading, Activity Search, Top Threats, blocked categories, client-ready findings |

---

## Architecture Context

```
User/device DNS query
    ↓
Umbrella recursive DNS (208.67.222.222 / 208.67.220.220)
    ↓
Policy evaluation (identity → destination list → category policy)
    ↓
Allow → return DNS answer
Block → NXDOMAIN or block page (Umbrella IP)
    ↓
Optional: Intelligent Proxy (full URL inspection for risky domains)
```

**Identity resolution order (highest to lowest priority):**
1. Roaming Computer identity (machine-level, highest)
2. Active Directory user/group (requires VA connector)
3. Network identity (public IP / DHCP forwarder)
4. Default policy (catch-all)

---

## Related

- [Cisco Umbrella GUI Guide](../cisco-umbrella-gui-guide.md) — Visual walkthrough of the Umbrella dashboard interface.
- [Meraki API Reference](../../api/meraki/README.md) — Meraki network API for firewall rule management.
- Sentinel Cisco Umbrella connector — `../../../../sentinel/Manual/Cisco/Umbrella/`
