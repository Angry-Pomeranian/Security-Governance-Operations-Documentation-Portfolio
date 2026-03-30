# Proofpoint CASB to PostgreSQL to Grafana Pipeline

## Overview

This document captures an end to end implementation for:

* Authenticating to the Proofpoint CASB API using OAuth2 client credentials
* Validating API reachability and token handling
* Persisting normalized CASB alerts into PostgreSQL
* Exposing data to Grafana with least privilege access
* Verifying ingestion and visibility

---

## 1. Environment Setup

### Export OAuth Credentials

```bash
export PROOFPOINT_CLIENT_ID="REPLACE_WITH_CLIENT_ID"
export PROOFPOINT_CLIENT_SECRET="REPLACE_WITH_CLIENT_SECRET"

echo "ID set: ${#PROOFPOINT_CLIENT_ID}"
echo "SECRET set: ${#PROOFPOINT_CLIENT_SECRET}"
```

Expected output:

```text
ID set: 36
SECRET set: 42
```

---

## 2. OAuth Token Validation

### Test Token Request (run as is)

```bash
curl -sS -X POST \
  "https://app.us-east-1-op1.op.analyze.proofpoint.com/v2/apis/auth/oauth/token" \
  -H "accept: application/json" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "client_id=${PROOFPOINT_CLIENT_ID}" \
  --data-urlencode "client_secret=${PROOFPOINT_CLIENT_SECRET}" \
  --data-urlencode "grant_type=client_credentials" \
  --data-urlencode "scope=*"
```

Expected response characteristics:

* HTTP status 200
* `access_token` present
* `expires_in` approximately 86400 seconds

---

## 3. Workbench Health Check

### Baseline Health Check (No Token)

```bash
curl -X GET \
  "https://app.us-east-1-op1.op.analyze.proofpoint.com/v2/apis/workbench/_health" \
  -H "accept: application/json"
```

Expected result:

* Status 200
* Confirms service reachability

---

## 4. Secure Token Storage

### Create Secure Directory

```bash
mkdir -p /home/USERNAME/.proofpoint
chmod 700 /home/USERNAME/.proofpoint
umask 077
```

### Persist Token to Disk

```bash
curl -sS -X POST \
  "https://app.us-east-1-op1.op.analyze.proofpoint.com/v2/apis/auth/oauth/token" \
  -H "accept: application/json" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "client_id=${PROOFPOINT_CLIENT_ID}" \
  --data-urlencode "client_secret=${PROOFPOINT_CLIENT_SECRET}" \
  --data-urlencode "grant_type=client_credentials" \
  --data-urlencode "scope=*" \
  > /home/USERNAME/.proofpoint/token.json
```

### Safe Validation (No Token Output)

```bash
python3 - <<'PY'
import json
p="/home/USERNAME/.proofpoint/token.json"
d=json.load(open(p,"r",encoding="utf-8"))
print("access_token:", "present" if d.get("access_token") else "missing")
print("refresh_token:", "present" if d.get("refresh_token") else "missing")
print("expires_in:", d.get("expires_in"))
print("status:", d.get("_status", {}).get("status"))
print("code:", d.get("_status", {}).get("code"))
PY
```

Expected output:

```text
access_token: present
refresh_token: present
expires_in: 86399
status: 200
code: it:error:none
```

Token location:

```text
/home/USERNAME/.proofpoint/token.json
```

---

## 5. Workbench Health Check With Token

### Load Token into Environment

```bash
export ACCESS_TOKEN="$(python3 -c 'import json; print(json.load(open("/home/USERNAME/.proofpoint/token.json"))["access_token"])')"
```

### Call Health Endpoint

```bash
curl -sS -X GET \
  "https://app.us-east-1-op1.op.analyze.proofpoint.com/v2/apis/workbench/_health" \
  -H "accept: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}"
```

Expected result:

* Status 200

Cleanup:

```bash
unset ACCESS_TOKEN
```

---

## 6. PostgreSQL Setup

### Confirm Client Version

```bash
psql --version
```

Example output:

```text
psql (PostgreSQL) 13.22
```

---

### Connect to PostgreSQL (RDS)

```bash
psql -h DB_HOST.example.internal -p 5432 -U db_admin postgres
```

List databases:

```sql
\l
```

---

### Connect to Existing Database

```sql
\c example_security_db
```

Note:

* Database reuse chosen due to permission constraints
* Migration to dedicated database planned later

---

## 7. Schema and Table Creation

