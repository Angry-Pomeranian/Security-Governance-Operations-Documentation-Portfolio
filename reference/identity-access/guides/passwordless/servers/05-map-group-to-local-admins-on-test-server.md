## **Step 5 – Map Group to Local Admins on Test Server**

Since `a1ms-pilot2025s` is **Arc-enabled & Hybrid Joined**:

1. On the server, go to **Computer Management → Local Users and Groups → Groups → Administrators**.
2. Add `Server-Admins-JIT-Test` (Azure AD group) as a member.

   * In Azure Arc scenarios, ensure that **AzureAD\GroupName** format is used.
3. Alternatively, do it centrally in **Endpoint Manager** under **Device → Device Settings → Local admin role assignments**.

