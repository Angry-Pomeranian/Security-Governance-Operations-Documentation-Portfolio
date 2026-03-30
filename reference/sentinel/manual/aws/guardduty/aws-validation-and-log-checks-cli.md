### AWS – Validation and Log Checks CLI:

1. **Validate GuardDuty Detector**
   Returns the Detector ID required for most GuardDuty operations.

   ```bash
   aws guardduty list-detectors --region <region>
   ```

2. **Validate KMS**
   Confirms the KMS key is enabled, customer-managed, symmetric, and region-matched.

   ```bash
   aws kms describe-key \
     --key-id arn:aws:kms:<region>:<account-id>:key/<kms-key-id> \
     --region <region>
   ```

3. **Validate GuardDuty S3 Export Setup**
   Checks the S3 destination configured for findings export.

   ```bash
   aws guardduty describe-publishing-destination \
     --detector-id <guardduty-detector-id> \
     --destination-id <guardduty-destination-id> \
     --region <region>
   ```

4. **Check S3 Logs Delivered by GuardDuty**
   Confirms that GuardDuty logs are landing in the expected bucket/prefix.

   ```bash
   aws s3 ls s3://<s3-bucket-name>/AWSLogs/<account-id>/GuardDuty/ --recursive --human-readable --summarize
   ```

   To confirm the most recent log files:

   ```bash
   aws s3 ls s3://<s3-bucket-name>/AWSLogs/<account-id>/GuardDuty/ --recursive | sort | tail -n 5
   ```

5. **CloudTrail Audit – GuardDuty Destination Events**
   Confirms GuardDuty successfully called `CreatePublishingDestination`.

   ```bash
   aws cloudtrail lookup-events \
     --lookup-attributes AttributeKey=EventName,AttributeValue=CreatePublishingDestination \
     --max-results 5
   ```

   To check for failures:

   ```bash
   aws cloudtrail lookup-events \
     --lookup-attributes AttributeKey=EventSource,AttributeValue=guardduty.amazonaws.com \
     --max-results 10 | jq -r '.Events[] | select(.CloudTrailEvent | contains("BadRequestException")) | .EventTime, .CloudTrailEvent'
   ```

6. **CloudTrail Audit – KMS Decrypt Usage**
   Shows if KMS decryption activity is occurring, confirming the key is being used during ingestion.

   ```bash
   aws cloudtrail lookup-events \
     --lookup-attributes AttributeKey=EventName,AttributeValue=Decrypt \
     --max-results 5
   ```

---

-----------------------

### Azure – Validation and Log Checks

1. **Register GuardDuty Connector (Azure Side)**: Registers the AWS-S3-GuardDuty connector in Sentinel using your existing role and destination config.

```powershell
.\Register-GuardDutySentinelConnector.ps1

# Register-GuardDutySentinelConnector.ps1

$workspaceResourceId = "<Azure Sentinel Workspace Resource ID>"
$connectorName = "<Connector Name>"  # e.g., AWS-S3-GuardDuty
$roleArn = "<ARN of IAM Role for Sentinel Access>"
$destinationTable = "<Destination Table Name>"  # e.g., AWSGuardDuty
$kind = "<Connector Kind>"  # e.g., AmazonWebServicesS3
$sqsUrl = "<SQS Queue URL>"

$properties = @{
    roleArn = $roleArn
    destinationTable = $destinationTable
    sqsUrls = @($sqsUrl)
    dataTypes = @{
        logs = @{
            state = "Enabled"
        }
    }
    connectorDefinitionName = ""
    dcrConfig = $null
}

New-AzResource -ResourceId "$workspaceResourceId/providers/Microsoft.SecurityInsights/dataConnectors/$connectorName" `
    -Properties $properties `
    -Force `
    -ApiVersion "2022-12-01-preview" `
    -Kind $kind
```

#### Expected Script Output:

```
Name                  : <Connector Name>
ResourceId            : <Full Azure Resource ID>
ResourceName          : <Log Analytics Workspace Name>
ResourceType          : Microsoft.OperationalInsights/workspaces
ExtensionResourceName : <Connector Name>
ExtensionResourceType : Microsoft.SecurityInsights/dataConnectors
Kind                  : <Connector Kind>
ResourceGroupName     : <Resource Group Name>
SubscriptionId        : <Subscription ID>
Properties            : @{roleArn=<Role ARN>; destinationTable=<Table>; sqsUrls=...; dataTypes=...; ...}
ETag                  : <ETag>
```

#### Check Sentinel Connector Status (Manually)

