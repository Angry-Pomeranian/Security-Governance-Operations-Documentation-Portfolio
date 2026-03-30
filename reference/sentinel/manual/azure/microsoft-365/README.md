# Connecting the Microsoft 365 (formerly Office 365) Connector to Microsoft Sentinel

<img width="781" height="493" alt="image" src="https://github.com/user-attachments/assets/68db8455-f723-490d-8981-db56c3551e9d" />


## Prerequisites

Before you begin, ensure the following:

- **Workspace Permissions**  
  You have **Read and Write** permissions on the Microsoft Sentinel workspace.

- **Tenant Permissions**  
  You are assigned one of the following Azure AD roles in the workspace's tenant:  
  - Global Administrator  
  - Security Administrator  

---

## Configuration Steps

1. **Open the Microsoft 365 Connector in Sentinel**
   - In the Azure portal, navigate to:  
     `Microsoft Sentinel` → select your workspace → `Content Management` → `Data Connectors`
   - Search for **Microsoft 365 (formerly Office 365)** in the connector list.

2. **Select Record Types to Ingest**
   - In the connector configuration pane, choose the activity log types you want to collect:
     - **Exchange**
     - **SharePoint**
     - **Teams**
   - Click **Apply Changes**.

3. **Manage Previously Connected Tenants**
   - Microsoft Sentinel supports a **single-tenant connection** for the Microsoft 365 connector.
   - If you have previously connected tenants:
     - Review and modify them as needed.
     - Click **Save** to update your configuration.

---

## Notes
- Data ingestion begins shortly after configuration, but initial population may take several minutes.
- You can disable or reconfigure the connector at any time from the same menu.
- Ensure that Microsoft 365 audit logging is enabled in your tenant for the selected record types.

```
