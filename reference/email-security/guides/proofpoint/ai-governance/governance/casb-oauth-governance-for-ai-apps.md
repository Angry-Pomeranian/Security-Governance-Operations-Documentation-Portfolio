# CASB OAuth Governance for AI Apps

## Overview

OAuth authorisations are the silent attack surface of AI governance. When a user installs an AI browser extension, connects an AI tool to their Google Workspace account, or authorises an AI app to read their OneDrive, they create a persistent trust relationship between the AI vendor and your corporate data — one that continues long after the user forgets they granted it.

This guide covers how to audit existing OAuth authorisations to AI apps, revoke high-risk tokens, block future high-risk OAuth grants, and maintain an ongoing approved AI app list that governs what users are permitted to authorise.

---

## Why OAuth Tokens for AI Apps Are High Risk

Standard OAuth concerns (broad permissions, forgotten authorisations) are amplified for AI tools:

| Risk factor | Why it matters for AI apps |
|---|---|
| **Training data risk** | AI vendors on consumer/free tiers may use OAuth-accessible data to train models |
| **Broad permission grants** | AI browser extensions often request full read/write access "for convenience" |
| **Persistent access** | OAuth tokens do not expire unless revoked — an authorisation from 18 months ago is still active |
| **No visibility by default** | Users cannot see what data the AI tool has already read via OAuth |
| **Extension scope vs expected scope** | An AI writing assistant that "needs" access to all your Google Drive documents is requesting far more than its stated function requires |

---

## Step 1 — Audit All Current OAuth Authorisations to AI Apps

### Find OAuth Authorisations in CASB

1. **CASB → OAuth** (or **Cloud Apps → OAuth Authorisations**)
2. Apply filters:
   | Filter | Value |
   |---|---|
   | App category | Artificial Intelligence (or AI Tools) |
   | Date range | All time (not just recent — legacy tokens are the risk) |
3. Export the full list: **Export → CSV**

### Review Columns in the Export

| Column | What to assess |
|---|---|
| Application name | The AI tool |
| Authorised by | The user who granted the token |
| Connected service | Google Workspace / Microsoft 365 / Dropbox / etc. |
| Permissions | What the AI app can do — see below |
| Grant date | When the token was created |
| Last used | When the app last used the token — never-used tokens from >90 days ago can be revoked |
| Token status | Active / Inactive |

### Classifying Permissions by Risk

| Permission | Risk level | Common context |
|---|---|---|
| `profile`, `email` (read-only basic info) | Low | Expected for SSO/login |
| `Files.Read` / `Drive.readonly` | Medium | AI can read all user files |
| `Files.ReadWrite` / `Drive` (full access) | High | AI can read and modify all user files |
| `Mail.Read` / `Gmail.readonly` | High | AI can read all email |
| `Mail.Send` / `Gmail.compose` | Critical | AI can send email as the user |
| `Sites.ReadWrite.All` | Critical | AI can access all SharePoint sites (M365) |
| `Calendars.ReadWrite` | Medium | AI can read and modify calendar |
| `Contacts.Read` | Medium | AI can read contact lists |
| `ChannelMessage.Read.All` | High | AI can read all Teams messages |

---

## Step 2 — Triage the OAuth List

For each AI app with an active OAuth authorisation, classify it using your CASB app tier:

| App tier | OAuth finding | Action |
|---|---|---|
| **Approved** | Low-permission OAuth (profile/email) | No action |
| **Approved** | High-permission OAuth (file read/write) | Review: is this needed for the app's function? Consider reducing scope |
| **Tolerated** | Low-permission OAuth | Monitor; notify user to review quarterly |
| **Tolerated** | High-permission OAuth | Revoke and notify user |
| **Review** | Any OAuth | Revoke immediately |
| **Blocked** | Any OAuth | Revoke immediately |
| **Unknown app** (not in CASB catalogue) | Any OAuth | Research app, revoke pending assessment |