```
'Microsoft.SecurityInsights/dataConnectors
kind: <Connector Kind>
destinationTable: <Destination Table>
roleArn: <Role ARN>'
Queue URL: <SQS Queue URL>
```

### Azure Log Analytics Query (if data were ingesting)

```kusto
AWSGuardDuty_CL
| take 10
```

```kusto
AzureDiagnostics
| where ResourceType == "DATA_CONNECTOR"
| where Resource == "<Connector Name>"
```

---

### Variables:

#### GuardDuty:

* **Detector ID**: `<GuardDuty Detector ID>`
* **S3 Bucket**: `<S3 Bucket Name>`
* **S3 Bucket ARN**: `arn:aws:s3:::<Bucket Name>`
* **KMS key ARN**: `arn:aws:kms:<region>:<account-id>:key/<Key ID>`

#### KMS KEY:

* **ARN**: `arn:aws:kms:<region>:<account-id>:key/<Key ID>`
* **Key ID**: `<Key ID>`
* **Alias**: `<KMS Key Alias>`

#### KEY POLICY:

```json
{
  "Version": "2012-10-17",
  "Id": "guardduty-kms-policy",
  "Statement": [
    {
      "Sid": "EnableRootAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<account-id>:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "AllowGuardDutyServicePrincipal",
      "Effect": "Allow",
      "Principal": {
        "Service": "guardduty.amazonaws.com"
      },
      "Action": ["kms:GenerateDataKey", "kms:Decrypt"],
      "Resource": "<Key ARN>",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "<Account ID>",
          "aws:SourceArn": "<GuardDuty Detector ARN>"
        }
      }
    },
    ...
    {
      "Sid": "AllowSentinelOIDCDecryptAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "<Sentinel Role ARN>"
      },
      "Action": "kms:Decrypt",
      "Resource": "*"
    }
  ]
}
```

---

### S3 Bucket

* **Name**: `<Bucket Name>`
* **ARN**: `arn:aws:s3:::<Bucket Name>`
* **Event Notification Name**: `<SQS Notification Name>`
* **Destination SQS Queue**: `<Queue Name>`

#### Bucket Policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyNonHTTPSAccess",
      "Effect": "Deny",
      "Principal": { "Service": "guardduty.amazonaws.com" },
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::<Bucket Name>/*",
      "Condition": {
        "Bool": { "aws:SecureTransport": "false" }
      }
    },
    {
      "Sid": "DenyIncorrectEncryptionHeader",
      ...
    },
    {
      "Sid": "AllowSentinelOIDCReadAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "<Sentinel Role ARN>"
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::<Bucket Name>",
        "arn:aws:s3:::<Bucket Name>/*"
      ]
    }
  ]
}
```

---

### IAM Role

* **Name**: `<Role Name>`
* **ARN**: `arn:aws:iam::<account-id>:role/<Role Name>`

#### Trust Policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<account-id>:oidc-provider/<OIDC Provider URL>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "<OIDC Provider URL>:aud": "<Audience ID>",
          "sts:RoleSessionName": "MicrosoftSentinel_<Workspace GUID>"
        }
      }
    }
  ]
}
```

#### Permissions Policies:

* **AmazonGuardDutyFullAccess\_v2**
* **OIDC\_SentinelGuardDuty\_Policy**

(Insert full structure here with placeholders where appropriate—already done above.)

---

### SQS Queue

* **Name**: `<Queue Name>`
* **URL**: `<Queue URL>`
* **ARN**: `arn:aws:sqs:<region>:<account-id>:<Queue Name>`

#### Access Policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowGuardDutyToSendMessage",
      "Effect": "Allow",
      "Principal": { "Service": "guardduty.amazonaws.com" },
      "Action": "SQS:SendMessage",
      "Resource": "<Queue ARN>",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "<Account ID>"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:guardduty:<region>:<account-id>:detector/*"
        }
      }
    },
    {
      "Sid": "AllowSentinelOIDCAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "<Sentinel Role ARN>"
      },
      "Action": [
        "SQS:ReceiveMessage",
        "SQS:DeleteMessage",
        "SQS:GetQueueAttributes",
        "SQS:GetQueueUrl"
      ],
      "Resource": "<Queue ARN>"
    },
    {
      "Sid": "AllowS3ToSendMessage",
      "Effect": "Allow",
      "Principal": { "Service": "s3.amazonaws.com" },
      "Action": "SQS:SendMessage",
      "Resource": "<Queue ARN>",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "<Account ID>"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:s3:::<Bucket Name>"
        }
      }
    }
  ]
}
```

---
