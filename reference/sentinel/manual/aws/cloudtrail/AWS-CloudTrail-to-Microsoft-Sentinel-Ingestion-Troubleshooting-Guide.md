## 📄 AWS CloudTrail to Microsoft Sentinel Ingestion Troubleshooting Guide

---

## Overview

This guide provides a step-by-step approach to troubleshooting AWS CloudTrail ingestion into Microsoft Sentinel using S3 and SQS.

---

## Architecture

```text
CloudTrail → S3 → SQS → Sentinel → Log Analytics
```

---

## Troubleshooting Steps

---

### 1. Verify CloudTrail is Configured

```bash
aws cloudtrail describe-trails --region <region>
```

Check:

* Trail exists
* S3 bucket configured

---

### 2. Confirm Logging is Active

```bash
aws cloudtrail get-trail-status \
  --name <trail-name> \
  --region <region>
```

Expected:

* `"IsLogging": true`

---

### 3. Check S3 for Log Files

```bash
aws s3 ls s3://<bucket>/AWSLogs/<account-id>/CloudTrail/ --recursive | tail
```

Expected:

* Recent `.json.gz` files

---

### 4. Check SQS Queue

```bash
aws sqs get-queue-attributes \
  --queue-url <queue-url> \
  --attribute-names ApproximateNumberOfMessages
```

Expected:

* Messages present

---

### 5. Validate IAM Role

```bash
aws iam get-role --role-name <role-name>
```

Check:

* Trust policy allows OIDC

---

### 6. Check Role Permissions

```bash
aws iam list-role-policies --role-name <role-name>
```

Ensure permissions include:

* `sqs:ReceiveMessage`
* `sqs:DeleteMessage`
* `s3:GetObject`
* `s3:ListBucket`

---

### 7. Confirm Role Usage

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRoleWithWebIdentity
```

---

### 8. Confirm S3 Access

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=GetObject
```

---

## Common Issues

| Issue                        | Cause                         |
| ---------------------------- | ----------------------------- |
| No logs in Sentinel          | Missing S3 permissions        |
| SQS working but no ingestion | Bucket policy blocking access |
| No AssumeRole events         | OIDC misconfiguration         |

---

## Required Permissions

### IAM Role

```json
{
  "Action": [
    "sqs:ReceiveMessage",
    "sqs:DeleteMessage",
    "s3:GetObject",
    "s3:ListBucket"
  ],
  "Effect": "Allow"
}
```

---

### S3 Bucket Policy

```json
{
  "Effect": "Allow",
  "Principal": {
    "AWS": "<role-arn>"
  },
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::<bucket>/*"
}
```

---

## Key Concept

S3 access requires both:

```text
IAM permission + Bucket policy permission
```
