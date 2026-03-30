# How to Implement AppLocker using Intune

Youtube:
https://www.youtube.com/watch?v=IWhoAjSNNJo

https://cloudinfra.net/how-to-implement-applocker-using-intune/
^ doc: *Published July 31, 2025 by Jatin Makhija on cloudinfra.net*

---

## Overview

AppLocker, introduced with Windows 7, allows organizations to control which applications can run on managed devices. 

It uses **policies and rules** to allow or deny execution of applications, scripts, DLLs, and packaged apps. 

This control increases security by preventing unauthorized or malicious software from running.

---

## Requirements to Use AppLocker

- Windows 10/11 **Enterprise** or **Education** edition, or supported Windows Server editions.
- **Application Identity** service must be enabled and running.
- Proper **planning and testing** before enforcement.

---

## Supported File Types

| File Type         | Extensions                                      |
|-------------------|-------------------------------------------------|
| Executables       | `.exe`, `.com`                                   |
| Installers        | `.msi`, `.mst`, `.msp`                           |
| Scripts           | `.ps1`, `.bat`, `.cmd`, `.vbs`, `.js`            |
| Dynamic Libraries | `.dll`, `.ocx`                                   |
| Packaged Apps     | `.appx`, `.msix`                                 |

---

## Planning & Best Practices (Microsoft Guidance)

1. **Inventory Applications** – Use built-in tools, ConfigMgr, or Intune reporting to identify currently used apps.
2. **Start in Audit Mode** – Monitor impact without blocking apps (set enforcement mode to *Audit only*).
3. **Define Rule Strategy** – Choose publisher, path, or hash rules based on environment stability.
4. **Use Exceptions Carefully** – Minimize exceptions to avoid policy gaps.
5. **Create Separate Collections** – Manage EXE, DLL, Script, MSI, and Packaged apps independently.
6. **Test on a Pilot Group** – Validate before organization-wide deployment.

---

## Step-by-Step Implementation

### 1. Enable AppLocker

1. Press **Windows + R** → type `secpol.msc` → **Enter**.
2. Navigate to:  
   `Application Control Policies → AppLocker`.
3. Right-click **AppLocker** → **Properties**.
4. Check **Configured** under **Executable Rules**.
5. Set **Action** to **Enforce rules** (or *Audit only* for testing).
6. Click **OK**.

---

### 2. Add AppLocker Default Rules

1. In `secpol.msc`, go to `Application Control Policies → AppLocker → Executable Rules`.
2. Right-click → **Create Default Rules**.

Default rules include:
- Allow all files in **C:\Windows** and **C:\Program Files**.
- Allow all files for members of the **Administrators** group.

---

### 3. Create a Custom Rule (Example: Block Google Chrome)

1. In `Executable Rules`, right-click → **Create New Rule**.
2. Click **Next**.
3. Choose **Deny** → **Next**.
4. Select **Publisher** → **Next**.
5. **Browse** to the app (e.g., `C:\Program Files\Google\Chrome\Application\chrome.exe`).
6. Adjust the slider to **File name** to apply the rule to all versions.
7. Skip **Exceptions** (or add if needed).
8. Give the rule a **Name** and **Description** → **Create**.

---

### 4. Export AppLocker Rules

1. In `secpol.msc`, right-click **AppLocker** → **Export Policy**.
2. Save the XML file (e.g., `AppLockerPolicy.xml`).

---

### 5. Deploy AppLocker via Intune

1. Go to **Intune Admin Center**:  
   `Devices → Windows → Configuration profiles → Create profile`.
2. Select:
   - **Platform**: Windows 10 and later
   - **Profile type**: Templates → **Custom**
3. Enter **Name** and **Description**.
4. Add an **OMA-URI** entry:

   For Executable rules:
```

OMA-URI: ./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/Apps/EXE/Policy
Data type: String
Value: \<Paste XML contents between <RuleCollection> tags>

```

Other collections:
```

MSI:    ./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/Apps/MSI/Policy
Script: ./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/Apps/Script/Policy
Store:  ./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/Apps/StoreApps/Policy
DLL:    ./Vendor/MSFT/AppLocker/ApplicationLaunchRestrictions/Apps/DLL/Policy

````

5. **Assignments**: Choose a device/user group (start with a pilot group).
6. **Review + Create**.

---

### 6. Verify Application Identity Service

On target devices, ensure the service is enabled:
```powershell
Set-Service -Name AppIDSvc -StartupType Automatic
Start-Service -Name AppIDSvc
````

---

## Monitoring & Troubleshooting

### End-User Experience

When a blocked app is launched:

```
This app has been blocked by your system administrator.
```

### Event Logs

1. Open **Event Viewer**.
2. Navigate to:
   `Applications and Services Logs → Microsoft → Windows → AppLocker → EXE and DLL`.
3. Look for:

   * **8003** – Allowed app.
   * **8004** – Blocked app.

---

## FAQs

**1. Delete AppLocker Policy on Local Machine**

* In `secpol.msc`, right-click **AppLocker** → **Clear Policy** → Confirm.

**2. Registry Storage Locations**

```
HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\SrpV2
HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\SrpV2
```

**3. File Storage Location**

```
C:\Windows\System32\AppLocker\MDM
```

---

## References

* [CloudInfra.net – How to Implement AppLocker using Intune](https://cloudinfra.net/how-to-implement-applocker-using-intune/)
* [Microsoft Learn – AppLocker Policies Deployment Guide](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/applocker/applocker-policies-deployment-guide)
* [Microsoft Learn – Requirements for Deploying AppLocker Policies](https://learn.microsoft.com/en-us/windows/security/application-security/application-control/app-control-for-business/applocker/requirements-for-deploying-applocker-policies)

```
