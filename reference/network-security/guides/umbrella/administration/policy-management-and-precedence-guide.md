# Policy Management and Precedence Guide — Cisco Umbrella

## Overview

Policy precedence confusion is the most common Umbrella misconfiguration issue. This guide explains how policies are structured, how Umbrella determines which policy applies to a given DNS query, how to create and order policies correctly, and how to use the Policy Tester to diagnose unexpected behaviour.

---

## How Policy Evaluation Works

When Umbrella receives a DNS query, it evaluates policies in this order:

```
DNS query arrives
    ↓
Is there a Roaming Computer identity match?
    → Yes → Apply the policy assigned to that roaming client identity
    ↓ No
Is there an AD user/group identity match (via VA connector)?
    → Yes → Apply the policy assigned to that user or group
    ↓ No
Is there a Network identity match (public IP)?
    → Yes → Apply the policy assigned to that network
    ↓ No
Apply the Default Policy
```

**Critical point:** Umbrella stops at the first matching identity and applies that policy. If a roaming computer has a policy assigned, Umbrella will never fall through to the network policy or default policy for that device — even if the roaming computer policy is less restrictive than the network policy.

---

## Identity Types

| Identity Type | Description | Where configured |
|---|---|---|
| Roaming Computers | Individual devices with the Umbrella client installed | Deployments → Roaming Computers |
| AD Users | Individual Active Directory user accounts (requires VA connector) | Deployments → Active Directory |
| AD Groups | AD security groups (requires VA connector) | Deployments → Active Directory |
| Networks | On-premises sites identified by public IP | Deployments → Core Identities → Networks |
| Network Devices | DHCP forwarders or Cisco network devices sending DNS source data | Deployments → Core Identities → Network Devices |

**Identity precedence (within the same query):**
1. Roaming Computer (highest)
2. AD User
3. AD Group (most specific group wins if user is in multiple groups)
4. Network
5. Default Policy (lowest)

---

## Policy Structure

A DNS policy in Umbrella contains:

| Component | Description |
|---|---|
| Security Settings | Which threat categories to block (malware, phishing, C2, etc.) |
| Content Categories | Which content categories to block or allow (adult, gambling, social media, etc.) |
| Application Settings | Block or allow specific applications (Dropbox, Tor, Bittorrent, etc.) |
| Destination Lists | Custom allow/block lists applied within this policy |
| Policy Identities | Which identities (networks, roaming clients, AD groups) this policy applies to |

**Important:** The Default Policy always exists and cannot be deleted. It is the catch-all that applies to any identity not matched by a specific policy.

---

## Creating a New Policy

1. **Policies → Management → DNS Policies → Add DNS Policy**
2. **Security Settings** tab:
   - Enable categories to block: Malware, Phishing, C2, Cryptomining (recommended for all policies)
   - Enable or disable additional categories based on client requirements
3. **Content Categories** tab:
   - Block categories per client's acceptable use policy (e.g. Adult Content, Gambling)
   - "Log only" option useful for initial monitoring before enforcing blocks
4. **Applications** tab:
   - Block specific applications (e.g. peer-to-peer, anonymous proxies)
5. **Destination Lists** tab:
   - Attach custom allow/block lists — see [Destination Lists Guide](destination-lists-guide.md)
6. **Policy Identities** tab:
   - Assign which identities this policy covers:
     - Networks: select from registered network identities
     - Roaming Computers: select individual devices or all roaming computers
     - AD Users/Groups: select users or groups (if AD integration is configured)
7. Click **Save and Apply**

---

## Policy Ordering and Precedence

Within the same identity type (e.g. multiple network policies), Umbrella evaluates policies in the order they appear in the policy list. **Higher in the list = higher priority.**

### Viewing and Reordering Policies

1. **Policies → Management → DNS Policies**
2. Policies are listed in priority order (top = first evaluated)
3. Drag and drop to reorder — or use the up/down arrows

### Precedence Rules

| Scenario | Outcome |
|---|---|
| Identity matches Policy A (position 1) and Policy B (position 3) | Policy A applies — first match wins |
| Roaming client in office (also matches a Network identity) | Roaming Computer policy applies — identity type takes precedence |
| AD user in two groups, each with a different policy | Policy assigned to the group listed higher in policy order wins |
| No identity match for the query | Default Policy applies |

