# Compliance

Security compliance framework references, maturity assessments, and implementation guidance. Covers the ASD Essential Eight (Australian government standard) and NIST Cybersecurity Framework (NIST CSF), with cross-references to technical controls documented elsewhere in this portfolio.

---

## Frameworks

| Framework | Audience | Documents |
|---|---|---|
| [ISO 27001:2022](iso-27001/) | Global enterprise, certification bodies | Annex A control reference (all 93 controls), portfolio mapping |
| [ASD Essential Eight](asd-essential-eight/) | Australian government, enterprise | Maturity model overview, assessment template, implementation guidance |
| [NIST CSF](nist-csf/) | Global enterprise, US federal | Framework mapping to existing portfolio controls |

---

## ISO 27001:2022

The international standard for Information Security Management Systems (ISMS). The 2022 revision contains 93 Annex A controls across four themes: Organisational (A.5), People (A.6), Physical (A.7), and Technological (A.8).

This portfolio aligns to ISO 27001:2022 across incident management (A.5.24–A.5.28), identity and access (A.5.15, A.5.18, A.8.2), detection and monitoring (A.8.15, A.8.16), endpoint hardening (A.8.7–A.8.9), and data leakage prevention (A.8.12).

Full detail → [iso-27001/README.md](iso-27001/README.md)

---

## ASD Essential Eight

The Australian Signals Directorate Essential Eight is the baseline cybersecurity framework recommended for Australian organisations. It defines eight mitigation strategies with four maturity levels (ML0–ML3).

Quick reference — Essential Eight controls:

| # | Control | Maturity target |
|---|---|---|
| 1 | Application Control | ML2+ for most organisations |
| 2 | Patch Applications | ML2+ |
| 3 | Configure Microsoft Office Macro Settings | ML2+ |
| 4 | User Application Hardening | ML2+ |
| 5 | Restrict Administrative Privileges | ML2+ |
| 6 | Patch Operating Systems | ML2+ |
| 7 | Multi-Factor Authentication | ML3 for internet-facing services |
| 8 | Regular Backups | ML2+ |

Full detail → [asd-essential-eight/README.md](asd-essential-eight/README.md)

---

## NIST CSF

The NIST Cybersecurity Framework provides five core functions — Identify, Protect, Detect, Respond, Recover — that map directly to controls and tools documented across this portfolio.

Full detail → [nist-csf/README.md](nist-csf/README.md)

---

## Related

- Identity and MFA controls → `../reference/identity-access/`
- Endpoint hardening (CIS benchmarks) → `../reference/endpoint-hardening/`
- Incident response playbooks → `../incident-response/`
- Sentinel detection and monitoring → `../reference/sentinel/`
