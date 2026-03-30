# Engineering Methodology

How the security engineering work in this portfolio is approached — the principles, patterns, and decisions that make it consistent and useful rather than a collection of one-off configurations.

---

## Implementation-First, Theory-Second

Every piece of this portfolio started from a real implementation problem — not a framework checkbox or a theoretical architecture exercise. The ISO 27001 compliance mapping was built by working backwards from deployed controls to the Annex A clauses they satisfy. The Conditional Access policies were designed to solve specific authentication gaps, then documented to a standard where another engineer can deploy them in the same configuration.

This means the documentation captures decisions as they were made — including the ones that are not obvious from reading vendor documentation. Why the DKIM CNAME is preferred over a TXT record. Why the Default Policy in Umbrella should be the most restrictive one. Why block rules for AI prompt detection need to run through two weeks of audit mode first. These things do not appear in vendor docs. They appear in this portfolio because they came from working the problem.

---

## Documentation as a First-Class Deliverable

Security controls that are not documented are controls that will be misconfigured by the next person who touches them. Every policy in this portfolio has:

- A description of what it does and why
- An assignment table (who it applies to, who is excluded)
- The specific settings and their rationale
- A verification method (a PowerShell script, a KQL query, a test procedure)
- Cross-links to related policies and guides that affect the same attack surface

The test is: can someone who did not build this control maintain it correctly in production? If the answer is no, the documentation is not done.

---

## Cross-Platform Awareness

Security controls rarely exist in isolation. A Conditional Access policy that enforces phishing-resistant MFA depends on the Authentication Methods policy that enables FIDO2 registration. Umbrella DNS blocking depends on the firewall rules that prevent users from bypassing Umbrella. The Proofpoint TAP API pipeline depends on the Azure Function deployment and the Sentinel connector configuration.

This is why each guide in the portfolio includes a "Related" section — not as a formality, but because the related items are the controls that will break if this one is misconfigured, and the ones that need to change when this one does.

---

## Operationalise, Then Automate

The sequence used for deploying any new control:

1. **Manual first** — deploy it manually to understand every step and every edge case
2. **Document** — write the runbook while the steps are fresh, including the edge cases that weren't in the vendor docs
3. **Validate** — write a validation script or test procedure that confirms the control is working correctly
4. **Automate** — once the manual process is reliable and documented, automate it for repeatability

Jumping to automation before the manual process is understood produces fragile automation that nobody can debug when it breaks.

---

## Phased Rollout and Audit Mode

New security controls that affect user behaviour — DLP rules, Conditional Access policies, Umbrella category blocks — are never switched from off to full enforcement in a single step. The standard progression:

1. **Report-only / audit mode** — generate data without affecting users; understand what would be blocked
2. **Pilot group** — apply to a small, informed group; gather false positive rate data
3. **Staged expansion** — broaden scope in groups; continue monitoring
4. **Full enforcement** — only after false positive rate is acceptable and users have been informed

This pattern is visible in the Conditional Access phishing-resistant MFA policy (4-phase rollout table), the Umbrella Newly Seen Domains category (log before block recommendation), and the AI governance DLP rules (14-day audit mode before escalating to alert).

---

## Paranoia-Per-Layer, Not Paranoia-Everywhere

Security controls have a cost: friction for users, maintenance burden, false positives. The goal is not to maximise restrictions; it is to apply the right control at the right layer for the actual risk.

- Phishing-resistant MFA is enforced for privileged roles and cloud management (high risk), and is in phased rollout for everyone else (medium risk). It is not applied to read-only service accounts where it would add cost with no benefit.
- AI tool DLP rules block credentials unconditionally (extreme sensitivity, virtually no false positives) but use alert-mode for general PII (meaningful false positive risk — a name in a context window is not a privacy incident).
- Umbrella blocks malware, phishing, and C2 categories unconditionally, but content filtering categories are configured per client based on their acceptable use policy.

The controls in this portfolio are calibrated this way throughout.

---

## Handoff Quality

The audience for this documentation is always "the next engineer who needs to maintain this in production." Not a vendor implementation guide that assumes perfect conditions. Not a theoretical overview for a manager. A working document that tells you what to do when it breaks, what the false positive rate was when it was configured, and which other controls break if you change this one.

That is the standard the documentation in this portfolio is written to.
