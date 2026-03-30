# AWS CloudTrail to Microsoft Sentinel Integration (Manual Setup)

This document describes the full manual setup to forward AWS CloudTrail logs into Microsoft Sentinel using S3, SQS, IAM role delegation, and OpenID Connect (OIDC) trust.

---

## 📋 Summary of Resources

| Component         | Name                                  | Notes                                                |
| ----------------- | ------------------------------------- | ---------------------------------------------------- |
| **S3 Bucket**     | `<CloudTrailBucketName>`               | CloudTrail logs are written here                     |
| **SQS Queue**     | `<CloudTrailSQSQueueName>`             | Triggered by the S3 bucket on `s3:ObjectCreated:Put` |
| **IAM Role**      | `<CompanyName>-Microsoft-Sentinel-OIDC` | Assumed by Microsoft Sentinel via OIDC               |
| **IAM Policy**    | `<CompanyName>-Allow-Microsoft-Sentinel` | Attached to the above IAM role                       |
| **OIDC Provider** | `sts.windows.net/<TenantID>`           | Existing Azure Entra OIDC identity provider          |
| **Workspace ID**  | `<SentinelWorkspaceID>`                | Used as both `aud` and `sub` in role trust policy    |

---

## 🪣 S3 Bucket: `<CloudTrailBucketName>`

- **Region**: `<AWSRegion>`
- **Event Notification Name**: `<S3EventNotificationName>`
- **Event Type**: `s3:ObjectCreated:Put`
- **Destination**: SQS Queue: `<CloudTrailSQSQueueName>`
- **Notes**:
  - Bucket must not use `/AWSLogs/` in subpath when used with VPC Flow Logs (reserved keyword)
  - Ensure event notification only points to **one queue** to avoid ambiguous suffixes error

---

## 📬 SQS Queue: `<CloudTrailSQSQueueName>`

**Access Policy Template**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3ToSendMessage",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SQS:SendMessage",
      "Resource": "arn:aws:sqs:<AWSRegion>:<AWSAccountID>:<CloudTrailSQSQueueName>",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "<AWSAccountID>"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:s3:::<CloudTrailBucketName>"
        }
      }
    },
    {
      "Sid": "AllowSentinelAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<SentinelAWSAccountID>:root"
      },
      "Action": [
        "SQS:ReceiveMessage",
        "SQS:GetQueueAttributes",
        "SQS:GetQueueUrl"
      ],
      "Resource": "arn:aws:sqs:<AWSRegion>:<AWSAccountID>:<CloudTrailSQSQueueName>"
    }
  ]
}
````

---

## 👤 IAM Role: `<CompanyName>-Microsoft-Sentinel-OIDC`

**Trust Policy Template**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<AWSAccountID>:oidc-provider/sts.windows.net/<TenantID>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "sts.windows.net/<TenantID>:sub": "spn:<SentinelWorkspaceID>",
          "sts.windows.net/<TenantID>:aud": "<SentinelWorkspaceID>"
        }
      }
    }
  ]
}
```

---

## 📜 IAM Policy: `<CompanyName>-Allow-Microsoft-Sentinel`

**Permissions Template**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::<CloudTrailBucketName>",
        "arn:aws:s3:::<CloudTrailBucketName>/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:DeleteMessage"
      ],
      "Resource": "arn:aws:sqs:<AWSRegion>:<AWSAccountID>:<CloudTrailSQSQueueName>"
    }
  ]
}
```

---

## 🔐 Identity Provider: Azure OIDC Trust

| Field            | Value                                                                  |
| ---------------- | ---------------------------------------------------------------------- |
| **Provider ARN** | `arn:aws:iam::<AWSAccountID>:oidc-provider/sts.windows.net/<TenantID>` |
| **Provider URL** | `sts.windows.net/<TenantID>`                                           |
| **Audience**     | `<SentinelWorkspaceID>`                                                |
| **Created**      | `<DateCreated>`                                                        |

This provider enables Microsoft Sentinel to use OpenID Connect to assume the delegated IAM role (`<CompanyName>-Microsoft-Sentinel-OIDC`) via `sts:AssumeRoleWithWebIdentity`.

⚠️ **Note:** If the audience or trust policy is misconfigured, validation will fail. Ensure both `aud` and `sub` match the **workspace ID**.

---

## 🌐 CloudTrail Setup

| Setting                | Value                                   |
| ---------------------- | --------------------------------------- |
| **Target Bucket**      | `<CloudTrailBucketName>`                |
| **Delivery Format**    | Default (JSON via S3)                   |
| **Region**             | `<AWSRegion>`                           |
| **Destination Prefix** | `AWSLogs/<AWSAccountID>/CloudTrail/...` |

---

## 🛠 Validation Checklist

### Microsoft Sentinel Workspace

* ✔️ Workspace ID matches the **external ID** in AWS trust policy
* ✔️ Azure CLI access confirmed with correct role (`Microsoft Sentinel Contributor` at subscription + workspace scope)

### Identity Provider (OIDC)

* ✔️ Audience matches **Sentinel Workspace ID**
* ✔️ Registered in AWS IAM
* ✔️ Used in IAM Role trust policy

### IAM Role

* ✔️ Trust policy configured with `aud` and `sub` matching Workspace ID
* ✔️ Policy attached with required S3 & SQS permissions

### S3 Bucket

* ✔️ CloudTrail delivering logs
* ✔️ Event notification configured to SQS

### SQS Queue

* ✔️ Access policy allows S3 to publish and Sentinel to poll
* ✔️ Region/account match confirmed
