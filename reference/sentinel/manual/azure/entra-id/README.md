# Connecting the Microsoft Entra ID Connector to Microsoft Sentinel

<img width="1332" height="1115" alt="image" src="https://github.com/user-attachments/assets/a9ce4386-057c-4016-b2a6-6993fb151e18" />


## Prerequisites

Before you begin, ensure the following:

- **Workspace Permissions**  
  You have **Read and Write** permissions on the Microsoft Sentinel workspace.

- **Tenant Permissions**  
  You have one of the following Azure AD roles in the tenant you are connecting:
  - Global Administrator
  - Security Administrator
  - Security Reader

---

## About This Connector

The Microsoft Entra ID (formerly Azure Active Directory) connector streams sign-in, audit, and provisioning activity logs from your tenant into Microsoft Sentinel for analysis, investigation, and alerting.

Supported log types:
- **Sign-ins**
- **Audit logs**
- **Provisioning logs**

---

## Configuration Steps

1. **Open the Connector**
   - In the Azure portal, go to:  
     `Microsoft Sentinel` → select your workspace → `Content Management` → `Data Connectors`.
   - Search for **Microsoft Entra ID** and open the connector page.

2. **Enable the Connection**
   - In the configuration pane, click **Open connector page** (if applicable).
   - Under **Configuration**, select **Connect**.

3. **Select Log Types to Ingest**
   - Choose the categories of logs you want to send to Sentinel:
     - **Sign-ins** — Records of authentication attempts and outcomes.
     - **Audit logs** — Directory changes, policy updates, and role assignments.
     - **Provisioning logs** — Details of identity provisioning operations.
   - Click **Apply Changes**.

4. **Verify Tenant**
   - Ensure you are connected to the correct Microsoft Entra ID tenant.
   - If you have multiple tenants, repeat the connection process for each as required.

---

## Notes
- Data ingestion may take several minutes to start after enabling the connector.
- For long-term retention, ensure your Sentinel workspace has a retention policy aligned to your compliance requirements.
- You can disable or modify the connected log types at any time from the connector settings.
