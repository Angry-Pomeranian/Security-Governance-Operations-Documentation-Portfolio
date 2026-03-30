# Security Incident Response Pipelines

End-to-end, production-grade incident response pipelines. Each pipeline document covers the full lifecycle for a specific attack scenario: detection engineering (KQL), SIEM analytics rules, investigation workflow, endpoint telemetry, automated response, and validation.

Unlike playbooks — which describe what to do — pipeline documents show the exact technical implementation: working queries, deployable automation, and actionable runbooks.

---

## Pipelines

| Pipeline | Scenario | Severity | Tools |
|---|---|---|---|
| [Impossible Travel + Suspicious Login](impossible-travel-incident-response-pipeline.md) | Compromised identity via impossible travel, correlated with endpoint activity | High | Sentinel · Entra ID · CrowdStrike · Intune |

---

## Document Structure

Each pipeline document follows this structure:

1. **Detection Engineering** — KQL queries with time window, IP enrichment, and user risk scoring logic
2. **Sentinel Analytics Rule** — Full JSON rule config with entity mapping and alert grouping
3. **Investigation Workflow** — Step-by-step procedure from alert triage to cross-tool pivot
4. **CrowdStrike Query / Workflow** — Falcon Event Search queries and host timeline steps
5. **Response Actions** — Conditional Access enforcement, session revocation, account containment
6. **Automation** — Logic App workflow: Teams alert, user disable, ticket creation
7. **Validation** — Safe simulation steps, expected log output, alert behaviour verification
8. **Troubleshooting** — Missing logs, device correlation gaps, data source issues
9. **Executive Summary** — Business impact for non-technical stakeholders

---

## Related

- Incident response playbooks → `../incident-response/`
- Sentinel detection rules and KQL → `../reference/sentinel/`
- Identity and Conditional Access policies → `../reference/identity-access/`
- CrowdStrike automation modules → `../reference/automation/crowdstrike/`
