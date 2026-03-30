---

### PHASE ONE: Create an S3 bucket and SQS queue

---

## Section 1 – Create an S3 Bucket

1. Create an S3 bucket to which you can send the logs from your AWS services – VPC, GuardDuty, CloudTrail, or CloudWatch.

📘 **AWS Docs**: [Create S3 Bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html)

---

### Steps

**Using the S3 Console**

1. Go to: [https://console.aws.amazon.com/s3/](https://console.aws.amazon.com/s3/)

2. Choose a Region for the bucket.
   📌 *Note: After creation, the region cannot be changed.*

3. Choose **General purpose buckets** → **Create bucket**.

**3.1** Bucket Name:
→ *(Enter a globally unique bucket name)*

**3.2** *(Optional)* Copy settings from an existing bucket:
→ *(Optional: name of existing bucket)*

**3.3** Object Ownership:
→ ACLs: Disabled (recommended)
→ Ownership: Bucket owner enforced

**3.4** Block Public Access:
→ Set to block all public access

**3.5** *(Optional)* Versioning:
→ Disabled

**3.6** *(Optional)* Tags:
→ Example:

* `Purpose`: Storage for GuardDuty logs
* `Tenant`: <OrgName>
* `Creator`: <Your Name>

**3.7** Encryption:
→ SSE-S3 (Amazon S3 managed keys)

**3.8** Advanced encryption options:
→ Not applicable if using SSE-S3

**3.9** Object Lock:
→ Disabled

**3.10** Save and create bucket.

---

✅ **End of Section 1: S3 bucket created for GuardDuty log ingestion**

---

## Section 2 – Create an SQS Queue for S3 Notifications

📘 **AWS Docs**: [Create SQS Queue](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/creating-sqs-standard-queues.html)

---

### Steps

**2.1** Go to: [https://console.aws.amazon.com/sqs/](https://console.aws.amazon.com/sqs/)

**2.2** Choose **Create queue**

**2.3** Queue Type:
→ Standard (default)

**2.4** Queue Name:
→ *(Enter a descriptive queue name)*

**2.5** Optional Parameters:

* Visibility timeout: `30`
* Message retention period: `4`
* Delivery delay: `0`
* Maximum message size: `256`
* Receive message wait time: `0`

**2.6** *(Optional)* Access Policy
📘 [SQS Access Policy Guide](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-creating-custom-policies-access-policy-examples.html)

Update with your relevant values:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowGuardDutyToSendMessage",
      "Effect": "Allow",
      "Principal": {
        "Service": "guardduty.amazonaws.com"
      },
      "Action": "SQS:SendMessage",
      "Resource": "<SQS Queue ARN>",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "<AWS Account ID>"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:guardduty:<Region>:<AccountId>:detector/*"
        }
      }
    },
    {
      "Sid": "AllowSentinelOIDCAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "<OIDC Role ARN>"
      },
      "Action": [
        "SQS:ReceiveMessage",
        "SQS:DeleteMessage",
        "SQS:GetQueueAttributes",
        "SQS:GetQueueUrl"
      ],
      "Resource": "<SQS Queue ARN>"
    },
    {
      "Sid": "AllowS3ToSendMessage",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SQS:SendMessage",
      "Resource": "<SQS Queue ARN>",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "<AWS Account ID>"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:s3:::<BucketName>"
        }
      }
    }
  ]
}
```

**2.7** Redrive Policy:
→ Enabled (select "Allow all" or "By queue" as per org policy)

**2.8** *(Optional)* Dead-letter queue:
→ Disabled

**2.9** *(Optional)* Tags:
→ Example:

* `Purpose`: Queue for GuardDuty logs
* `Tenant`: <OrgName>
* `Creator`: <Your Name>

**2.10** Create the queue.

---

✅ **End of Section 2: SQS queue configured for GuardDuty delivery**

---

## Section 3 – Configure S3 to Send Notifications to SQS

📘 [S3 Notification Configuration](https://docs.aws.amazon.com/AmazonS3/latest/userguide/enable-event-notifications.html)

---

### Steps

1. Go to: [https://console.aws.amazon.com/s3/](https://console.aws.amazon.com/s3/)

2. Select your bucket (created in Section 1)

3. Go to: `Properties` → `Event Notifications` → `Create Event Notification`

4. **Name**: *(Give a descriptive name)*

5. **Event Types**:
   → Select: `All object create events` (or `s3:ObjectCreated:*`)

6. **Prefix / Suffix**:
   → Optional; leave empty or specify if needed

7. **Destination**:
   → SQS
   → Enter ARN: `<SQS Queue ARN>`

8. **Save changes**
   → A test notification will be sent to the SQS queue

---

✅ **End of Section 3: Event notifications from S3 to SQS enabled**

---

## PHASE 2: Create an OpenID Connect (OIDC) Web Identity Provider

---

### Section 1 – OIDC Provider for Sentinel

📘 **Microsoft Documentation Note**:

> If you already have an OIDC Connect provider set up for Microsoft Defender for Cloud, **add Microsoft Sentinel as an audience** to the existing provider.
>
> * **Commercial**: `api://<Sentinel-Audience-ID>`
> * **Do not** create a new provider specifically for Sentinel.

---

### Steps

✅ **OIDC role already created**: `<OIDC_Sentinel_RoleName>`

---

### Main Sentinel IAM Policy

**Policy Name**: `<PolicyName>`

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
      "Resource": "arn:aws:sqs:<region>:<account-id>:<CloudTrailQueueName>"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogDelivery",
        "logs:DeleteLogDelivery"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowGuardDutyExportToS3",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::<GuardDutyBucket>",
        "arn:aws:s3:::<GuardDutyBucket>/guardduty-findings/*"
      ]
    }
  ]
}
```

✅ **End of Section 1: OIDC audience for Sentinel set up and IAM policy attached**

---

## PHASE 3: Create AWS Assumed Role for Sentinel (GuardDuty Integration)

---

### Section 1 – Role Creation and Purpose

If Sentinel is already using an OIDC provider, create a **dedicated IAM role** for GuardDuty ingestion with its own permissions.

✅ **Final Configuration**

* **Role Name**: `<OIDC_SentinelGuardDuty_RoleName>`
* **Role ARN**: `arn:aws:iam::<account-id>:role/<OIDC_SentinelGuardDuty_RoleName>`
* **OIDC Trust Policy**: Reuse existing provider (no changes required)

---

### IAM Trust Policy Template

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<account-id>:oidc-provider/<OIDC-provider-URL>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "<OIDC-provider-URL>:aud": "api://<SentinelAudienceID>",
          "sts:RoleSessionName": "MicrosoftSentinel_<workspace-id>"
        }
      }
    }
  ]
}
```

---

### Attached IAM Policy – GuardDuty Integration (`<PolicyName>`)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GuardDutyFullAccess",
      "Effect": "Allow",
      "Action": "guardduty:*",
      "Resource": "*"
    },
    {
      "Sid": "CreateGuardDutyServiceLinkedRole",
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "iam:AWSServiceName": [
            "guardduty.amazonaws.com",
            "malware-protection.guardduty.amazonaws.com"
          ]
        }
      }
    },
    {
      "Sid": "GuardDutyOrganizationsReadOnly",
      "Effect": "Allow",
      "Action": [
        "organizations:ListAWSServiceAccessForOrganization",
        "organizations:DescribeOrganizationalUnit",
        "organizations:DescribeAccount",
        "organizations:DescribeOrganization",
        "organizations:ListAccounts"
      ],
      "Resource": "*"
    },
    {
      "Sid": "GuardDutyOrganizationsAdminAccess",
      "Effect": "Allow",
      "Action": [
        "organizations:EnableAWSServiceAccess",
        "organizations:DisableAWSServiceAccess",
        "organizations:RegisterDelegatedAdministrator",
        "organizations:DeregisterDelegatedAdministrator",
        "organizations:ListDelegatedAdministrators"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "organizations:ServicePrincipal": [
            "guardduty.amazonaws.com",
            "malware-protection.guardduty.amazonaws.com"
          ]
        }
      }
    },
    {
      "Sid": "GuardDutyIamRoleAccess",
      "Effect": "Allow",
      "Action": "iam:GetRole",
      "Resource": "arn:aws:iam::*:role/*AWSServiceRoleForAmazonGuardDutyMalwareProtection"
    },
    {
      "Sid": "PassRoleToMalwareProtectionPlan",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::*:role/*",
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": "malware-protection-plan.guardduty.amazonaws.com"
        }
      }
    },
    {
      "Sid": "AllowGuardDutyExportToS3",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::<GuardDutyBucket>",
        "arn:aws:s3:::<GuardDutyBucket>/guardduty-findings/*"
      ]
    },
    {
      "Sid": "AllowGuardDutyKMSAccess",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "arn:aws:kms:<region>:<account-id>:key/<key-id>"
    },
    {
      "Sid": "AllowSentinelSQSAccess",
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl"
      ],
      "Resource": "arn:aws:sqs:<region>:<account-id>:<GuardDutyQueueName>"
    }
  ]
}
```

---

### ✅ Confirm Role Permissions via Simulation

```bash
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::<account-id>:role/<OIDC_SentinelGuardDuty_RoleName> \
  --action-names sqs:ReceiveMessage \
  --resource-arns arn:aws:sqs:<region>:<account-id>:<GuardDutyQueueName>
```

✅ **Expected Result**: `EvalDecision: allowed`

---

✅ **End of Phase 3: Dedicated role and policy created for GuardDuty ingestion**

---

## ✅ Step 4 – Attaching Policy to KMS Key

---

### 4.1 Create or Use a KMS Key

📘 [AWS KMS Docs – Create Keys](https://docs.aws.amazon.com/kms/latest/developerguide/create-keys.html)

> 🔐 GuardDuty requires KMS key permissions to encrypt findings.
> Microsoft Sentinel also requires KMS permissions to decrypt them for ingestion.

---

### ✅ Key Configuration

| Field            | Value                                        |
| ---------------- | -------------------------------------------- |
| Key Type         | Symmetric                                    |
| Usage            | Encrypt and decrypt                          |
| Advanced Options | KMS (recommended)                            |
| Regionality      | Single-region                                |
| Alias            | `<your-key-alias>` (e.g., `gd-sentinel-key`) |

---

### 4.2 Required IAM Principals

Include permissions for:

* **GuardDuty service principal**: `guardduty.amazonaws.com`
* **Sentinel OIDC role**: `arn:aws:iam::<account-id>:role/<OIDC_SentinelGuardDuty_RoleName>`
* **Optional**: Any SSO or admin roles managing the key

---

### ✅ Example KMS Key Policy (Template)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowRootAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<account-id>:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "AllowAdminRoles",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::<account-id>:role/<AdminRole1>",
          "arn:aws:iam::<account-id>:role/<AdminRole2>"
        ]
      },
      "Action": [
        "kms:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowUseBySentinel",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<account-id>:role/<OIDC_SentinelGuardDuty_RoleName>"
      },
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowGuardDutyEncryptDecrypt",
      "Effect": "Allow",
      "Principal": {
        "Service": "guardduty.amazonaws.com"
      },
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "<account-id>",
          "aws:SourceArn": "arn:aws:guardduty:<region>:<account-id>:detector/<detector-id>"
        }
      }
    },
    {
      "Sid": "AllowGuardDutyServiceRole",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<account-id>:role/aws-service-role/guardduty.amazonaws.com/AWSServiceRoleForAmazonGuardDuty"
      },
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": "*"
    }
  ]
}
```

---

### 4.3 Save and Validate

After attaching the policy:

✅ KMS key is now ready to accept encrypted findings from GuardDuty and decrypt requests from Sentinel.

---

### 4.4 Record the ARN

You will need this ARN when creating the GuardDuty export:

```
arn:aws:kms:<region>:<account-id>:key/<key-id>
```

✅ **End of Step 4 – KMS Key Configured and Ready**

---

## ✅ Step 5 – Update S3 Bucket Policy for GuardDuty & Sentinel

---

📘 [AWS Docs – Export GuardDuty Findings to S3](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_exportfindings.html)

---

### 5.1 Required S3 Actions

| Action                 | Purpose                                 |
| ---------------------- | --------------------------------------- |
| `s3:PutObject`         | Required by GuardDuty to write findings |
| `s3:GetObject`         | Required by Sentinel to read logs       |
| `s3:ListBucket`        | Required by Sentinel to enumerate logs  |
| `s3:GetBucketLocation` | Used by both services during export     |

---

### ✅ Example S3 Bucket Policy (Template)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyInsecureTransport",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::<BucketName>/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "DenyUnencryptedUploads",
      "Effect": "Deny",
      "Principal": {
        "Service": "guardduty.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::<BucketName>/*",
      "Condition": {
        "StringNotEqualsIfExists": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    },
    {
      "Sid": "DenyMissingKMSHeader",
      "Effect": "Deny",
      "Principal": {
        "Service": "guardduty.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::<BucketName>/*",
      "Condition": {
        "StringNotEqualsIfExists": {
          "s3:x-amz-server-side-encryption-aws-kms-key-id": "<KMS-Key-ARN>"
        }
      }
    },
    {
      "Sid": "AllowGuardDutyPutObject",
      "Effect": "Allow",
      "Principal": {
        "Service": "guardduty.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::<BucketName>/*",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "<account-id>",
          "aws:SourceArn": "arn:aws:guardduty:<region>:<account-id>:detector/<detector-id>",
          "s3:x-amz-server-side-encryption": "aws:kms",
          "s3:x-amz-server-side-encryption-aws-kms-key-id": "<KMS-Key-ARN>"
        }
      }
    },
    {
      "Sid": "AllowSentinelReadAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<account-id>:role/<OIDC_SentinelGuardDuty_RoleName>"
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::<BucketName>",
        "arn:aws:s3:::<BucketName>/*"
      ]
    }
  ]
}
```

✅ **End of Step 5 – Bucket policy validated and secured**

---

## ✅ Troubleshooting – GuardDuty Export to S3 & Sentinel Integration

---

### 📌 Problem Summary

**Issue**: GuardDuty is not exporting findings to the configured S3 bucket.
**Symptoms**:

* No logs appear in the destination S3 path.
* `create-publishing-destination` command fails or returns `BadRequestException`.
* CloudTrail logs show failed `CreatePublishingDestination` events.

---

### 🔍 Environment Validation Checklist

Ensure the following are correct:

| Component          | Expected State                                 |
| ------------------ | ---------------------------------------------- |
| AWS Region         | `<region>` (e.g. `ap-southeast-2`)             |
| GuardDuty Detector | Exists and enabled                             |
| KMS Key            | Customer-managed, symmetric, enabled           |
| KMS Key Region     | Matches GuardDuty region                       |
| MultiRegion Key    | `false` (recommended for single-region setups) |

---

### ✅ Commands for Validation

**1. Validate Detector**

```bash
aws guardduty list-detectors --region <region>
```

→ Output should include a valid detector ID:
`<detector-id>`

---

**2. Validate KMS Key**

```bash
aws kms describe-key \
  --key-id arn:aws:kms:<region>:<account-id>:key/<key-id> \
  --region <region>
```

Look for:

* `Enabled: true`
* `KeyUsage: ENCRYPT_DECRYPT`
* `KeyManager: CUSTOMER`
* `MultiRegion: false`

---

### 🚫 Common Error: Parameter Case Sensitivity

Incorrect:

```bash
--destination-properties destinationArn=...,kmsKeyArn=...
```

Correct:

```bash
--destination-properties DestinationArn=...,KmsKeyArn=...
```

---

### ✅ Working Command Template

```bash
aws guardduty create-publishing-destination \
  --detector-id <detector-id> \
  --destination-type S3 \
  --destination-properties DestinationArn=arn:aws:s3:::<bucket-name>,KmsKeyArn=arn:aws:kms:<region>:<account-id>:key/<key-id> \
  --region <region>
```

Expected output:

```json
{
  "DestinationId": "<destination-id>"
}
```

---

### 🔎 Use CloudTrail for Failure Diagnosis

Check if `CreatePublishingDestination` failed:

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=CreatePublishingDestination \
  --max-results 5
```

Look for `errorCode: BadRequestException` and related failure messages indicating:

```
The GuardDuty service principal does not have permission to the KMS key or S3 resource
```

---

### 🛠️ Resolution Steps

1. **Fix parameter casing** in the CLI command (e.g., `DestinationArn` vs `destinationArn`).

2. **Update the KMS key policy**:

   * Include `kms:GenerateDataKey` and `kms:Decrypt` for `guardduty.amazonaws.com`.
   * Include `kms:Decrypt` for the OIDC Sentinel role.

3. **Update the S3 bucket policy**:

   * Allow `s3:PutObject` from GuardDuty with KMS key enforcement.
   * Allow `s3:GetObject` and `s3:ListBucket` for Sentinel role.

---

### ✅ Final Verification

**1. Check Log Delivery in S3**

```bash
aws s3 ls s3://<bucket-name>/AWSLogs/<account-id>/GuardDuty/ --recursive --human-readable --summarize
```

→ You should see `.jsonl.gz` files being delivered regularly.

---

**2. Check Destination Status**

```bash
aws guardduty describe-publishing-destination \
  --detector-id <detector-id> \
  --destination-id <destination-id> \
  --region <region>
```

Expected output:

```json
{
  "DestinationType": "S3",
  "Status": "PUBLISHING",
  "DestinationProperties": {
    "DestinationArn": "arn:aws:s3:::<bucket-name>",
    "KmsKeyArn": "arn:aws:kms:<region>:<account-id>:key/<key-id>"
  }
}
```

---

### 🚀 Next Steps

* Re-run the Sentinel connector registration script if needed:

```powershell
.\Register-GuardDutySentinelConnector.ps1
```

* Monitor ingestion via Log Analytics query in Azure:

```kusto
AWSGuardDuty_CL
| take 10
```

---

✅ **End of Troubleshooting Section – GuardDuty Integration Confirmed Functional**

---
