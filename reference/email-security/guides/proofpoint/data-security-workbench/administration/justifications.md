# Justifications

Justifications are **explanatory notes added to alerts or investigations** to document an analyst's reasoning for a decision. When an alert is reviewed and a determination is made — such as dismissing the alert as a false positive or escalating it for further action — a justification records why that decision was made.

Justifications create an audit trail that supports compliance reporting, peer review, and post-incident analysis.

---

# When to Add a Justification

Justifications should be added any time an alert is:

- dismissed as a false positive
- resolved after confirmed investigation
- escalated to a formal incident
- deferred pending additional context
- marked as a known exception or approved activity

Organisations with formal security programs often require justifications on all resolved alerts to satisfy audit and compliance obligations.

---

# Adding a Justification

Steps:

1. Open an alert in the **Alerts dashboard**

2. Review the alert details and any associated evidence

3. Navigate to the **Justification** field in the alert record

4. Select a justification type from the dropdown (if configured)

5. Enter a descriptive note explaining:
   - what activity was observed
   - why the determination was made
   - any follow-up actions taken

6. Save the justification

---

# Justification Best Practices

**Be specific**
Vague justifications like "reviewed and closed" provide little value. Include enough detail for another analyst to understand the decision without re-investigating.

**Reference evidence**
Where possible, cite specific data points — file names, timestamps, user statements, or corroborating Exploration results — to support the justification.

**Use consistent language**
If your organisation has defined justification categories (false positive, approved exception, confirmed incident), use them consistently to enable accurate reporting.

**Review justifications in audits**
Periodically review justifications to identify patterns such as recurring false positives that may indicate a rule needs tuning, or approved exceptions that may need to be formalised in policy.
