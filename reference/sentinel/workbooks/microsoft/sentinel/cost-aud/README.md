# Microsoft Sentinel Workbook AUS Cost Summary

**Author:** Nicole Kemp  
**Date:** 2025-07-18  
**Version:** v1  
**Description:**  
> This JSON can be ingested into Microsoft Sentinel to show a workbook of current costs for the service, altered for AUD (Australian Dollar).

---

## 📄 Overview

This workbook provides:

- **Region:** Australia Southeast  
- **Currency:** AUD  
- **Rates:** Ingestion **6.2 AUD/GB** | Retention **0.15 AUD/GB-month**

It calculates:

1. **Ingestion cost** = total GB ingested × 6.2 AUD  
2. **Retention cost** = total GB retained (> 90 days) × 0.15 AUD/month  
3. **Breakdown by log type** and daily averages.

---

## 🚀 Deployment

1. In the Azure Portal, navigate to your Microsoft Sentinel workspace.  
2. Click **Workbooks** → **+ New** → **Advanced Editor**.  
3. Paste the JSON file content.  
4. Click **Save**, give it a name (e.g. “AUS Cost Summary”), and **Open**.  
5. Adjust the **Workspace**, **TimeRange**, **Price**, and **RetentionPrice** parameters as needed.  
6. Hit **Refresh** (🔄) to recalculate with your settings.

---

## 🔒 Security Considerations

- **Input validation:** Ensure parameter values are validated/formatted correctly.  
- **Authentication:** Use Azure Managed Identity or a least-privilege service principal.  
- **Authorization:** Grant the identity **Reader** role on the target workspace.  
- **Logging/Audit:** Never log secrets; log only high-level success/failure events.  
- **Error handling:** Fail gracefully without leaking sensitive details.  
- **Dependencies:** Pin to known-good JSON schemas; scan templates for risks.

---
Example of what it looks like:
