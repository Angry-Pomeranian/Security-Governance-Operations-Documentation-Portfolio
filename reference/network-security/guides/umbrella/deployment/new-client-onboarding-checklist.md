# New Client Onboarding Checklist — Cisco Umbrella

## Overview

This checklist covers the end-to-end process for onboarding a new client to Cisco Umbrella DNS-layer security. Follow phases in order — each phase has dependencies on the previous one.

**Estimated time:** 2–4 hours for a typical SMB (1–500 users) with no legacy DNS complications.

---

## Pre-Onboarding Requirements

Before starting, collect the following from the client:

| Item | Notes |
|---|---|
| Umbrella organisation name and org ID | Found in **Admin → Account Management** |
| Current DNS resolvers in use | Run `nslookup -type=ns clientdomain.com` to confirm |
| Current public IP address(es) for the network | Required for network identity registration |
| Active Directory domain (if applicable) | For AD integration and user-level visibility |
| List of phishing simulation / security tool domains to allow | KnowBe4, Proofpoint SAT, etc. |
| SSL inspection requirement | Will the Cisco root certificate need to be pushed? |
| Roaming device count and management platform | Intune, JAMF, GPO, or manual |

---

## Phase 1 — Umbrella Organisation Setup

- [ ] **Log in to Umbrella Dashboard** — `https://dashboard.umbrella.com`
- [ ] **Confirm organisation is the correct tenant** — check the org name in the top-right header; MSPs must verify they are in the correct client org via the multi-org switcher
- [ ] **Set org timezone** — Admin → Account Management → Org Settings → Timezone (required for accurate reporting)
- [ ] **Add admin users** — Admin → Account Management → Users → Invite; assign roles (Full Admin / Read Only)
- [ ] **Enable two-factor authentication for all admins** — Admin → Account Management → Authentication

---

## Phase 2 — Network Identity Registration

This makes on-premises DNS queries attributable to the client's network.

- [ ] **Add network identity** — Deployments → Core Identities → Networks → Add Network
  - Enter the client's public egress IP address(es)
  - Name: use the site name (e.g. `HQ-Sydney-203.0.113.10`)
  - If the client has multiple offices, add each public IP as a separate network identity
- [ ] **If IP is dynamic — set up Dynamic IP Updater:**
  - Download the Umbrella Dynamic IP Updater from the Roaming Computers page
  - Install on a server or router at the client site
  - It checks the public IP every 30 minutes and updates Umbrella automatically
- [ ] **Verify network identity appears as Active** — status should show green within 5 minutes of a DNS query from that IP

---

## Phase 3 — DNS Pointing

Changing DNS is the step that activates Umbrella for on-premises queries.

- [ ] **Change DNS on the internal DNS server (recommended) or router:**
  - Primary: `208.67.222.222` (OpenDNS/Umbrella)
  - Secondary: `208.67.220.220`
  - IPv6 (if applicable): `2620:119:35::35` / `2620:119:53::53`
- [ ] **Verify DNS is pointing to Umbrella** — from inside the network, run:
  ```
  nslookup -type=txt debug.opendns.com
  ```
  Expected output includes the resolver IP and the network identity name:
  ```
  Server:  dns.umbrella.com
  Address: 208.67.222.222

  Non-authoritative answer:
  debug.opendns.com text = "server 12.fra"
  debug.opendns.com text = "flags 40 0 1000 ..."
  debug.opendns.com text = "id 123456"                ← your org ID
  debug.opendns.com text = "source x.x.x.x:port"     ← public IP
  ```
- [ ] **Confirm the network identity is receiving traffic** — Deployments → Core Identities → Networks: check **Last Seen** timestamp

---

## Phase 4 — Policy Creation

Create a default policy and any custom policies before roaming clients are deployed.

- [ ] **Review the default policy** — Policies → Management → Default Policy
  - Confirm the default policy action (Allow / Block by category)
  - The Default Policy applies to any identity not matched by a more specific policy
- [ ] **Create a site-specific or client policy** (optional but recommended for MSPs):
  - Policies → Management → DNS Policies → Add
  - Name: `[ClientName]-Standard`
  - Assign to the network identity created in Phase 2
- [ ] **Configure security category blocks** (recommended minimum):
  - Malware ✅ Block
  - Phishing ✅ Block
  - Command and Control ✅ Block
  - Cryptomining ✅ Block
  - Newly Seen Domains — consider **Log** (not Block) initially to assess false positive rate
