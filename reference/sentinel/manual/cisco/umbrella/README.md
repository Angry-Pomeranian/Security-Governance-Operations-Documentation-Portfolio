# Cisco Umbrella to Microsoft Sentinel – Deployment Guide

<img width="237" height="320" alt="image" src="https://github.com/user-attachments/assets/b1c6ca6a-1dd8-4e1c-a114-7748be151099" />


## **1. Overview**

This document outlines the steps taken to configure Cisco Umbrella DNS logs ingestion into Microsoft Sentinel using an **Azure Function App** and a **self-managed AWS S3 bucket**.

The process uses:

* AWS S3 for log storage
* A dedicated AWS IAM user for log retrieval
* Microsoft’s Cisco Umbrella data connector (Azure Function-based ingestion)
* Sentinel Kusto function parser for normalization

---

## **2. Prerequisites**

### **Permissions**

* **Azure Sentinel Workspace**:

  * Read & Write permissions
  * Read access to workspace shared keys
* **Azure Functions**:

  * `Microsoft.Web/sites` read & write permissions
* **AWS S3**:

  * Access Key ID & Secret Access Key
  * `s3:GetObject` and `s3:ListBucket` permissions for the target bucket
* **Optional**: Azure Key Vault to securely store credentials

---

## **3. Step-by-Step Implementation**

### **Step 1 – Create and Configure AWS S3 Bucket**

1. Log in to the AWS Management Console.
2. Create a new S3 bucket:

   ```
   <UmbrellaBucketName>
   ```
3. Note the bucket ARN:

   ```
   arn:aws:s3:::<UmbrellaBucketName>
   ```
4. Configure Cisco Umbrella to send DNS logs to this S3 bucket.

---

### **Step 2 – Create Dedicated IAM User**

1. In AWS IAM, create a new user:

   ```
   <UmbrellaIngestUser>
   ```
2. Attach a policy granting **read-only** access to the S3 bucket:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListBucket",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::<UmbrellaBucketName>"
        },
        {
            "Sid": "GetObject",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::<UmbrellaBucketName>/*"
        }
    ]
}
```

3. Generate an **Access Key ID** and **Secret Access Key** for this user.
4. Securely store the credentials (preferably in Azure Key Vault).

---

### **Step 3 – Verify Cisco Umbrella Logging**

* Confirm that logs are being delivered to the S3 bucket.
* Typical daily ingestion volume: \~369 MB/day.

---

### **Step 4 – Deploy the Cisco Umbrella Connector in Sentinel**

1. In the Azure Portal, navigate to:
   `Microsoft Sentinel > <WorkspaceName> > Data connectors`
2. Search for **Cisco Umbrella** and open the connector page.
3. Select **Open Connector Page** and choose the **Azure Function App** deployment method.
4. When prompted, provide:

   * **Workspace ID**: `<YourSentinelWorkspaceID>`
   * **Workspace Primary Key**: `<YourSentinelPrimaryKey>`
   * **AWS Access Key ID**: `<AWSAccessKeyID>`
   * **AWS Secret Access Key**: `<AWSSecretAccessKey>`
   * **S3 Bucket Name**: `<UmbrellaBucketName>`
5. Deploy the Function App.

---

### **Step 5 – Configure Data Normalization**

* Create the **Kusto Function** `Cisco_Umbrella` in Sentinel to normalize logs to schema version 11.
* Microsoft’s connector documentation provides the required function definition.

---

## **4. Security Considerations**

* Store AWS credentials securely in **Azure Key Vault**.
* Use a dedicated IAM user with **least privilege**.
* Consider restricting IAM access by **source IP** if possible.
* Monitor ingestion costs in Azure Functions and Sentinel.

---

## **5. Validation**

* Verify that the Azure Function App is successfully retrieving logs.
* Run a KQL query in Sentinel:

```kusto
Cisco_Umbrella
| take 10
```

* Check for expected DNS request entries.

---

## **6. References**

* [Microsoft Sentinel – Cisco Umbrella Data Connector Docs](LinkToMicrosoftDocs)
* [Cisco Umbrella Logging to AWS S3 Guide](LinkToCiscoDocs)
* [Azure Functions Pricing](LinkToAzurePricing)
* [Azure Key Vault Documentation](LinkToAzureKeyVaultDocs)

---

Do you want me to also make a **visual architecture diagram** for this so it’s easier to include in your IT Boost package? That would map Umbrella → S3 → Azure Function → Sentinel.
