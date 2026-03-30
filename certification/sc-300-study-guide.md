# SC-300 Lab Execution Order

**Optimized for Exam Logic and Weak Areas**

---

## Phase 0: Ground Rules Before You Start

**Do once, then proceed**

* Create:

  * 2 test users
  * 1 break-glass user
  * 1 test admin
* Ensure sign-in logs are accessible
* Keep notes on what fails vs what silently succeeds

This supports every lab that follows.

---

## Phase 1: Tenant-Level Foundations (Must Come First)

### 1.1 Security Defaults vs Conditional Access Conflict

**Why first:** Nothing else behaves correctly until this is understood.

**Lab:**

* Check Security Defaults
* Attempt to create Conditional Access
* Disable Security Defaults
* Retry policy creation

**Outcome you must internalize:**
Conditional Access cannot exist alongside Security Defaults.

---

### 1.2 Tenant-wide vs Per-user Authentication

**Why now:** Establishes precedence rules early.

**Lab:**

* Enable per-user MFA
* Create Conditional Access MFA policy
* Sign in and inspect logs

**Outcome:**
Conditional Access overrides per-user MFA every time.

---

## Phase 2: Authentication and Conditional Access Enforcement

### 2.1 Conditional Access Evaluation Order

**Why now:** This is the core SC-300 skill.

**Lab:**

* One block policy
* One grant policy
* Same scope
* Observe outcome

**Outcome:**
Block always wins. Order matters.

---

### 2.2 Exclusions and Break-glass Behavior

**Why next:** Exclusions short-circuit everything.

**Lab:**

* Apply MFA to All users
* Attempt break-glass sign-in
* Exclude account
* Retry

**Outcome:**
Exclusions remove scope entirely.

---

### 2.3 Report-only Mode and What If Tool

**Why here:** Builds safe testing intuition.

**Lab:**

* Create Report-only policy
* Run What If simulations
* Compare with sign-in logs

**Outcome:**
Testing uses Report-only and What If, not enforcement.

---

## Phase 3: Administrative Scope and Delegation

### 3.1 Administrative Units Scope Behavior

**Why here:** Now that enforcement logic is clear, scope can be layered in.

**Lab:**

* Create AU
* Assign scoped admin role
* Attempt user management

**Outcome:**
Administrative Units limit admin scope, not sign-in or access.

---

### 3.2 Administrative Units vs Groups

**Why immediately after:** Prevents a common exam confusion.

**Lab:**

* Assign role via group
* Assign role via AU
* Compare visibility and control

**Outcome:**
Groups grant roles. AUs restrict scope.

---

## Phase 4: Defender for Cloud Apps (MCAS)

### 4.1 Cloud Discovery and Shadow IT

**Why now:** Monitoring before enforcement.

**Lab:**

* Review discovered apps
* Inspect risk scores

**Outcome:**
MCAS discovers and informs. It does not block.

---

### 4.2 MCAS Without Conditional Access

**Why next:** Reinforces enforcement boundaries.

**Lab:**

* Disable CA App Control
* Access monitored app
* Review logs

**Outcome:**
MCAS alone cannot block access.

---

### 4.3 Conditional Access App Control Session Enforcement

**Why last in MCAS:** This is the most advanced enforcement.

**Lab:**

* Enable CA App Control
* Apply session restriction
* Test browser behavior

**Outcome:**
Session controls are proxy-based and browser-only.

---

## Phase 5: Case Study and Time Management

### 5.1 Case Study Simulation Drill

**Why last:** Ties everything together under time pressure.

**Lab:**

* One scenario
* 6 questions
* 12 to 15 minute limit

**Outcome:**
Fast context extraction beats rereading.

---

## Final Order Summary (Quick Reference)

1. Security Defaults vs Conditional Access
2. Per-user MFA vs Conditional Access
3. Conditional Access evaluation order
4. Exclusions and break-glass accounts
5. Report-only and What If testing
6. Administrative Units scope behavior
7. Administrative Units vs groups
8. MCAS Cloud Discovery
9. MCAS without Conditional Access
10. MCAS session controls
11. Case study timing drill

