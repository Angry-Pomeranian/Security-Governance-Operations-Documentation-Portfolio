# Destination Lists Guide — Cisco Umbrella

## Overview

Destination lists in Cisco Umbrella are custom allow or block lists for specific domains, URLs, or IP addresses. They are attached to DNS policies and give administrators granular control beyond what category-based policies provide.

---

## Destination List Types

| List Type | Behaviour |
|---|---|
| **Allow list** | Domains in this list are always allowed, even if they fall in a blocked category. Applied within the scope of the policies the list is attached to. |
| **Block list** | Domains in this list are always blocked, even if they fall in an allowed category. |
| **Global Allow list** | Applied across all policies organisation-wide — bypasses all category blocks. Use sparingly. |
| **Global Block list** | Applied across all policies organisation-wide — cannot be bypassed by policy-level allow lists. |

---

## Creating a Destination List

1. **Policies → Policy Components → Destination Lists → Add**
2. Configure:
   | Field | Value |
   |---|---|
   | List name | Descriptive: `KnowBe4-Allow`, `Blocked-Competitors`, `Finance-Tools-Allow` |
   | Access | Allow / Block |
   | Destinations | Add domains or URLs (see formats below) |
3. Click **Save**
4. Attach the list to one or more policies:
   - **Policies → Management → DNS Policies → [Policy Name] → Edit → Destination Lists**
   - Select the list and confirm the access type

---

## Destination Formats

| Format | Example | What it matches |
|---|---|---|
| Domain | `example.com` | Exact domain and all subdomains |
| Subdomain | `sub.example.com` | Only `sub.example.com` and its subdomains |
| URL | `example.com/specific-path` | Only that specific URL path |
| IP address | `93.184.216.34` | DNS queries resolving to that IP (limited effectiveness — see note) |

**Note on IP addresses:** Umbrella is a DNS-layer control. IP-based entries in destination lists apply at the DNS response level — if a domain resolves to the listed IP, the resolution may be blocked. However, direct IP-based connections (which bypass DNS entirely) are not controlled by Umbrella DNS policies. Use a firewall for direct IP blocking.

**Wildcard support:** Umbrella destination lists do not use explicit wildcards — entering `example.com` automatically covers `*.example.com`. There is no need to enter `*.example.com` separately.

---

## Global Allow List vs Policy-Level Allow List

| | Global Allow List | Policy Allow List |
|---|---|---|
| Scope | All identities in the organisation | Only identities assigned to policies using this list |
| Override behaviour | Overrides all category blocks globally | Overrides category blocks within that policy only |
| Use case | Umbrella false positives affecting the whole org (e.g. misclassified vendor domain) | Client-specific or group-specific exceptions |
| MSP risk | High — affects all tenants in the organisation | Low — scoped to specific policies |

**MSP caution:** In multi-tenant environments, confirm you are in the correct client organisation before modifying any Global list. A global allow added in the wrong tenant will bypass security controls for all identities in that tenant.

---

## Common Allow List Use Cases

### Phishing Simulation Platforms

Phishing simulation tools must be on the allow list — both the sending domains and the landing page / click-tracking domains. Blocking these causes simulation campaigns to fail silently (clicks never register).

| Platform | Domains to allow |
|---|---|
| KnowBe4 | `knowbe4.com`, `knb4.com`, `knowbe4training.com`, `phishinglinks.com` (plus any custom domains configured in your KnowBe4 account) |
| Proofpoint SAT | `proofpointessentials.com` plus campaign-specific domains from your SAT console |
| Cofense | `cofense.com`, `phishme.com` (legacy), campaign domains |
| Terranova | Obtain current domain list from Terranova platform |

For each platform: add to a dedicated allow list (e.g. `KnowBe4-Phishing-Simulation`) and attach it to all relevant DNS policies. Do not add to the Global Allow list unless all clients use the same platform.

### Security Tools and Agents

Security software (EDR, DLP, vulnerability scanners) often communicates with cloud management consoles that may be miscategorised.

