# "Sites Are Being Blocked Unexpectedly" Troubleshooting Guide — Cisco Umbrella

## Overview

Unexpected blocks are the most common day-to-day Umbrella support request. This guide walks through diagnosing and resolving cases where legitimate domains are being blocked by Umbrella, including use of the Policy Tester, destination list review, and the category dispute process.

---

## Step 1 — Gather Information From the User

Before touching any Umbrella configuration, get these details from the user reporting the block:

| Information | How to get it |
|---|---|
| The exact domain or URL being blocked | Ask the user to copy the domain shown on the Umbrella block page |
| Their device name or username | Needed to identify the correct identity in the Policy Tester |
| Whether they are on-network or remote | Determines which identity type applies |
| When the block started | Helps narrow down what changed — policy edit, new device, etc. |
| Whether other users are also affected | Indicates scope (per-user vs org-wide) |

**From the Umbrella block page:** The block page displays:
- The blocked domain
- The Umbrella organisation name
- The category that caused the block
- A "Contact your administrator" link or message

If the block page is not showing (the browser just times out or shows a generic error), the connection may be blocked at a different layer — see [Not the Block Page](#appendix-when-the-umbrella-block-page-does-not-show).

---

## Step 2 — Use the Policy Tester

The Policy Tester shows exactly which policy is applying to a domain for a specific identity, and why.

1. **Policies → Management → Policy Tester**
2. Fill in:
   | Field | Value |
   |---|---|
   | Domain | The blocked domain (e.g. `software-vendor.com`) |
   | Identity | Select the affected user's roaming computer, AD user, or network identity |
3. Click **Test**

**Interpreting results:**

| Result field | What to check |
|---|---|
| Action: Block | Confirm the reason — category, destination list, or security setting |
| Policy name | Identifies which policy is responsible — is this the expected policy for this user? |
| Reason: [Category] | Check if the category classification is correct — the domain may be miscategorised |
| Reason: Destination List | A specific block list entry is matching — check the list |
| Reason: Security Setting | A security category (malware, phishing, C2) is matching — treat with caution before unblocking |

---

## Step 3 — Check the Category Classification

If the Policy Tester shows the block reason is a content category (e.g. "Newly Seen Domains", "File Storage", "Proxy/Anonymizer"), verify the classification is correct:

1. **Navigate to the Cisco Talos domain lookup:** `https://talosintelligence.com/reputation_center/lookup?search={domain}`
2. Check the Web Category shown — this is the classification Umbrella uses
3. If the category is wrong: see [Category Dispute Process](#category-dispute-process) below

**Common miscategorisations:**

| Legitimate site type | Sometimes miscategorised as |
|---|---|
| New vendor with recently registered domain | Newly Seen Domains / Dynamic DNS |
| Developer tool or API endpoint | Proxy/Anonymizer (if it relays requests) |
| Cloud storage / backup service | File Storage |
| Marketing link tracker | URL Shortener |
| Internal test environment | Suspicious / Unknown |
| Security research blog | Hacking / Malware (if it discusses threats) |

---

## Step 4 — Review Destination Lists

If the Policy Tester shows the block reason is a Destination List, find which list contains the domain:

1. **Policies → Policy Components → Destination Lists**
2. For each block list: open and search for the domain
3. If found: determine if the entry is:
   - **Intentional** (e.g. a blocked competitor or known malicious domain): do not remove; instead advise the user
   - **Stale** (e.g. a domain that was temporarily blocked and should have been removed): remove the entry
   - **Error** (e.g. the wrong domain was added): remove and add the correct one

**For the Global Block List:** Check **Policies → Policy Components → Destination Lists → Global Block List** first — entries here apply to all identities and cannot be overridden by policy-level allow lists.

---

## Step 5 — Resolve the Block

Choose the appropriate resolution based on what you found:

### Resolution A — Miscategorised Domain (Category Block)

**Option 1 — Add to destination allow list (immediate fix):**
1. **Policies → Policy Components → Destination Lists**
2. Open the appropriate policy-level allow list, or create a new one
3. Add the domain
4. Confirm the allow list is attached to the affected user's policy
5. Wait 5 minutes; have the user retry

**Option 2 — Change category handling in the policy (broader fix):**
If the category causing the block is too aggressive for this client (e.g. "Newly Seen Domains" is catching too many legitimate vendor sites):
1. **Policies → Management → DNS Policies → [Policy] → Edit → Security Settings**
2. Change the action for the relevant category from **Block** to **Log** or **Warn**
3. This affects all domains in that category — use with care

**Option 3 — Submit a category dispute (long-term fix):** See below.

### Resolution B — Destination List Block

1. Remove the domain from the block list (if it should not be blocked)
2. Or add the domain to a policy-level allow list that takes precedence
3. Note: a policy-level allow list does **not** override the Global Block List

### Resolution C — Security Category Block (Malware, Phishing, C2)

Do not unblock domains matched by a security category without investigation. These classifications come from Cisco Talos threat intelligence.

Before allowing:
1. Check the domain in Talos: `https://talosintelligence.com/reputation_center/lookup?search={domain}`
2. Check VirusTotal: `https://www.virustotal.com/gui/domain/{domain}`
3. Check URLVoid / URLScan.io for any recent flags

If the domain is genuinely legitimate and is a false positive from Talos threat intelligence:
- Add to destination allow list as a temporary measure
- Submit a Cisco Talos false positive report (see below)
- Document the exception with a review date

---

## Category Dispute Process

If a domain is miscategorised by Cisco Umbrella / Talos, submit a reclassification request:

1. **Navigate to:** `https://dashboard.umbrella.com/` → **Policies → Management → DNS Policies → [any policy]** → hover over a blocked domain in Activity Search → **Request Recategorisation**

   Or directly via the Talos URL reputation centre:
   `https://talosintelligence.com/reputation_center/lookup?search={domain}`
   → Scroll to "Submit a Dispute"

2. Fill in:
   | Field | Value |
   |---|---|
   | Domain | The exact domain (without `https://`) |
   | Requested category | The correct category (e.g. "Computer and Internet Security", "Software/Technology") |
   | Justification | Brief explanation: "This is a legitimate vendor/SaaS tool used for [purpose]. Current category [X] is incorrect." |
   | Contact email | Your email for follow-up |

3. Cisco Talos reviews category disputes within 1–5 business days
4. Changes propagate to Umbrella within 24–48 hours of approval

**While waiting for reclassification:** Add to a destination allow list as a temporary exception. Remove the allow list entry once the category is corrected.

---

## Activity Search — Confirming the Block

After making changes, confirm the fix in Activity Search:

1. **Reporting → Activity Search**
2. Filter by: domain name, identity, last 30 minutes
3. Look for the action change from **Blocked** to **Allowed**

If the domain still shows Blocked after adding it to an allow list:
- Confirm the allow list is attached to the correct policy
- Confirm the policy is assigned to the correct identity
- Check policy order — if the identity matches a higher-priority policy that has a block list containing this domain, the allow list in a lower-priority policy will not apply
- Flush DNS cache on the user's device: `ipconfig /flushdns` (Windows) or `sudo dscacheutil -flushcache` (macOS)

---

## Appendix — When the Umbrella Block Page Does Not Show

If users report sites not loading but do not see the Umbrella block page:

**Possible cause 1 — HTTPS site blocked without certificate trust:**
If Intelligent Proxy is active but the Cisco root certificate is not installed, HTTPS blocks return a certificate error rather than the block page.
- Fix: Deploy the Cisco root certificate — see [Cisco Root Certificate Deployment Guide](../deployment/cisco-root-certificate-deployment-guide.md)

**Possible cause 2 — DNS returning NXDOMAIN:**
Some security category blocks return `NXDOMAIN` rather than the block page IP. The browser shows "Server not found" or "This site can't be reached" rather than the Umbrella block page.
- Diagnose: `nslookup {domain} 208.67.222.222` — if the response is `NXDOMAIN` or returns `146.112.61.104`, Umbrella is blocking
- Fix: same resolution steps as above

**Possible cause 3 — Network connectivity issue (not Umbrella):**
If the domain was never in a blocked category but the site is unreachable:
- Test: `nslookup {domain} 8.8.8.8` — if this also fails, the DNS issue is upstream (domain expired, DNS propagation issue)
- Test: ping the resolved IP — if DNS resolves but ping fails, the issue is routing or firewall downstream of Umbrella

---

## Related

- [Policy Management and Precedence Guide](../administration/policy-management-and-precedence-guide.md) — Understanding policy evaluation and the Policy Tester.
- [Destination Lists Guide](../administration/destination-lists-guide.md) — Managing allow and block lists.
- [DNS Bypass Prevention Guide](dns-bypass-prevention-guide.md) — Ensuring DNS queries actually route through Umbrella.
- [Umbrella Reporting & Activity Search Guide](../reporting/umbrella-reporting-activity-search-guide.md) — Using Activity Search to confirm policy actions.
