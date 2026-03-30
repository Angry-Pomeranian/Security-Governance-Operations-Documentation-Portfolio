## **Step 4 – Configure Activation, Assignment, and Notification Settings**

In **PIM → Groups → `Server-Admins-JIT-Test` → Settings → Member settings**:

---

### **Activation Settings**

* **Activation maximum duration (hours)**: `1`–`2` hours for testing.
* **Require justification**: **Yes**.
* **Require MFA on activation**: **Yes**.
* **Require approval to activate**: **No** for testing (can enable later).

<img width="373" height="338" alt="image" src="https://github.com/user-attachments/assets/041d1a0f-5900-4312-81a9-218a5d643f71" />

---

### **Assignment Settings**

**Eligible assignments**

* **Allow permanent eligible assignment**: **Yes** *(keeps you eligible without frequent re-assignment)*.
* **Expire eligible assignments after**: `1 Year` (default for test).

**Active assignments**

* **Allow permanent active assignment**: **No** *(prevents indefinite admin rights)*.
* **Expire active assignments after**: `6 Months` *(upper limit — your activation window above controls real session length)*.
* **Require Azure Multi-Factor Authentication on active assignment**: **Yes**.
* **Require justification on active assignment**: **Yes**.

<img width="289" height="256" alt="image" src="https://github.com/user-attachments/assets/b4a11ee4-63ef-4b18-98d2-7fc2e219c5b7" />



---

### **Notification Settings**

#### When members are **assigned as eligible**:

* **Role assignment alert**: Send to PIM admins (default) + add security mailbox if required.
* **Notification to assigned user (assignee)**: Enabled.
* **Request to approve renewal/extension**: Approver (only if approval workflow is enabled).

#### When members are **assigned as active**:

* **Role assignment alert**: Send to PIM admins (default) + optional security mailbox.
* **Notification to assigned user (assignee)**: Enabled.
* **Request to approve renewal/extension**: Approver (only if approval workflow is enabled).

#### When **eligible members activate** this role:

* **Role activation alert**: Send to PIM admins (default) + optional SOC/security mailbox.
* **Notification to activated user (requestor)**: Enabled.
* **Request to approve activation**: Approver (only if approval workflow is enabled).

<img width="625" height="391" alt="image" src="https://github.com/user-attachments/assets/5adcd1a9-9ac6-4ff8-9dfb-80aa9c42dbae" />


---

**Save** to apply changes.
