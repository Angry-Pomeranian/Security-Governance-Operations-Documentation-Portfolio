# Proofpoint — MSP Operations Guide

## Overview

This guide covers MSP-specific procedures for managing Proofpoint across multiple client tenants: new client onboarding, recurring health checks, threat dashboard interpretation, and client communication templates.

**Applies to:**
- Proofpoint Essentials (multi-tenant MSP portal)
- Proofpoint Enterprise (POD) managed on behalf of clients

---

## 1. Client Onboarding Checklist

Complete these steps for every new client before go-live. Tasks are ordered to avoid configuration gaps that cause delivery failures.

### Phase 1 — DNS and Routing (Day 1)

- [ ] **Obtain current MX record** — document the existing mail flow before changing anything
- [ ] **Identify all sending sources** — CRM, ERP, ticketing, payroll, marketing platform, cloud fax — everything that sends email on behalf of the client's domain
- [ ] **Add client domain to Proofpoint** — Admin Console → Setup → Domains → Add domain
- [ ] **Configure inbound routing** — set the delivery server to the client's mail server (Exchange on-prem IP or `{tenant}.mail.protection.outlook.com` for M365)
- [ ] **Test inbound routing without changing MX** — use the Proofpoint test delivery tool or `telnet {tenant}.pphosted.com 25` to verify routing
- [ ] **Add Proofpoint IP ranges to client M365 inbound connector** (if M365) — restrict M365 to accept inbound only from Proofpoint IPs (prevents bypass)
- [ ] **Update MX record** — point to `{tenant}.pphosted.com` (TTL 300 during cutover; restore to 3600 after 48h)
- [ ] **Verify MX propagation** — `nslookup -type=MX clientdomain.com`

### Phase 2 — Email Authentication (Day 1–2)

- [ ] **Update SPF record** — add `include:pphosted.com` to the client's SPF TXT record
- [ ] **Verify SPF lookup count** — must be ≤10 (`mxtoolbox.com/spf.aspx`)
- [ ] **Configure DKIM signing** — Admin Console → Email Authentication → DKIM Signing → Create key → publish CNAME in client DNS
- [ ] **Verify DKIM DNS record** — Admin Console → DKIM → Test (allow up to 30 minutes for propagation)
- [ ] **Publish DMARC record** — start with `p=none` for the first 30 days:
  ```
  v=DMARC1; p=none; rua=mailto:dmarc@{msp-domain}.com; pct=100
  ```
- [ ] **Configure DMARC reporting inbox** — set up a mailbox or forwarding rule at the `rua` address to receive aggregate reports
- [ ] **Enable anti-spoofing policy** — Email Protection → Policies → Anti-Spoofing → add client's domain to protected list

### Phase 3 — Policy Configuration (Day 2–3)

