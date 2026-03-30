# Azure AD B2C — Passwordless Sign-In Setup

Azure Active Directory B2C is Microsoft's customer identity and access management (CIAM) service. It is a **separate service from Entra ID** designed for external-facing applications — allowing customers, partners, and public users to sign in to your apps using their own identities (social accounts, local accounts, or enterprise IdPs).

> **Important:** Azure AD B2C uses a **dedicated B2C tenant** that is separate from your organisation's Entra ID (corporate) tenant. Do not confuse B2C with Entra External Identities, which handles guest access within your existing tenant.

---

## 1. Setting Up Sign-In for Single-Page Apps

<img width="2400" height="1350" alt="1_Setting-Up-Sign-In-for-Single-Page-Apps-with-Azure-AD-B2C" src="https://github.com/user-attachments/assets/481c1290-b805-4707-9592-c9ab74045be4" />

B2C integrates with Single-Page Applications (SPAs) via **MSAL.js** using the **Authorization Code flow with PKCE** (Proof Key for Code Exchange). This is the current recommended flow — the older implicit flow is deprecated.

The B2C tenant issues tokens (ID token, access token) after the user completes a **User Flow** or **Custom Policy** (Identity Experience Framework).

---

## 2. Important Notes About Your Tenant

<img width="2400" height="1350" alt="2_Important-Notes-About-Your-Tenant" src="https://github.com/user-attachments/assets/cad28dde-6edc-412d-8ed7-fd276c128330" />

Key points to understand before building with B2C:
- B2C has its own **domain** (e.g. `contoso.b2clogin.com` or a custom domain)
- **Billing** is MAU-based (Monthly Active Users) — first 50,000 MAU/month are free
- **User flows** handle standard sign-in/sign-up/password-reset scenarios; **Custom Policies** (XML-based) handle complex flows
- B2C uses its own **policy namespace** — `B2C_1_` for user flows, `B2C_1A_` for custom policies
- B2C **cannot** enforce Conditional Access against the same policies as your corporate Entra ID tenant

---

## 3. Prerequisites and Setup

<img width="2400" height="1754" alt="3_Prerequisites-and-Setup" src="https://github.com/user-attachments/assets/c1e72a9c-0e65-476f-91e2-5120fab55dc6" />

**Before creating your B2C tenant:**
- Active Azure subscription (B2C tenant is linked to a subscription for billing)
- Global Administrator role on the Azure subscription
- Decision on **data residency region** — B2C data is stored in a specific Azure region; choose based on compliance requirements (Australia East for AU data residency)
- For Australian data residency: the **Go Local add-on** must be configured (see Section 11)

---

## 4. Authentication Process

<img width="2400" height="2292" alt="4_Authentication-Process" src="https://github.com/user-attachments/assets/fe2da995-cc2f-4282-94f9-fcf447dacf0c" />

The B2C authentication flow for a SPA:

1. User clicks "Sign In" in the app
2. App redirects to B2C login endpoint with an **Authorization Request** (including `client_id`, `redirect_uri`, `scope`, PKCE challenge)
3. B2C presents the user flow UI (sign-in/sign-up page, branded to your organisation)
4. User authenticates (local account, social IdP, or enterprise IdP via federation)
5. B2C returns an **Authorization Code** to the redirect URI
6. App exchanges the code for tokens using PKCE verifier
7. App receives **ID token** (user identity claims) and **access token** (API access)

---

## 5. Accessing Protected Resources

<img width="2400" height="1350" alt="5_Accessing-Protected-Resources" src="https://github.com/user-attachments/assets/6eede2f3-d323-449c-9076-0f343751ff68" />

Access tokens issued by B2C are scoped to your registered API. When calling protected resources:
- Include the access token in the `Authorization: Bearer <token>` header
- Validate the token on the server: check `iss` claim (matches your B2C tenant), `aud` claim (matches your API), and token expiry
- Use the ID token only for user identity in the client app — do not use it to call APIs

---

## 6. Creating an Azure AD B2C Tenant

<img width="2400" height="1350" alt="6_Creating-an-Azure-Active-Directory-B2C-Tenant" src="https://github.com/user-attachments/assets/1d71d421-9558-4428-87f4-a411c1b7c5c8" />

