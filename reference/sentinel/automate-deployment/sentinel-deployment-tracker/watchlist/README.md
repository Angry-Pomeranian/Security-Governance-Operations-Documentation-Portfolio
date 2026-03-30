# Define, Track, and Complete Your Sentinel Deployment and Migration Tasks

This Watchlist powers the **Deployment and Migration Tracker** workbook in the Microsoft Sentinel gallery (or GitHub). It lets you capture, monitor, and close out all the critical steps in your Sentinel rollout or migration. Be sure to deploy it alongside the workbook to get the full experience!

---

## Prerequisites

1. **Azure Subscription**
2. **Microsoft Sentinel workspace**
3. **Sentinel Contributor** role on the Resource Group containing your Sentinel workspace (and know the workspace name)

> **Note:** If you plan to deploy Defender or Azure AD connectors, you’ll also need **Global Administrator** or **Security Administrator** permissions at the tenant level.

---

## Deployment Options

### Option 1: “Deploy to Azure” Button

1. Click the **Deploy to Azure** button below.
2. In the Azure Portal, pick your **Subscription**, **Resource Group**, and the **Sentinel workspace**.
3. Click **Review + create**, then **Create**.
4. In 1–2 minutes the Watchlist will appear under your Sentinel workspace.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzure-Sentinel%2Fmaster%2FWatchlists%2FDeploymentandMigration%2Fazuredeploy.json)

---

### Option 2: Custom Template Deployment

1. Open the JSON template in the GitHub folder and click **Raw**.
2. Copy the raw JSON.
3. In the Azure Portal search bar, type **Deploy a custom template** and select it.
4. Choose **Build my own template in the editor** and paste the JSON.
5. Select your **Subscription** and **Resource Group**.
6. Click **Review + create**, then **Create**.
7. In 1–2 minutes the Watchlist will appear under your Sentinel workspace.
