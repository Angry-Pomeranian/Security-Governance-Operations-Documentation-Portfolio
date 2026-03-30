## 1. **Concept Overview**

You’ll be combining:

* **Passwordless sign-in** (already enabled via WHfB/passkeys).
* **PIM (Privileged Identity Management)** to grant temporary role membership to a *security group* that controls server admin access.
* **Azure AD Security Groups** assigned to server local admins via **Azure AD role assignments** or **Azure Arc–based RBAC**.
* **Time-bound role activation** so that after the set duration, the user loses admin rights.
* **Datto RMM** for session brokering/remote management.

---

## 2. **High-Level Flow**

1. **User signs in** to Microsoft Entra with WHfB or passkey (no password).
2. **User requests elevation in PIM** for the Azure AD group that maps to server local admins.
3. **User sets justification and time range** for the role.
4. **PIM grants group membership** for the chosen duration.
5. **Azure AD → Azure Arc sync** adds user to local Administrators on the target server(s).
6. **User connects to server** (via RDP, PowerShell Remoting, or Datto RMM session) using their existing Entra sign-in.
7. **When finished**, the user logs off; PIM automatically removes them from the group when time expires.

---

## 3. **Configuration Steps**

### **A. Prepare the Azure AD Group**

* Create a **cloud-only security group** (e.g., `Server-Admins-JIT`).
* Membership type: *Assigned*.
* No direct members — all assignments go via PIM.
* Assign the group to:

  * **Local Administrators** on Azure Arc servers (use `Azure AD Join`/`Hybrid Join` + [Device Local Administrator Role Mapping](https://learn.microsoft.com/azure/active-directory/devices/assign-local-admin)) OR
  * Arc-enabled server RBAC if you want management via Azure portal.

---

### **B. Enable PIM for the Group**

1. Go to **Entra Admin Center → PIM**.
2. Manage **Groups**.
3. Enable **Azure AD role-assignable** for your group if you want privileged access on resources.
4. Set **Eligible assignments** for the target users.
5. Configure **Activation settings**:

   * Require MFA on activation (you already have MFA).
   * Set **Maximum activation duration** (e.g., 1–4 hours).
   * Require justification.
   * Optionally require approval.

---

### **C. Configure Passwordless**

* Already in place (WHfB/passkeys), so no change here.
* Ensure servers are **Hybrid Joined** or **Azure AD Joined** so WHfB SSO works.
* For RDP, enable [Entra Kerberos with WHfB](https://learn.microsoft.com/azure/active-directory/authentication/howto-authentication-passwordless-deployment) or Smartcard Logon.

---

### **D. Azure Arc + Local Admin Sync**

* In Azure Arc, ensure **Hybrid Azure AD Join** is completed.
* Use **Local Administrator role mapping** in Endpoint Manager or Group Policy Preferences to map the PIM-controlled group to local Administrators.
* This means when the user is added to the group (via PIM), they instantly get local admin rights on the server.

---

### **E. Datto RMM Integration**

* Ensure Datto RMM agents authenticate sessions via the signed-in Windows account (Kerberos/NTLM).
* Optionally, restrict RMM access to only those with active PIM role membership using:

  * Conditional Access policies scoped to Datto RMM app (if Azure AD SSO is set up for Datto).
  * Or role-based permissions inside Datto tied to the same PIM group.

---

## 4. **Testing Plan (Azure Arc Servers First)**

1. Confirm WHfB login works for target servers (Arc + Hybrid Join).
2. Map your PIM-enabled group to local admins on Arc server.
3. Activate PIM role → verify group membership → RDP into server (passwordless).
4. Expire the role → confirm local admin rights are removed.

---

## 5. **Security Considerations**

* Enforce **approval workflow** for high-privilege roles.
* Log all PIM activations in **Microsoft Sentinel**.
* Enable **session recording** in RDP for compliance if needed.
* Consider **Just Enough Administration (JEA)** for PowerShell-based access.

---

## 6. **References**

* [Passwordless authentication options – Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-passwordless)
* [Configure PIM for Groups](https://learn.microsoft.com/en-us/entra/id-governance/pim-for-groups)
* [Manage local admins via Azure AD groups](https://learn.microsoft.com/en-us/azure/active-directory/devices/assign-local-admin)