### Common Precedence Mistakes

**Mistake 1 — Default Policy is too permissive:**
When a new roaming client is deployed but has not been assigned a specific policy, it falls through to the Default Policy. If the Default Policy has lenient settings, the client gets no real protection until assigned.
- Fix: Make the Default Policy the most restrictive. Use specific policies to loosen restrictions for identities that need it.

**Mistake 2 — Network policy doesn't apply to roaming clients in the office:**
When an employee is on-premises, their roaming client registers as a Roaming Computer identity. The network policy does not apply to them — their roaming computer policy applies.
- This is by design. If you want on-premises and roaming behaviour to match, assign the same policy to both the network identity and the roaming computer group.

**Mistake 3 — AD group policy doesn't apply:**
AD-based policies require the Virtual Appliance (VA) connector to be healthy and syncing. If the VA is down, AD user/group identities fall through to the network or default policy.
- Fix: see [Active Directory Integration Guide](active-directory-integration-guide.md) for VA health checks.

---

## Using the Policy Tester

The Policy Tester is the fastest way to diagnose why a specific domain is blocked or allowed for a specific user or device.

1. **Policies → Management → Policy Tester**
2. Fill in the fields:
   | Field | What to enter |
   |---|---|
   | Domain | The domain being tested (e.g. `example.com`) |
   | Identity | Select the roaming computer, network, or AD user experiencing the issue |
3. Click **Test**
4. The result shows:
   | Field | What it means |
   |---|---|
   | Action | Block / Allow |
   | Policy Name | Which policy matched |
   | Reason | Category match, destination list match, or security setting |
   | Policy Position | The ordering position of the matched policy |

### Policy Tester Scenarios

**Scenario A — Block you did not expect:**
- Domain: `software-vendor.com`
- Identity: `Jane.Smith@corp.com`
- Result: Block — Newly Seen Domains — Policy: Default Policy

Fix: The domain is less than 30 days old and categorised as a newly registered domain. Add it to an allow list (destination list) or change the Newly Seen Domains setting from Block to Log.

**Scenario B — Allow you did not expect:**
- Domain: `known-malware.com`
- Identity: `DESKTOP-ABC123` (roaming computer)
- Result: Allow — Policy: `DESKTOP-ABC123 Custom Policy`

Fix: The roaming computer has a custom policy that is missing the Malware category block. Check the security settings on that policy.

**Scenario C — Wrong policy applying:**
- Domain: `anything.com`
- Identity: `NetworkIdentity-HQ`
- Result: Policy: Default Policy (not the HQ-specific policy)

Fix: The network identity is not assigned to the HQ policy. Check **Policies → Management → DNS Policies → [HQ Policy] → Policy Identities** and add the network identity.

---

## Applying Policy Changes

Changes to policies in Umbrella are applied globally within approximately 5 minutes. There is no per-device push required — the next DNS query from the identity will be evaluated under the updated policy.

**If changes do not appear to take effect:**
- Wait 5 minutes and test again
- Use the Policy Tester — if the tester shows the correct result but live traffic does not, the device may be caching DNS responses locally. Flush the DNS cache:
  - Windows: `ipconfig /flushdns`
  - macOS: `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder`

---

## Policy Best Practices

| Practice | Reason |
|---|---|
| Make the Default Policy restrictive | Any unassigned identity falls through to it |
| Name policies clearly: `[Client]-[Group]-[Purpose]` | Easier to audit in multi-tenant MSP environments |
| Keep destination lists separate from policies | One allow/block list can be attached to multiple policies |
| Test every policy change with the Policy Tester | Catches misconfiguration before users encounter it |
| Review policy order after any new policy is added | New policies are placed at the bottom — reorder if needed |
| Use "Log only" before enforcing new content blocks | Prevents unexpected productivity impact during rollout |

---

## Related

- [Destination Lists Guide](destination-lists-guide.md) — Allow/block lists referenced in policy configuration.
- [Active Directory Integration Guide](active-directory-integration-guide.md) — Required for AD user/group identity-based policies.
- [Unexpected Blocks Troubleshooting Guide](../troubleshooting/unexpected-blocks-troubleshooting-guide.md) — Policy Tester walkthrough for live incidents.
