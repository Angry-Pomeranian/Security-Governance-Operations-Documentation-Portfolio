# Guide: Integrating Azure DevOps Audit Logs into Microsoft Sentinel

This guide walks you through connecting Azure DevOps (ADO) audit logs to Microsoft Sentinel using the **Azure DevOps Auditing** data connector (Codeless Connector Platform).  
By the end of this process, Sentinel will automatically ingest audit events from ADO into your Log Analytics workspace.

---

## 1. Overview

Azure DevOps audit logs track activity such as project creation, policy changes, permission updates, and sign-ins.  
Integrating these into Microsoft Sentinel provides:

- Centralized logging for compliance and security investigations
- Real-time detection and alerting on high-risk DevOps activity
- Extended retention beyond ADO’s default 90-day log window

---

## 2. Prerequisites

Before starting, ensure you have:

- A Microsoft Sentinel workspace set up
- Appropriate roles:
  - **Microsoft Sentinel Contributor** on the workspace
  - **Log Analytics Contributor** (to read shared keys)
- An **Azure DevOps Organization** with:
  - Auditing **enabled**
  - Your connector account as an **organization member**
  - **View audit log** permission set to **Allow** (explicitly) at the organization level
- An **App Registration** in Microsoft Entra ID with:
  - Delegated API permission: **Azure DevOps → vso.auditlog (Audit Read Log)**
  - Admin consent granted
  - A valid **Client Secret** (Value) stored securely (e.g., Key Vault)

---

## 3. Step-by-Step Setup

### Step 1 — Verify Auditing in Azure DevOps
1. Navigate to:
```

[https://dev.azure.com/](https://dev.azure.com/)<org-name>/\_settings/auditlog

````
2. Confirm **Auditing** is enabled.
3. Check the **Logs** tab for recent events.
4. If no events exist, create a low-impact change such as:
- Create and delete a test project
- Toggle an organization setting and revert it

---

### Step 2 — Create / Configure the Entra App Registration
1. Go to **Microsoft Entra admin center** → **App registrations** → **New registration**.
2. Fill in:
- **Name**: `<app-name>`
- **Supported account types**: Single tenant (recommended)
- **Redirect URI** (Web):
  ```
  https://portal.azure.com/TokenAuthorize/ExtensionName/Microsoft_Azure_Security_Insights
  ```
3. Click **Register**.
4. Under **API permissions**:
- Add **Azure DevOps** → Delegated → `vso.auditlog` (*Audit Read Log*)
- Grant admin consent
5. Under **Certificates & secrets**:
- Create a new **Client secret**
- Store the **Value** securely (not the Secret ID)

---

### Step 3 — Connect in Microsoft Sentinel
1. Open your Sentinel workspace.
2. Go to **Data connectors** → Search for **Azure DevOps Auditing** → **Open connector page**.
3. Click **Connect** and provide:
- **Authorization Endpoint (v2)**:
  ```
  https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/authorize
  ```
- **Token Endpoint (v2)**:
  ```
  https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token
  ```
- **API Endpoint**:
  ```
  https://auditservice.dev.azure.com/<org-name>/_apis/audit/auditlog?api-version=7.2-preview
  ```
- **App Client ID**: `<client-id>`
- **App Client Secret (Value)**: `<client-secret>`
4. Sign in using the account with **View audit log** permission.
<img width="939" height="546" alt="image" src="https://github.com/user-attachments/assets/498183ea-8ae0-43b4-8186-5c2503c02bf9" />

---

### Step 4 — Validate Data Ingestion
1. Wait 5–15 minutes after connecting.
2. In Sentinel **Logs**, run:
```kusto
ADOAuditLogs_CL
| order by TimeGenerated desc
| take 50
````

3. If no results appear, try:

   ```kusto
   AzureDevOpsAuditing
   | order by TimeGenerated desc
   | take 50
   ```

---

## 4. Troubleshooting

| Issue                              | Possible Cause                        | Fix                                  |
| ---------------------------------- | ------------------------------------- | ------------------------------------ |
| **403 Forbidden** when connecting  | Missing View audit log permission     | Set to **Allow** in ADO Org settings |
| No data after connect              | No recent events in ADO audit log     | Generate a test event                |
| Connected but “No data received”   | Token expired or consent incomplete   | Disconnect and reconnect             |
| **401 Unauthorized**               | Wrong client secret / Tenant / App ID | Verify all values                    |
| API returns events, Sentinel empty | Polling delay                         | Wait 15–20 minutes after reconnect   |

---

## 5. Maintenance

* **Secret expiry**: Track expiry in CMDB or Key Vault alerts (rotate before expiration)
* **Access reviews**: Confirm the connector account retains **View audit log** permission
* **Conditional Access**: Ensure CA policies do not block token refresh for this connection

---

## 6. References

* [Azure DevOps Auditing](https://learn.microsoft.com/azure/devops/organizations/audit/azure-devops-auditing)
* [Microsoft Sentinel Data Connectors](https://learn.microsoft.com/azure/sentinel/connect-data-sources)

---

## 7. Architecture Diagram

![Azure DevOps Audit Logs to Sentinel Flow](Azure_DevOps_Audit.png)

```