```sql
create schema if not exists proofpoint;

create table if not exists proofpoint.casb_alerts (
  alert_id text primary key,
  fqid text not null,
  occurred_at_utc timestamptz,
  created_at_utc timestamptz,
  rule_name text,
  severity text,
  incident_status text,
  user_email text,
  user_display_name text,
  app_suite text,
  app_name text,
  client_app text,
  resource_name text,
  resource_url text,
  resource_location text,
  resource_path text,
  share_level text,
  share_permission text,
  dlp_detector text,
  dlp_count integer,
  remediation_kind text,
  remediation_status text,
  remediation_executed_at timestamptz,
  remediation_message text,
  confidence numeric(4,2),
  send_email boolean,
  normalized jsonb not null,
  ingested_at timestamptz not null default now()
);
```

### Indexes

```sql
create index if not exists casb_alerts_occurred_at_idx
  on proofpoint.casb_alerts (occurred_at_utc desc);

create index if not exists casb_alerts_severity_idx
  on proofpoint.casb_alerts (severity);

create index if not exists casb_alerts_rule_name_idx
  on proofpoint.casb_alerts (rule_name);

create index if not exists casb_alerts_user_email_idx
  on proofpoint.casb_alerts (user_email);
```

### Verify Table

```sql
\dt proofpoint.*
```

---

## 8. Grafana Permissions

```sql
grant usage on schema proofpoint to grafana_readonly;
grant select on proofpoint.casb_alerts to grafana_readonly;
alter default privileges in schema proofpoint grant select on tables to grafana_readonly;
```

---

## 9. Insert First Record

### Set Environment Variables

```bash
export PGHOST="DB_HOST.example.internal"
export PGPORT="5432"
export PGDATABASE="example_security_db"
export PGUSER="db_admin"
export PGPASSWORD="REPLACE_WITH_PASSWORD"
```

### Verify psycopg2

```bash
python3 -c "import psycopg2; print('psycopg2 ok')"
```

---

### Insert Script

```python
import json
import os
import psycopg2
from psycopg2.extras import Json

path = "/home/USERNAME/.proofpoint/normalized_record.json"
rec = json.load(open(path, "r", encoding="utf-8"))

conn = psycopg2.connect(
    host=os.environ["PGHOST"],
    port=int(os.environ.get("PGPORT", "5432")),
    dbname=os.environ["PGDATABASE"],
    user=os.environ["PGUSER"],
    password=os.environ["PGPASSWORD"],
)
conn.autocommit = True

sql = """
insert into proofpoint.casb_alerts (
  alert_id, fqid, occurred_at_utc, created_at_utc,
  rule_name, severity, incident_status,
  user_email, user_display_name,
  app_suite, app_name, client_app,
  resource_name, resource_url, resource_location, resource_path,
  share_level, share_permission,
  dlp_detector, dlp_count,
  remediation_kind, remediation_status, remediation_executed_at, remediation_message,
  confidence, send_email,
  normalized
) values (
  %(alert_id)s, %(fqid)s, %(occurred_at_utc)s, %(created_at_utc)s,
  %(rule_name)s, %(severity)s, %(incident_status)s,
  %(user_email)s, %(user_display_name)s,
  %(app_suite)s, %(app_name)s, %(client_app)s,
  %(resource_name)s, %(resource_url)s, %(resource_location)s, %(resource_path)s,
  %(share_level)s, %(share_permission)s,
  %(dlp_detector)s, %(dlp_count)s,
  %(remediation_kind)s, %(remediation_status)s, %(remediation_executed_at)s, %(remediation_message)s,
  %(confidence)s, %(send_email)s,
  %(normalized)s
)
on conflict (alert_id) do update set
  normalized = excluded.normalized,
  ingested_at = now();
"""

params = dict(rec)
rem = rec.get("automated_remediation") or {}
params["remediation_kind"] = rem.get("kind")
params["remediation_status"] = rem.get("status")
params["remediation_executed_at"] = rem.get("executed_at")
params["remediation_message"] = rem.get("message")
params["normalized"] = Json(rec)

with conn.cursor() as cur:
    cur.execute(sql, params)

print("Insert successful")
conn.close()
```

---

## 10. Final Outcome

### What Has Been Built

#### Ingestion

* Proofpoint CASB alerts retrieved via API
* OAuth handled securely
* Alerts keyed by FQID

#### Decision Logic

* Severity evaluated
* Confidence calculated deterministically
* Email decisions derived, not hardcoded

#### Persistence

* Stored in PostgreSQL
* Deduplicated by `alert_id`
* JSON preserved for future reprocessing

#### Visibility

* Grafana dashboard created
* Read only access enforced
* Sorting, filtering, and time selection validated

### Architectural Result

* Primary system of record: Grafana
* Secondary notification channel: Email only when justified

This forms a complete, auditable SecOps data pipeline.

---