**Volume-reduction prioritisation:** If the list has hundreds of entries, prioritise revocation in this order:
1. Unknown apps with high permissions
2. Blocked/Review-tier apps (any permission)
3. Consumer AI tools with Mail or full Files access
4. Old tokens last used > 90 days ago

---

## Step 3 — Revoke High-Risk OAuth Tokens

### Via CASB (Individual Revocation)

1. Select the OAuth authorisation
2. **Actions → Revoke OAuth Token**
3. CASB revokes the token via the connected service's API (Google Workspace, Microsoft 365)
4. The AI app immediately loses access — it will prompt the user to re-authorise on next use

### Via Microsoft 365 Admin Center (Bulk Revocation for M365)

For large-scale revocation of M365 OAuth tokens:

1. **M365 Admin Center → Users → [user] → Manage Microsoft 365 apps**
2. Or use PowerShell for bulk:
```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Directory.ReadWrite.All", "Application.ReadWrite.All"

# Find all OAuth grants for a specific AI app by display name
$appDisplayName = "ChatGPT for Google Workspace"  # adjust to actual app name
$servicePrincipal = Get-MgServicePrincipal -Filter "displayName eq '$appDisplayName'"

if ($servicePrincipal) {
    # Get all OAuth2 permission grants for this app
    $grants = Get-MgOauth2PermissionGrant -Filter "clientId eq '$($servicePrincipal.Id)'"

    foreach ($grant in $grants) {
        Write-Output "Revoking grant for user: $($grant.PrincipalId), scopes: $($grant.Scope)"
        Remove-MgOauth2PermissionGrant -OAuth2PermissionGrantId $grant.Id
    }
    Write-Output "Revocation complete. $($grants.Count) grants removed."
} else {
    Write-Output "Service principal not found: $appDisplayName"
}
```

### Via Google Workspace Admin Console (Bulk for Google)

1. **Google Admin → Security → API Controls → App Access Control**
2. Filter by app name
3. **Select → Block access** (revokes all user tokens for that app)
4. Or select individual user tokens: **Connected Apps → [App] → Users → Revoke**

---

## Step 4 — User Communication After Revocation

Users will notice when an AI tool stops working. Proactive communication reduces helpdesk calls and re-authorisation attempts:

**Revocation notification template:**

> Subject: Access to [AI App Name] has been revoked
>
> We have removed the authorisation that was connecting [AI App Name] to your [Google Drive / Microsoft 365 / email] account.
>
> Why: This connection gave [AI App Name] access to your corporate files and data in a way that does not align with our data security policy.
>
> What to do: You may continue to use [AI App Name] as a standalone tool at [URL] without connecting it to your corporate account. If you need AI assistance with corporate documents, [approved alternative].
>
> Questions: Contact [IT security contact].

Send via IT ticketing system, not email (ironic to send a data governance message via an email that Outlook might archive to the same data store the AI had access to).

---

## Step 5 — Block High-Risk OAuth Authorisations Going Forward

Revocation solves the existing problem. You also need to prevent users from re-granting these authorisations.

### CASB OAuth Policy — Block High-Risk AI App Authorisations

1. **CASB → Policies → OAuth Policy → New Policy**
2. Configure:
   | Field | Value |
   |---|---|
   | Policy name | `Block AI App OAuth - High Risk Permissions` |
   | Trigger | OAuth authorisation request |
   | App category | Artificial Intelligence |
   | Permission scope | Contains any of: `Files.ReadWrite`, `Mail.Read`, `Mail.Send`, `Sites.ReadWrite.All`, `Drive` (full access) |
   | Action | Block authorisation + alert security team |
   | User message | "This authorisation has been blocked by IT security policy. Contact [IT contact] to discuss alternatives." |
3. Save

**For blocked-tier apps (any OAuth):**
1. **CASB → App Management → [App] → Policy → Block**
2. Action: Block app access entirely — no OAuth, no browsing
3. This is enforced via CASB's proxy or network integration

