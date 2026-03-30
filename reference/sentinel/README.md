# Sentinel

This repository contains automation artifacts, workbooks, and analytic rules for **Microsoft Sentinel** (Azure-native SIEM/SOAR).  
It supports our internal deployment, detection engineering initiatives, and SOC handover readiness.

---
## 📁 Repository Structure
```

/
├── workbooks/
│   ├── Microsoft/           # Custom Microsoft Sentinel workbooks
│   └── <other vendors>/     # Future workbook sets (e.g., Defender, AWS)
│
├── rules/                   # Analytic rules (KQL-based detections)
│   ├── scheduled/
│   ├── nrt/
│   └── fusion/
│
├── scripts/                 # KQL queries, automation helpers, enrichment scripts
├── templates/               # Deployment templates (ARM/Bicep)
└── docs/                    # Internal documentation

```

---
## ✅ Current Tasks
- [ ] **Rename `workbooks/Microsoft-workbooks/` ➜ `workbooks/Microsoft/`**
- [ ] **Fine-tune existing Microsoft Sentinel workbook JSON files**
- [ ] **Finish uploading remaining workbook artifacts**
  
  ![Workbook Progress](https://github.com/user-attachments/assets/338ecb4c-4372-4c07-91df-e4d66f5292a3)

---
## 🛠️ Upcoming Work
- [ ] **Begin developing analytic rules under `rules/`**
  - Focus areas:
    - Identity misuse (risky sign-ins, impossible travel, privilege abuse)
    - Endpoint anomalies (CrowdStrike, Defender)
    - Azure resource abuse and misconfigurations

  ![Rule Development](https://github.com/user-attachments/assets/d8fdfc38-97f6-4b37-9233-480fe9e681d9)

---
## 🔒 Internal Use Only
> This repository is **private** and intended for internal use only.  
> It supports production readiness and collaboration between engineering and security teams.
- Do **not** share externally without approval.

---
## 📌 Notes
- All workbooks must validate within the Sentinel portal or template deployment.
- Detection rules should follow naming and tagging conventions agreed with the SOC.
- Future plans include onboarding `Log Analytics Tables`, enrichment playbooks, and custom workbook templates.

---

## 🔐 License

Private – no external distribution.
```