- [ ] **Set spam policy action** — Quarantine (recommended) vs Junk Folder (depends on client's preference and M365 integration)
- [ ] **Set bulk mail sensitivity** — start at Medium; adjust after reviewing false positive reports in week 1
- [ ] **Enable URL Defense** — TAP → URL Defense → on; action = Block
- [ ] **Enable Attachment Defense** — TAP → Attachment Defense → on; action = Replace attachment while scanning
- [ ] **Configure quarantine digest schedule** — daily (morning) is standard; confirm with client
- [ ] **Set quarantine digest From address** — use a domain the client's users will recognise (e.g. `noreply@{clientdomain}.com` via custom branding, or your MSP digest domain)
- [ ] **Create any organisation-level safe sender entries** — import from client's existing whitelist if migrating from another product

### Phase 4 — End User Access (Day 3)

- [ ] **Enable End User Digest portal** — confirm users can log in via the Proofpoint End User portal
- [ ] **Verify user accounts are provisioned** — users are auto-created in Proofpoint Essentials when mail flows through; confirm all addresses appear under Users
- [ ] **Deploy PhishAlarm Outlook add-in** (if licensed) — deploy via M365 Admin Center → Integrated Apps or via GPO
- [ ] **Send onboarding communication to client users** — explain URL rewriting, quarantine digest, and how to report phishing

### Phase 5 — Phishing Simulation Allowlisting (Week 1–2)

- [ ] **Confirm which simulation platform the client uses** — KnowBe4, Proofpoint SAT, Cofense, other
- [ ] **Add simulation platform IPs to IP allow list**
- [ ] **Add simulation sending domains to safe sender list**
- [ ] **Add simulation click-tracking domains to URL Defense exceptions**
- [ ] **Run a test simulation campaign to a pilot group** — confirm delivery, click tracking, and no Proofpoint blocks

### Phase 6 — Post-Go-Live Validation (Day 7)

- [ ] **Review message trace for false positives** — search past 7 days; any unexpected blocks from known senders?
- [ ] **Review quarantine for false negatives** — spot-check for spam that was delivered instead of quarantined
- [ ] **Confirm DKIM is signing outbound mail** — send a test to `check-auth2@verifier.port25.com`; confirm `dkim=pass` in the reply
- [ ] **Confirm SPF passes for the client's primary domain** — same Port25 test; confirm `spf=pass`
- [ ] **Review TAP dashboard** — any unusual URL or attachment activity in week 1?
- [ ] **Schedule DMARC policy escalation review** — book a 30-day review to assess reports and move from `p=none` to `p=quarantine`

---

## 2. Monthly Health Check Template

Run this check for each active client monthly. Document results in your ticketing/client management system.

### 2.1 Threat Summary

| Metric | How to find | This month | Last month | Trend |
|---|---|---|---|---|
| Total messages processed | TAP Dashboard → Summary | | | |
| Spam blocked | Email Protection → Reports → Spam | | | |
| Phishing blocked | TAP Dashboard → Phishing | | | |
| Malware blocked | TAP Dashboard → Malware | | | |
| Malicious URL clicks (TAP) | TAP Dashboard → URL Clicks | | | |
| Malicious attachment submissions | TAP Dashboard → Attachments | | | |
| Messages quarantined | Email Protection → Reports → Quarantine | | | |
| User phishing reports (PhishAlarm) | TAP Dashboard → User Reports | | | |
| TRAP auto-pulls | TRAP → Activity Log | | | |

### 2.2 Authentication Status

| Check | Expected | Actual | Status |
|---|---|---|---|
| SPF pass rate | >95% | | |
| DKIM pass rate | >95% | | |
| DMARC pass rate | >90% | | |
| DMARC policy | `p=quarantine` or `p=reject` after 30 days | | |
| Outbound DKIM signing active | Yes | | |

**How to check authentication pass rates:**
- Email Protection → Reports → Email Authentication
- DMARC aggregate reports (received at `rua` address) — look for `<dkim>pass</dkim>` and `<spf>pass</spf>` counts vs totals

### 2.3 Policy Health

| Check | Finding | Action needed |
|---|---|---|
| Allowed sender list reviewed | | Remove stale entries |
| IP allow list reviewed | | Remove IPs no longer in use |
| URL Defense exceptions reviewed | | Remove exceptions no longer needed |
| TAP policies up to date | | — |
| Quarantine digest being received by users (sample check) | | — |

### 2.4 User Activity

| Check | How to find | Finding |
|---|---|---|
| Users who released phishing/malware from quarantine | Email Protection → Quarantine → filter by reason=phishing, action=released by user | |
| Users with highest click-through on malicious URLs | TAP Dashboard → URL Clicks → by user | |
| Dormant mailboxes still receiving large volumes of mail | Email Protection → Reports → Top Recipients | |

### 2.5 Recommended Actions (post-check)

Document any items requiring follow-up:

```
Client: [client name]
Check date: [date]
Performed by: [your name]

Findings:
1. [Finding 1] — Action: [action] — Owner: [person] — Due: [date]
2. [Finding 2] — Action: [action] — Owner: [person] — Due: [date]

Next check scheduled: [date]
```

---

## 3. Explaining the TAP Threat Dashboard to Clients

When presenting the Proofpoint TAP dashboard to clients, translate the technical findings into business impact. Common items clients ask about and how to explain them:

### 3.1 "What are Very Attacked People (VAPs)?"

**Technical definition:** Proofpoint identifies users who receive a disproportionately high volume of targeted attacks (phishing, malware, BEC attempts) compared to the rest of the organisation.

**Client-friendly explanation:**
> "Proofpoint tracks which of your staff receive the most sophisticated attacks targeted specifically at them — not just bulk spam, but emails crafted to impersonate colleagues or contain targeted malware. This list typically includes executives, finance staff, and anyone who handles sensitive information or can authorise payments. These individuals need additional security awareness training and may benefit from stricter email policies."

**What to recommend:**
- Enrol VAPs in mandatory phishing awareness training (KnowBe4, Proofpoint SAT)
- Enable additional controls: require MFA for VAP mailbox access, enable browser isolation for VAP web access
- Increase quarantine aggressiveness for VAP mailboxes (separate policy)

### 3.2 "What is a Credential Phishing Attack?"

**Technical definition:** An email containing a URL that leads to a fake login page designed to steal usernames and passwords.

**Client-friendly explanation:**
> "These are fake login pages designed to look like Microsoft 365, your bank, or another service your staff use. If someone clicks the link and enters their password, the attacker captures it and can log in to your real account. Proofpoint blocks these links before your staff can reach the page."

**What to show:** TAP Dashboard → Phishing → filter by `type = credential phishing`. Show the number blocked this month and the number of clicks that were stopped.

### 3.3 "What is an Impostor Attack (BEC)?"

**Technical definition:** An email that impersonates an executive or supplier using lookalike domain names, display name spoofing, or compromised accounts, typically requesting a wire transfer or gift card purchase.

**Client-friendly explanation:**
> "These emails pretend to be from your CEO, CFO, or a trusted supplier. They typically ask for urgent payment or gift cards and are designed to bypass traditional spam filters because they contain no malicious links or attachments — they're just social engineering. Proofpoint's anti-spoofing and impostor detection catches these based on the sender domain and behaviour patterns."

**What to show:** TAP Dashboard → Impostor Attacks. Highlight any that reached the inbox vs those blocked — any that reached the inbox should prompt a user security awareness reminder.

### 3.4 "We Received No Threats This Month — Does That Mean We're Safe?"

**Client-friendly explanation:**
> "Low threat volumes in any given month can mean two things: either you're genuinely receiving fewer attacks (which does happen — attackers shift focus between targets), or the attacks are being blocked so efficiently they're not registering as significant. Looking at your trend over 3–6 months is more meaningful than any single month. The risk that remains is internal: a staff member clicking a link before Proofpoint can re-evaluate it, or a business email compromise attempt that bypasses filters."

### 3.5 "Why Are We Still Getting Spam If We're Paying for Proofpoint?"

**Client-friendly explanation:**
> "No email security tool blocks 100% of spam — the attackers constantly adapt to evade filters. Proofpoint's effectiveness is measured by what it catches, not by whether any spam gets through. If you're seeing an increased spam volume, it usually means either a new spam campaign is active that hasn't been fully categorised yet, or some messages are coming from IP ranges or domains that appear legitimate. We can tune the sensitivity settings or add specific senders to the block list — can you forward me some examples of what's getting through?"

---

## 4. Multi-Tenant Management Tips

### 4.1 Proofpoint Essentials MSP Portal

The Proofpoint Essentials MSP portal (`essentials.proofpoint.com` or your branded portal URL) allows managing all client tenants from one login.

- **Switch clients:** Use the client selector dropdown at the top of the portal
- **Bulk policy updates:** Policy changes in the MSP default template propagate to all clients using that template — review before saving to avoid unintended client impact
- **Audit log:** Admin Console → System → Audit Log — view all admin actions, including which MSP admin made the change

### 4.2 Separating Client Configurations

| Setting | Recommendation |
|---|---|
| Allowed sender lists | Per-client only — never share across clients |
| URL Defense exceptions | Per-client — different clients have different SaaS tools |
| Spam sensitivity | Per-client — different risk tolerances |
| DKIM keys | Per-client — each client needs their own selector |
| Quarantine digest branding | Per-client where licensed |

### 4.3 Common MSP Mistakes to Avoid

| Mistake | Consequence | Prevention |
|---|---|---|
| Updating MX before testing inbound routing | Mail flow outage | Always test routing via Proofpoint delivery test before MX cutover |
| Forgetting to restrict M365 inbound connector to Proofpoint IPs | Proofpoint bypass — attackers can send directly to M365 | M365 connector hardening is part of onboarding checklist (Phase 1) |
| Using the same DKIM selector name across multiple clients | DKIM verification failures on shared selector DNS | Use unique selector names (e.g. `{clientshortname}-pp1`) |
| Applying a template policy change without checking per-client overrides | Unintended policy change in production | Review per-client policy exceptions before template changes |
| Not reviewing TRAP activity after enabling | Legitimate messages pulled without admin awareness | Review TRAP Activity Log weekly for first 30 days after enablement |

---

## Related

- [End User Guide](end-user-guide.md) — User-facing procedures. Send this to clients for distribution to their staff.
- [Admin Guide](admin-guide.md) — Deep-dive configuration for each feature covered in onboarding.
- [Proofpoint TAP API Pipeline](../../api/proofpoint/README.md) — Sentinel integration for MSPs using SIEM services.
- [BEC Incident Response Playbook](../../../../../incident-response/business-email-compromise-playbook.md) — Response procedures when a client reports a suspected BEC incident.
