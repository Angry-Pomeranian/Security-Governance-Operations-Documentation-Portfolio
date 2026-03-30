## **Step 1 – Create the Test Security Group**

Ref: [Groups in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/groups-concept)

1. Go to **Entra Admin Center → Groups → All groups → New group**.
2. **Group type**: Security.
3. **Group name**: `Server-Admins-JIT-Test`.
4. **Group description**: *Test group for PIM-based JIT admin on -pilot2025s*.
5. **Membership type**: Assigned.
6. **Azure AD roles can be assigned to the group** → **Yes** (this makes it “role-assignable”).
7. Create the group.

---

## **Step 2 – Enable PIM for the Group**

Ref: [PIM for Groups – Overview](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/concept-pim-for-groups)

1. Go to **Entra Admin Center → Privileged Identity Management**.
2. Under **Manage**, select **Groups**.
3. Locate `Server-Admins-JIT-Test` and **Manage settings**.
4. If PIM hasn’t been enabled for the group yet, choose **Enable**.
5. Once enabled, open the group in PIM.

---

## **Step 3 – Assign Eligible Membership**

Ref: [Configure role settings for a group](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/groups-role-settings)

1. In PIM for Groups, choose **Assignments → Add assignments**.
2. **Select group**: `Server-Admins-JIT-Test`.
3. **Membership type**: *Member* (not Owner — Owner can change group settings).
4. **Select members**: Add **your account**.
5. **Assignment type**: Eligible.
6. Confirm and assign.

---

## **Step 4 – Configure Activation Settings**

In PIM → `Server-Admins-JIT-Test` → **Settings → Member settings**:

* **Activation maximum duration (hours)**: Set to your desired test window (e.g., 1–2 hours).
* **Require justification**: Yes.
* **Require MFA on activation**: Yes (you already have MFA).
* **Require approval to activate**: No (for testing; can enable later).
* Save settings.

---

## **Step 5 – Map Group to Local Admins on Test Server**

Since `-pilot2025s.` is **Arc-enabled & Hybrid Joined**:

1. On the server, go to **Computer Management → Local Users and Groups → Groups → Administrators**.
2. Add `Server-Admins-JIT-Test` (Azure AD group) as a member.

   * In Azure Arc scenarios, ensure that **AzureAD\GroupName** format is used.
3. Alternatively, do it centrally in **Endpoint Manager** under **Device → Device Settings → Local admin role assignments**.

---

## **Step 6 – Test PIM Activation**

1. Sign in to Entra → **PIM → Groups** → `Server-Admins-JIT-Test`.
2. **Activate** → give justification → set time limit (e.g., 1 hour).
3. Wait for membership propagation (Arc typically syncs in \~5 min).
4. From your admin PC:

   * RDP into `-pilot2025s.` using your Entra account + WHfB/passkey (no password).
   * Confirm local admin rights (open elevated PowerShell or check “net localgroup administrators”).

---

## **Step 7 – Validate Role Expiry**

1. Let the activation time expire or manually deactivate in PIM.
2. Attempt to perform an admin action — it should fail.
3. Check local Administrators group on the server — your Entra account/group should be gone.

---

## **Extra Notes**

* Since **PIM is already configured org-wide**, you’re skipping all the tenant onboarding steps.
* Because `-pilot2025s` is Azure Arc–enabled and Server 2025, the WHfB SSO should work provided device trust and Kerberos cloud ticketing are set.
* If group sync seems slow, you can **force sync** via `dsregcmd /refreshprt` or restart the Arc agent.

