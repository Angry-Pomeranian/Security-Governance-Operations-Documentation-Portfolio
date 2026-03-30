# Policy Overview

**Policy name**
MAM - APP Protection Policy

**Description**
This policy requires that mobile devices that access company data are protected with defined application-level security controls, including encryption, data loss prevention, and access restrictions.

**Platform**
Android

---

## App Targeting

**Target to apps on all device types**
Yes

**Public apps**
All Microsoft Apps

**Custom apps**

* com.microsoft.copilot
* com.microsoft.ramobile
* com.microsoft.rdc.android
* com.microsoft.stream

---

## Data Protection Settings

### Data Handling

**Prevent backups**
Block

**Save copies of org data**
Block

**Allowed save locations**

* OneDrive for Business
* SharePoint

---

### Data Transfer Controls

**Send org data to other apps**
Policy managed apps

**Exempt apps**

* Android dialer and telephony service

  * com.android.phone
* Android settings content provider

  * com.android.providers.settings
* Android Settings UI

  * com.android.settings
* Google Play Store

  * com.android.vending
* Microsoft Teams mobile application

  * com.microsoft.teams
* SMS messaging applications

  * com.google.android.apps.messaging
  * com.android.mms
  * com.samsung.android.messaging

**Receive data from other apps**
All apps

**Restrict cut, copy, and paste between other apps**
Policy managed apps with paste in

**Cut and copy character limit**
30 characters

---

### Telephony and Messaging

**Transfer telecommunication data to**
Any dialer app

**Transfer messaging data to**
Any messaging app

---

### Open In and Content Controls

**Open data into org documents**
Allow

**Allowed sources**

* OneDrive for Business
* SharePoint
* Camera
* Photo Library

**Restrict web content transfer with other apps**
Microsoft Edge

---

### Device Interaction Controls

**Screen capture and Google Assistant**
Disable

**Printing org data**
Block

**Org data notifications**
Allow

---

### Keyboard Configuration

**Approved keyboards required**
Not required

**Known keyboards (not enforced)**

* Gboard

  * com.google.android.inputmethod.latin
* SwiftKey

  * com.touchtype.swiftkey
* Samsung Keyboard

  * com.sec.android.inputmethod
  * com.samsung.android.honeyboard
* Google Indic Keyboard

  * com.google.android.apps.inputmethod.hindi
* Google Pinyin Input

  * com.google.android.inputmethod.pinyin
* Google Japanese Input

  * com.google.android.inputmethod.japanese
* Google Korean Input

  * com.google.android.inputmethod.korean
* Google Handwriting Input

  * com.google.android.apps.handwriting.ime
* Google voice typing

  * com.google.android.googlequicksearchbox
* Samsung voice input

  * com.samsung.android.svoiceime

---

### Encryption

**Encrypt org data**
Require

**Encrypt org data on enrolled devices**
Require

**Sync policy managed app data with native apps or add-ins**
Allow

---

## Access Requirements

**PIN required**
Yes

**PIN type**
Numeric

**Simple PIN allowed**
Yes

**Minimum PIN length**
4

**Biometrics allowed**
Yes

**App PIN required when device PIN is set**
Require

**Recheck access requirements after inactivity**
30 minutes

---

## Conditional Launch Settings

| Condition                   | Value       | Action       |
| --------------------------- | ----------- | ------------ |
| Max PIN attempts            | 5           | Reset PIN    |
| Offline grace period        | 720 minutes | Block access |
| Offline grace period        | 90 minutes  | Wipe data    |
| Jailbroken or rooted device | Detected    | Block access |

---

## Assignments

**Included groups**

* Intune - Microsoft Protection Policy

  * Status: Active

**Excluded groups**
None

---

## Scope Tags

**Scope tag**
Default

---

## Validation and Notes

* This policy is final and locked for change.
* App Protection Policy enforces data boundaries independently of device enrollment.
* SMS copy and paste is intentionally allowed with a strict 30-character limit to support on-call operational use cases.
* Web content is restricted to Microsoft Edge to maintain protected browsing flows.
* Desktop Edge CIS hardening policies are not required for mobile devices.

---
