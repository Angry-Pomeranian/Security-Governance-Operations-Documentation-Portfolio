# Microsoft Sentinel Deployment and Migration Tracker

This workbook offers a guided, multi-tab tracker to plan, monitor, and report on your Microsoft Sentinel deployment or migration project. It leverages a Sentinel Watchlist named **Deployment** to drive its task list and completion scoring.

---

## 📋 Features

* **Workspace & Time-Range Selector**
  Choose any Log Analytics workspace and time window; all queries honor your selection.

* **Phase-Based Tabs**

  * **Deployment**
  * **Data Connectors**
  * **Analytics**
  * **Workbooks**
  * **Automation**
  * **UEBA**
  * **Data Management**
    Click a tab to filter the task list to that phase.

* **Watchlist-Driven Task List**
  Reads tasks from your **Deployment** watchlist, displaying:

  * Priority
  * Category
  * Action
  * Status (Not Started, In Progress, Completed)
  * Last Update
  * Blocked flag
  * Completion Date

* **Completion Score**
  Calculates % of tasks marked **Completed** across all phases.

* **Guidance Panels**

  * **General Tips** (toggleable) link to Microsoft migration guidance.
  * **Instructions** (toggleable) explain how to deploy and configure the watchlist.

---

## 🚀 Prerequisites

1. **Microsoft Sentinel workspace**
2. **Deployment Watchlist**
   You must create a watchlist named `Deployment` containing your project task CSV. See the ARM/terraform template in this repo under `Watchlists/Deployment/`.

---

## ⚙️ Deployment Steps

1. **Deploy the Deployment Watchlist**
   Use the provided ARM or Terraform template to upload a CSV of your project tasks into a Sentinel watchlist called `Deployment`.
2. **Import the Workbook**

   * In the Azure portal, navigate to **Microsoft Sentinel → Workbooks**
   * Click **+ Add → Upload workbook**
   * Paste the contents of `MicrosoftSentinelDeploymentandMigrationTracker.json` and save.
3. **Configure Parameters**

   * Select your **Workspace**
   * Set your **Time Range**
   * Toggle **MigrationTips** or **Instructions** to “Yes” to reveal guidance sections.

---

## 🎯 How to Use

1. **Select Your Scope**
   Pick the subscription/workspace and timeframe for your migration or ongoing operations.

2. **Track by Phase**
   Click any of the phase tabs to view only relevant tasks.

3. **Update Status**
   Go to your `Deployment` watchlist in Sentinel and mark tasks as “Completed” or “Blocked.” Changes will reflect instantly in the workbook.

4. **Monitor Progress**
   Watch the **Completion Score** tile update to see overall progress at a glance.

---

## 🔍 How It Works

* **Watchlist Queries**
  The workbook uses Kusto’s `_GetWatchlist('Deployment')` function to pull your task entries.
* **Filtering & Aggregation**
  Each phase tab applies a simple filter on the watchlist data.
* **Dynamic Scoring**
  A Kusto query computes the percentage of tasks where `Status == "Completed"`.

---

## 📖 Further Reading

* [Deployment Watchlist template (ARM)](/Watchlists/Deployment/azuredeploy.json)
* [Migration Guidance on Microsoft Docs](https://docs.microsoft.com/azure/sentinel/migration-guide)

---

> **Tip:** Keep your watchlist CSV under version control to track changes over time, and use Sentinel’s built-in tagging to manage ownership and due dates.