1. Azure portal → `Create a resource` → search `Azure Active Directory B2C`
2. Select **Create a new Azure AD B2C Tenant**
3. Fill in:
   - Organisation name (e.g. `Contoso Customers`)
   - Initial domain name (e.g. `contosocustomers`) — becomes `contosocustomers.onmicrosoft.com`
   - Country/Region — **this cannot be changed after creation**
   - Subscription and Resource Group for billing linkage
4. Click **Review + Create**

---

## 7. Important Considerations Before You Begin

<img width="2400" height="1350" alt="7_Important-Considerations-Before-You-Begin" src="https://github.com/user-attachments/assets/576cecd7-672e-48c4-b218-9c92263f5166" />

- **Region is permanent** — once set, the B2C tenant region cannot be changed; data residency is determined at creation
- **Custom domains** can be added later via `Domains` in the B2C tenant settings (e.g. `auth.contoso.com` instead of `contosocustomers.b2clogin.com`)
- **Tenant cannot be merged** with your corporate Entra ID tenant — keep credentials and admin accounts separate
- **Avoid using personal Microsoft accounts** as B2C tenant admins — use work accounts or dedicated service accounts

---

## 8. Prerequisites for Tenant Creation

<img width="2400" height="1350" alt="8_Prerequisites" src="https://github.com/user-attachments/assets/83ead98c-c179-4800-8d6a-a07b9edc16a2" />

- Azure subscription (Owner or Contributor role)
- At minimum one admin account that is not tied to the subscription's corporate Entra ID tenant (to avoid lockout scenarios)
- Decision made on initial domain name (cannot be changed later)
- Compliance sign-off on data residency region

---

## 9. Creating Your Azure AD B2C Tenant

<img width="2400" height="1690" alt="9_Creating-Your-Azure-AD-B2C-Tenant" src="https://github.com/user-attachments/assets/07b6ca75-dabf-423a-a08a-7779ce774be8" />

After the tenant is created:
1. Switch directory to the new B2C tenant in the Azure portal (top-right → Directories)
2. Navigate to **Azure AD B2C** in the portal search bar
3. Register your application: `App registrations → + New registration`
4. Create your first **User Flow**: `User flows → + New user flow → Sign up and sign in (Recommended)`

---

## 10. Configuring Your New Tenant

<img width="2400" height="2290" alt="10_Configuring-Your-New-Tenant" src="https://github.com/user-attachments/assets/14669095-6a01-4346-bfac-de7ffbfe7abc" />

Initial configuration checklist:
- [ ] Register the application (client ID generated)
- [ ] Create at least one User Flow (sign-in/sign-up)
- [ ] Configure identity providers (local account, Google, Apple, enterprise IdP via SAML/OIDC)
- [ ] Customise the UI (company branding, custom HTML templates)
- [ ] Set token lifetimes (access token default 1h; refresh token default 14 days)
- [ ] Enable MFA for the user flow if required

---

## 11. Go Local Add-on for Data Residency

<img width="2400" height="2026" alt="11_Go-Local-Add-on-for-Data-Residency" src="https://github.com/user-attachments/assets/f8860579-6ec1-488d-8f7b-09872dddcf53" />

For Australian data residency requirements, Microsoft offers the **Go Local add-on** which ensures user data is stored within Australian datacentre boundaries.

- The add-on must be requested via Microsoft/your licensing agreement — it is not self-service
- Create the B2C tenant in the **Australia** region before requesting Go Local; the region cannot be changed post-creation
- Verify data residency: `Azure AD B2C → Properties → Data location`

---

## 12. Accessing Your New B2C Tenant

<img width="2400" height="1450" alt="12_Accessing-Your-New-B2C-Tenant" src="https://github.com/user-attachments/assets/07c91586-2e1a-44e2-80c6-466240ec4bcd" />

After initial setup:
- Access the B2C tenant via Azure portal → Directories → switch to B2C tenant
- Bookmark the direct B2C URL: `portal.azure.com/<b2c-tenant-id>`
- Manage users at: `Azure AD B2C → Users`
- Monitor with: `Azure AD B2C → Audit logs` and `Sign-in logs`

---

## Related

- [Microsoft Authenticator](../microsoft-auth/README.md) — Authenticator can be used as an MFA method within B2C user flows.
- [Passkey (FIDO2)](../passkey/README.md) — FIDO2 keys can be configured as an authentication method in B2C Custom Policies.
- [MFA Deployment Guide](../../mfa/README.md) — MFA for internal (corporate) Entra ID users.
- [Identity Access Overview](../../../README.md)
