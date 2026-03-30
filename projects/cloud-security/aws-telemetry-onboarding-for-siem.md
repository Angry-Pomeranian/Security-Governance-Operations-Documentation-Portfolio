# AWS Telemetry Onboarding for SIEM

## Overview
Implemented AWS-to-Sentinel telemetry ingestion workflows to centralize multi-cloud security signals into a single monitoring platform.

## Security Problem
Cloud incidents can go undetected when AWS audit and network telemetry is fragmented across services and not integrated into centralized detection operations.

## Implementation Approach
Used scripted connector configuration patterns to onboard key AWS security log sources and establish transport components for reliable ingestion into Sentinel.

## Security Controls Implemented
- CloudTrail ingestion for API and account activity monitoring.
- GuardDuty integration for managed threat findings.
- VPC flow and CloudWatch log onboarding for network and service visibility.
- S3/SQS-based pipeline configuration for log collection and delivery.

## Outcome
Expanded cloud detection coverage, improved correlation of AWS activity with broader enterprise telemetry, and enabled faster cloud-focused incident triage.