- [ ] **Add destination list for known-allowed domains** (see [Destination Lists Guide](../administration/destination-lists-guide.md))
- [ ] **Add phishing simulation domains to the Global Allow list:**
  - KnowBe4: `knowbe4.com`, `knb4.com`, KnowBe4 click-tracking domains
  - Proofpoint SAT: confirm domains from Proofpoint SAT console
- [ ] **Test the policy using Policy Tester:**
  - Policies → Management → Policy Tester
  - Enter a test domain (e.g. `malware.wicar.org`) and the network identity — confirm it returns Block

---

## Phase 5 — Roaming Client Deployment

Deploys Umbrella protection to laptops and remote workers.

- [ ] **Confirm the correct client package** — Deployments → Roaming Computers → Roaming Client → Download
  - OrgID and fingerprint are embedded in the downloaded package
- [ ] **Choose deployment method:**
  - Intune → see [Roaming Client Mass Deployment Guide](roaming-client-mass-deployment-guide.md)
  - GPO → see [Roaming Client Mass Deployment Guide](roaming-client-mass-deployment-guide.md)
  - JAMF (macOS) → see [Roaming Client Mass Deployment Guide](roaming-client-mass-deployment-guide.md)
- [ ] **Deploy to pilot group first** (5–10 devices) — confirm Protected status before full rollout
- [ ] **Verify roaming clients appear in Dashboard** — Deployments → Roaming Computers: each device should show status **Protected**
- [ ] **Full rollout** once pilot is confirmed

---

## Phase 6 — Cisco Root Certificate Deployment

Required if the client has SSL inspection / Intelligent Proxy enabled.

- [ ] **Download the Cisco Umbrella root certificate** — Admin → Root Certificate → Download
- [ ] **Push the certificate using the appropriate method:**
  - Windows via GPO → see [Cisco Root Certificate Deployment Guide](cisco-root-certificate-deployment-guide.md)
  - Mac via MDM → see [Cisco Root Certificate Deployment Guide](cisco-root-certificate-deployment-guide.md)
  - Chrome → see [Cisco Root Certificate Deployment Guide](cisco-root-certificate-deployment-guide.md)
  - Firefox → see [Cisco Root Certificate Deployment Guide](cisco-root-certificate-deployment-guide.md)
- [ ] **Verify certificate is trusted** — open a browser on a test device and navigate to a domain that Umbrella proxies. No certificate error should appear.

---

## Phase 7 — Go-Live Verification

Run these checks after deployment to confirm everything is working before handing off to the client.

- [ ] **On-premises DNS verification:**
  ```
  nslookup -type=txt debug.opendns.com
  ```
  Confirm org ID and correct public IP appear.

- [ ] **Block test (on-premises):**
  ```
  nslookup internetbadguys.com 208.67.222.222
  ```
  Expected: returns `146.112.61.104` (Umbrella block page IP) — not the real IP.

- [ ] **Roaming client verification (off-network device):**
  - Disconnect device from corporate network / disable VPN
  - Run `nslookup -type=txt debug.opendns.com` — org ID should still appear, confirming roaming client is active
  - Run block test above — same result expected

- [ ] **Activity Search — confirm traffic is visible:**
  - Reporting → Activity Search → filter by the network identity or a roaming device — confirm DNS queries appear within the last 15 minutes

- [ ] **Policy Tester — confirm correct policy is applying:**
  - Policies → Management → Policy Tester
  - Test a blocked category domain against the network identity — confirm the correct policy name appears in results

- [ ] **Client sign-off** — walk through the dashboard with the client contact, show the network identity, roaming clients, and first activity data

---

## Post-Onboarding Handoff

- [ ] Document all created network identities, policies, and destination lists in the client record in your PSA/ticketing system
- [ ] Schedule 30-day review: assess false positive reports, policy tuning needs, DMARC escalation if Proofpoint is also in scope
- [ ] Provide client with the [End User Guide (Umbrella block pages)](../../email-security/guides/proofpoint/end-user-guide.md) adapted for Umbrella if needed — end users will encounter block pages and need to know how to report false positives

---

## Related

- [DNS Layer Security Setup Guide](dns-layer-security-setup-guide.md) — Detailed DNS configuration steps.
- [Roaming Client Mass Deployment Guide](roaming-client-mass-deployment-guide.md) — Intune/GPO/JAMF deployment procedures.
- [Cisco Root Certificate Deployment Guide](cisco-root-certificate-deployment-guide.md) — Certificate trust deployment.
- [Policy Management and Precedence Guide](../administration/policy-management-and-precedence-guide.md) — Policy structure and ordering.