| Tool category | Example domains |
|---|---|
| CrowdStrike EDR | `*.crowdstrike.com`, `*.cloudsink.net` |
| Microsoft Defender | `*.wdcp.microsoft.com`, `*.wdcpalt.microsoft.com` |
| Qualys scanner | `*.qualys.com`, `*.qagpublic.com` |
| Nessus/Tenable | `*.tenable.com`, `*.tenablecloud.com` |

### Vendor / SaaS Tools with Dynamic Domains

Some legitimate business SaaS tools use domains that match Umbrella's threat categories (e.g. newly registered domains, URL shorteners used for tracking):

- Add the specific domain to a policy-level allow list
- Document the business justification and review date
- Do not add entire CDN domains (e.g. `*.amazonaws.com`) — too broad and bypasses protection for all AWS-hosted content

---

## Common Block List Use Cases

### Competitor or Inappropriate Sites

HR or management may request specific domains be blocked. Add these to a policy-level block list rather than a category block — this avoids blocking entire categories for a single target:

```
competitor-recruitment-site.com
gambling-app.com
specific-social-media.example
```

### Threat Intelligence Feeds

If you receive IOC (Indicator of Compromise) feeds from a threat intel source, domains can be bulk-imported to a block list. See [Bulk Import/Export](#bulk-importexport) below.

---

## Bulk Import/Export

### Bulk Import

For large allow/block lists (e.g. importing from a previous product or threat intelligence feed):

1. Prepare a plain text file with one domain per line:
   ```
   malicious-domain.com
   another-bad-domain.net
   phishing-site.org
   ```
2. **Policies → Policy Components → Destination Lists → [List Name] → Edit**
3. Click **Import** → upload the text file
4. Umbrella processes the import and confirms the number of entries added

**Limits:** Destination lists have a maximum of 30,000 entries. For threat intelligence feeds larger than this, use the Umbrella API to manage entries programmatically or consider splitting across multiple lists attached to the same policy.

### Bulk Export

To export a destination list (for backup, migration, or audit):

1. **Policies → Policy Components → Destination Lists → [List Name] → Edit**
2. Click **Export** → downloads a `.csv` file with all entries

Schedule regular exports as part of configuration backup — Umbrella does not provide automatic backup of destination lists.

### API-Based Management

For automated management of destination lists (e.g. pushing IOC feeds hourly):

```bash
# Get destination list ID
GET https://management.api.umbrella.com/v1/organizations/{orgId}/destinationlists

# Add destinations to a list
POST https://management.api.umbrella.com/v1/organizations/{orgId}/destinationlists/{destListId}/destinations
Content-Type: application/json

{
  "destinations": [
    {"destination": "malicious-domain.com"},
    {"destination": "another-bad-domain.net"}
  ]
}
```

Use an Umbrella Management API key (Admin → API Keys → Management) with the `policies:write` scope.

---

## Destination List Maintenance

| Task | Frequency | How |
|---|---|---|
| Review allow list entries | Quarterly | Audit for entries added for temporary reasons that are no longer needed |
| Review block list entries | Quarterly | Confirm blocked domains are still intentionally blocked |
| Verify phishing simulation domains still current | Before each campaign | Check with simulation vendor for updated sending domains |
| Export backup of all destination lists | Monthly | Manual export or API dump |

**Stale allow list entries are a security risk.** A domain that was legitimate when added may have been abandoned and re-registered as a malicious site. Quarterly review is the minimum.

---

## Destination Lists vs Category Blocks

| Use case | Use destination list | Use category block |
|---|---|---|
| One specific domain to allow/block | Yes | No |
| All domains in a content category | No | Yes |
| Temporary exception for a vendor | Yes (with expiry note) | No |
| Blocking all gambling sites | No | Yes (Gambling category) |
| Allowing a misclassified domain | Yes | No |
| Client-specific rules | Yes (policy-level list) | Yes (per-policy settings) |

---

## Related

- [Policy Management and Precedence Guide](policy-management-and-precedence-guide.md) — How destination lists interact with policy evaluation.
- [Unexpected Blocks Troubleshooting Guide](../troubleshooting/unexpected-blocks-troubleshooting-guide.md) — Using destination lists to resolve false positive blocks.
- [New Client Onboarding Checklist](../deployment/new-client-onboarding-checklist.md) — Initial destination list configuration during onboarding.
