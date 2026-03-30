<img width="924" height="439" alt="TAP Credentials Setup" src="https://github.com/user-attachments/assets/60631cee-b468-46b3-8750-2465c2bb7741" />

### 🔧 Setup Instructions for Proofpoint TAP

1. Log into the **Proofpoint TAP Dashboard**.
2. Navigate to **Settings** → **Connected Applications** tab.
3. Click **Create New Credential**.
4. Provide a descriptive name and click **Generate**.
5. Copy the **Service Principal** and **Secret** values.

---

<img width="568" height="167" alt="image" src="https://github.com/user-attachments/assets/dd8d958e-d36c-45e5-a4b1-faeeaeb66cbd" />


### 🔐 Retrieve Proofpoint PoD Cluster ID and API Token

> **Note:**  
> - The PoD Log API does **not** allow the same token to be used for more than one session at a time.  
> - The WebSocket API requires the **Remote Syslog Forwarding** license.  
> - You will need to provide both the **Cluster ID** and the **API Token** to complete integration.  
> - Refer to Proofpoint documentation for more details on PoD Log API requirements.

#### Steps:

1. **Log in to the Proofpoint Management Console**  
   Use an account with **Admin** privileges.

2. **Retrieve the Cluster ID**  
   - Once logged in, the **Cluster ID** is visible in the **upper-right corner** of the Management Console.

3. **Retrieve or Generate the API Token**  
   - Navigate to: `Settings` → `API Key Management`  
   - Select the **PoD Logging** tab.  
   - Create a **new API key** or use an existing one if available.