### Microsoft 365 — Restrict User OAuth Consent

In M365, restrict users from authorising OAuth apps without admin consent for sensitive permissions:

1. **Azure AD → Enterprise Applications → User Settings**
2. Set: **Users can consent to apps accessing company data on their behalf** → **No** (for sensitive permission scopes)
3. Or configure a consent policy:
   - Allow consent for verified publishers only
   - Require admin approval for apps requesting sensitive scopes (file read/write, mail access)

This means users attempting to authorise an AI app with broad M365 permissions will see an "Admin approval required" prompt rather than being able to grant access unilaterally.

---

## Step 6 — Maintain an Approved AI App List

The approved AI app list is the governance instrument that guides users toward sanctioned tools and supports consistent policy enforcement.

### List Format

| App name | URL | Tier | Approved OAuth connections | Approved for | Review date |
|---|---|---|---|---|---|
| Microsoft Copilot for M365 | copilot.microsoft.com | Approved | M365 (via Microsoft enterprise agreement) | All users | Annual |
| GitHub Copilot Enterprise | github.com/copilot | Approved | GitHub Enterprise only | Developers | Annual |
| Perplexity.ai | perplexity.ai | Tolerated | None — standalone use only | All users (no data submission) | Quarterly |
| [New app] | | Pending review | | | 30 days |

### Governance Process for New Apps

When a user requests approval for a new AI tool:

1. **Discovery:** User submits request via IT portal, or CASB discovery alert identifies new tool in use
2. **Assessment:**
   - CASB risk score review
   - Data handling questionnaire sent to vendor (minimum: data retention, training opt-out, compliance certifications, data residency)
   - Legal/privacy review for tools that will receive PII or confidential data
3. **Decision:**
   - Approved: add to list, configure appropriate Isolation and DLP policies
   - Tolerated: add to list with restrictions, configure Isolation upload/clipboard block
   - Denied: add to CASB blocked list, notify requestor with approved alternatives
4. **Review:** All entries reviewed annually (or quarterly for Tolerated tier)

### Publishing the Approved List

Make the approved AI app list visible to employees:
- Intranet / IT portal: "Approved AI Tools" page
- Include: app name, approved use cases, what you cannot do with it (submit PII, connect to corporate storage, etc.)
- Link to the request process for new tools

A visible approved list reduces shadow AI adoption by providing a legitimate path — users who know which tools are approved are less likely to use unknown ones.

---

## Ongoing Monitoring

| Activity | Frequency | Source |
|---|---|---|
| Review new OAuth grants to AI apps | Weekly | CASB OAuth alert |
| Review approved list for new or changed apps | Monthly | CASB app discovery |
| Audit for re-granted revoked tokens | Monthly | CASB OAuth → filter: previously revoked apps |
| Vendor data handling questionnaire renewal | Annual | Approved app list review dates |
| Review M365 enterprise app consent log | Quarterly | Azure AD → Enterprise Apps → Consent |

---

## DSPM Note

OAuth governance controls what AI apps can access via user-granted permissions. It does not address:
- What data Microsoft Copilot for M365 can access via its native M365 integration (Copilot is not subject to user OAuth consent — it uses its own Microsoft service principal)
- Overexposed SharePoint/OneDrive data that any authorised user or service can access

For Copilot for M365 data exposure mapping, see the [DSPM Positioning Note](../dspm-note.md).

---

## Related

- [Shadow AI Discovery Guide (CASB)](../visibility/shadow-ai-discovery-casb.md) — Initial OAuth audit that feeds into this ongoing governance process.
- [Adaptive AI Access Controls](adaptive-ai-access-controls.md) — Using OAuth risk signals to step up Isolation controls.
- [Investigating a GenAI Data Loss Alert](../investigation/investigating-genai-data-loss-alert.md) — What to do when an OAuth-enabled AI app has accessed sensitive data.
