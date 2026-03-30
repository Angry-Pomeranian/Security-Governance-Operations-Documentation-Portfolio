# Connecting the Azure Activity Connector to Microsoft Sentinel

<img width="1902" height="1101" alt="image" src="https://github.com/user-attachments/assets/06df549a-a5d7-459a-9a07-ef72cc1f4d94" />



## Prerequisites

Before you begin, ensure the following:

- **Workspace Permissions**  
  You have **Read and Write** permissions on the Microsoft Sentinel workspace.

- **Policy Permissions**  
  You have the **Owner** role assigned for each **Azure Policy** assignment scope.

- **Subscription Permissions**  
  You have the **Owner** role on each subscription you will connect.
---

## About This Connector

The Azure Activity connector now uses the **Diagnostics Settings** back-end pipeline.  
This provides:
- Increased functionality
- Better consistency with resource logs
- Ability to govern at scale with Azure Policy

---

## Configuration Steps

### 1. Disconnect Legacy Method (If Applicable)
- If any subscriptions are still connected using the **legacy method**:
  - In the connector configuration pane, click **Disconnect All**.
  - Proceed to the next step.

> If no subscriptions are using the legacy method, skip to Step 2.

---

### 2. Connect Subscriptions via Diagnostics Settings (New Pipeline)
This process uses **Azure Policy** to apply a single Azure Subscription log-streaming configuration to a defined scope.

1. **Launch the Azure Policy Assignment Wizard** from the connector configuration pane.
2. **Basics Tab**  
   - Under **Scope**, click the three-dot (…) button and select your desired resources or management group.
3. **Parameters Tab**  
   - From the **Log Analytics workspace** drop-down, select your Microsoft Sentinel workspace.
   - Keep all log and metric types you wish to ingest marked as **True**.
4. **Remediation Tab**  
   - Select **Create a remediation task** to apply the policy to existing resources.
5. **Review + Create**  
   - Review your settings and click **Create** to apply the policy.

---

## Notes
- Once configured, Azure Activity logs will begin streaming into Sentinel.
- Applying the policy to a management group ensures that **all current and future subscriptions** within that group will be connected automatically.
- You can reconfigure or remove the policy at any time from the **Azure Policy** blade.
```
