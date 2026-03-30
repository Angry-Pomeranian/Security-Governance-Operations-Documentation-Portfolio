<p align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0EA5E9,100:2563EB&height=120&section=header&text=Smart%20Search%20Guidance&fontSize=32&fontColor=ffffff&animation=fadeIn"/>
</p>

Smart Search is an advanced Exploration feature in **Proofpoint Data Security Workbench** that helps analysts create searches using natural language instead of manually building every filter node from scratch.

It is designed to make complex investigations faster by using:

- artificial intelligence
- natural language processing
- machine learning

Rather than requiring an analyst to know the exact field names used in Proofpoint, Smart Search allows the analyst to describe what they want to find in plain language. 

Proofpoint then attempts to convert that request into the appropriate query structure for an Exploration.

This feature is especially useful for situations such as:

- junior analysts still learning the platform
- complex investigations involving multiple conditions
- quickly building a first-pass query
- reducing the time needed to locate the correct fields manually

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

### Contents


| Topic  | Description |
|---|---|
| 🔎 [What Smart Search Does](#what-smart-search-does) | Overview of the Smart Search capability |
| ⚙️ [When to Use Smart Search](#when-to-use-smart-search) | Best investigation scenarios |
| ⚠️ [When Not to Rely on Smart Search Alone](#when-not-to-rely-on-smart-search-alone) | Situations requiring manual validation |
| 🧠 [Analyst Guidance](#analyst-guidance) | Recommended analyst workflow |
| 📂 [Accessing Smart Search](#accessing-smart-search) | Where to find Smart Search |
| 🧩 [How Smart Search Works](#how-smart-search-works) | How query interpretation works |
| ✍️ [Writing Better Queries](#writing-better-queries) | Tips for better Smart Search results |
| 📊 [Example Smart Search Queries](#example-smart-search-queries) | Investigation query examples |
| ⚠️ [Common Pitfalls](#common-pitfalls) | Mistakes analysts should avoid |
| 🕵️ [Investigation Walkthrough](#example-investigation-walkthrough) | Real investigation scenario |
| 🔧 [Relationship to Manual Explorations](#relationship-to-manual-explorations) | Combining Smart Search with manual filters |
| 💾 [When to Save Explorations](#when-to-save-a-smart-search-exploration) | When to reuse queries |
| 📚 [Related Documentation](#related-documentation) | Additional documentation |


<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=What%20Smart%20Search%20Does%20&fontSize=26&fontColor=ffffff"/>
</p>


Smart Search helps translate a free-form written query into a structured Exploration filter.

For example, instead of manually finding and selecting multiple fields, an analyst might type something like:


`Show DLP activity for admin users in the last 30 days`


Smart Search will then attempt to generate the Exploration logic needed to produce those results.

This allows analysts to focus more on the **investigation objective** and less on remembering the exact menu paths or field names.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=When%20to%20Use%20Smart%20Search%20&fontSize=26&fontColor=ffffff"/>
</p>

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>


Smart Search is designed to help analysts **quickly build Explorations using natural language** instead of manually configuring multiple filters.

It is most effective when you know **what you want to investigate**, but are unsure which fields or filters should be used in the platform.

## Ideal Use Cases

| Scenario | Why Smart Search Helps |
|---|---|
| Investigating activity but unsure which Proofpoint fields map to the event | Smart Search converts investigation intent into exploration filters |
| Investigations involving multiple concepts | AI can combine user, activity, and timeframe logic quickly |
| Quickly building an initial Exploration | Allows analysts to generate a query in seconds |
| Learning the Proofpoint platform | Helps junior analysts understand how queries map to activity fields |
| Testing a search idea before refining it manually | Generates a starting point that can later be edited |

### Example Investigation Scenarios

Smart Search works well for queries such as:

| Investigation Type | Example |
|---|---|
| DLP activity investigation | Finding DLP signals for a specific user or group |
| Website activity monitoring | Identifying browsing activity for risky categories |
| Risk-based investigations | Reviewing activity performed by high-risk users |
| Data exposure investigations | Locating files shared externally |
| Behavioral anomalies | Searching for abnormal data movement |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=When%20Not%20to%20Rely%20on%20Smart%20Search%20Alone&fontSize=26&fontColor=ffffff"/>
</p>

Smart Search is a **query accelerator**, not a replacement for analyst review.

For critical investigations, analysts should always validate the generated exploration before relying on the results.

## Situations Where Manual Review Is Required

| Situation | Why Manual Validation Is Important |
|---|---|
| High-impact security investigations | Queries must be precise and validated |
| Results appear incomplete or overly broad | Generated filters may not match the intended investigation |
| Investigations requiring exact field control | Manual filters provide greater accuracy |
| Formal incident investigations | Results must be defensible and reproducible |
| Compliance or legal investigations | Query logic must be explicitly verified |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Analyst%20Guidance&fontSize=26&fontColor=ffffff"/>
</p>


Treat Smart Search as the **first step in an investigation workflow**, not the final answer.

Recommended workflow:

```
Smart Search Query
      ↓
Review Generated Filters
      ↓
Refine Exploration Manually
      ↓
Investigate Results
```

Smart Search should always be considered a starting point for building an Exploration rather than a fully validated investigation query.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=When%20Not%20to%20Rely%20on%20Smart%20Search%20Alone&fontSize=26&fontColor=ffffff"/>
</p>


Smart Search is powerful, but it should not be treated as a replacement for analyst review.

Do not rely on Smart Search alone when:

* the investigation is high impact and requires precise filtering
* results look incomplete or too broad
* you need exact field-level control
* the generated query needs validation
* you are working with a sensitive or formal investigation where accuracy matters more than speed

The output of Smart Search should be treated as a **starting point**, not automatically assumed to be correct.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Accessing%20Smart%20Search%20&fontSize=26&fontColor=ffffff"/>
</p>


Smart Search is available from within an Exploration.

Navigation path:

```
Proofpoint Data Security & Posture
→ Data Security Workbench
→ Activity
→ Explorations
→ New Exploration
```

To use Smart Search:

1. Open or create an Exploration
2. In the Filters area, click **+**
3. From the list of available fields, select **Advanced Query with AI**
4. Enter your natural language query
5. Click **Generate**
6. Review the generated results
7. Click **Done** if the query is correct, or edit it manually if needed

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=How%20Smart%20Search%20Works%20&fontSize=26&fontColor=ffffff"/>
</p>


Smart Search interprets the language in your query and attempts to map it to available Proofpoint fields, operators, values, and filters.

This means it tries to understand:

* who you are investigating
* what activity you are looking for
* what time range applies
* what data source might be relevant
* whether the query refers to risk, alerts, web activity, DLP, or file actions

For example, if you type:

`Show me admin users with DLP activity in the last week`

Smart Search may infer:

* a user or group filter related to admin users
* a signal type filter for DLP
* a time filter covering the past 7 days

This can save a large amount of time compared to building the same query manually.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Basic%20Workflow%20for%20Using%20Smart%20Search&fontSize=26&fontColor=ffffff"/>
</p>


A good analyst workflow for Smart Search is:

1. Define the investigation question clearly
2. Enter a natural language query in Smart Search
3. Review the generated Exploration
4. Validate that the fields and time range make sense
5. Refine or add filters manually if needed
6. Save the Exploration if it is useful

This keeps Smart Search within its best role, which is helping you get to a useful query faster.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=What%20Makes%20a%20Good%20Smart%20Search%20Query%20&fontSize=26&fontColor=ffffff"/>
</p>


Smart Search queries work best when the request includes:

* clear
* specific
* based on actual investigation goals
* limited to one or two main ideas at a time

Good queries usually include some combination of:

* a user, group, or role
* an activity type
* a time range
* a risk concept
* a destination or object

Examples of useful query ingredients:

| Query Element | Example                                       |
| ------------- | --------------------------------------------- |
| User or group | admin users, VAP users, a named user          |
| Activity      | DLP activity, file uploads, browsing activity |
| Time          | last 24 hours, last 7 days, last 30 days      |
| Risk concept  | risky activity, anomaly, high risk            |
| Object        | USB device, cloud folder, gaming websites     |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Example%20Smart%20Search%20Queries%20&fontSize=26&fontColor=ffffff"/>
</p>


Below are examples of Smart Search queries that work well as starting points for common investigations.

| Example | Investigation Goal | Smart Search Query | Why It Is Useful |
|---|---|---|---|
| DLP activity for privileged users | Identify potentially risky data handling behavior performed by privileged accounts | Show DLP activity for admin users in the last 7 days | Helps detect whether high-privilege users are triggering DLP events that may indicate data exfiltration or policy violations. |
| VAP user monitoring | Review activity from users classified as Very Attacked People (VAP) | Show activity for VAP users in the last 30 days with risk level | Useful for identifying behavior associated with high-risk users and understanding how Proofpoint has classified their activity risk. |
| Gaming website browsing | Investigate acceptable use policy violations related to non-work browsing | Find users browsing gaming websites this week | Helps identify patterns of non-business browsing that may violate acceptable use policies. |
| Suspicious external sharing | Investigate whether files are being shared outside the organization | Show file sharing activity where files were shared externally | Helps detect potential data exposure or unauthorized sharing through cloud platforms. |
| User follow-up after an alert | Pivot from an alert into a broader activity investigation | Show all activity for jsmith around the time of the alert | Allows analysts to review surrounding user behavior and determine whether the alert was isolated or part of a larger pattern. |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Writing%20Better%20Queries%20&fontSize=26&fontColor=ffffff"/>
</p>


There are practical ways to improve Smart Search results.

## Be specific about the activity

Instead of:


`Find suspicious stuff`


Use:

`Show file upload activity to cloud storage in the last 7 days`

Specific activities are easier for Smart Search to interpret accurately.

## Include a time range

Time ranges help reduce noise and improve the relevance of the results.

Instead of:


`Show admin user activity`


Use:


`Show admin user DLP activity in the last 30 days`


## Include the subject of the search

If you know who or what you are investigating, include it.

Examples:

* a specific user
* a group such as admin
* a category such as Games
* a property such as VAP

## Avoid combining too many ideas at once

Overly complex requests may produce confusing or overly broad results.

Instead of asking one long multi-part question, start with one clear investigation goal and refine from there.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>
<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Examples%20of%20Weak%20vs%20Strong%20Queries%20&fontSize=26&fontColor=ffffff"/>
</p>

---

| ❌ Weak Query | ⚠ Problem | ✅ Better Query |
|---|---|---|
| `Show risky stuff` | Too vague. Missing user, activity, and timeframe. | `Show high risk file activity for VAP users in the last 30 days` |
| `Find web issues` | Too broad. Does not specify web activity type. | `Show users browsing gaming websites in the last 7 days` |
| `Investigate this user` | Missing activity and timeframe. | `Show file upload and DLP activity for jsmith in the last 24 hours` |
| `Check anomalies` | Missing context about anomaly type. | `Show anomalous data exfiltration activity in the last 30 days` |

This matters because Smart Search can only generate good results when the investigation question is clear enough to map to platform fields.


<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Reviewing%20the%20Generated%20Query%20&fontSize=26&fontColor=ffffff"/>
</p>


Once Smart Search returns results, you should review them carefully before accepting them.

Check the following:

| Review Area   | What to Confirm                              |
| ------------- | -------------------------------------------- |
| Time range    | Is it correct for the investigation?         |
| Source        | Does it match the event type you care about? |
| Filters       | Do they reflect the query you intended?      |
| Results       | Are they relevant and not overly broad?      |
| Missing logic | Is anything important absent?                |

A junior analyst should build the habit of reviewing the generated query instead of clicking **Done** immediately.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=What%20to%20Look%20For%20After%20Generation%20&fontSize=26&fontColor=ffffff"/>
</p>


After Smart Search builds the query, inspect whether it correctly interpreted the request.

Questions to ask:

* Did it choose the right source?
* Did it set the right time range?
* Did it include the correct user, group, or activity?
* Are the results actually relevant to the investigation?
* Is anything obviously missing?

For example, if you asked for cloud sharing activity but the Exploration still appears to be rooted in endpoint-only data, the query may need manual correction.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Refining%20Smart%20Search%20Results%20Manually%20&fontSize=26&fontColor=ffffff"/>
</p>


Smart Search results can and should be edited if they are not quite right.

Common manual refinements include:

* changing the time range
* correcting the source node
* adding a missing filter
* tightening a broad condition
* removing irrelevant generated logic

This is one of the most important practical points for junior analysts:

**Smart Search is not the final investigation step. It is the first draft of an Exploration.**

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Suggested%20Analyst%20Process%20&fontSize=26&fontColor=ffffff"/>
</p>


A practical process for using Smart Search is:

1. Enter a natural language query
2. Generate the results
3. Review the source node
4. Review the time range
5. Review the filters that were created
6. Check whether the returned results match the investigation goal
7. Add or remove filters manually if needed
8. Save the Exploration if it is useful for reuse

This approach turns Smart Search into a reliable productivity tool without over-trusting it.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Smart%20Search%20and%20Junior%20Analysts&fontSize=26&fontColor=ffffff"/>
</p>


Smart Search is especially helpful for junior analysts because it reduces the need to memorize the full field hierarchy in Proofpoint.

It can help newer analysts:

* learn how Proofpoint maps investigation concepts to fields
* build working Explorations more quickly
* understand how different activity types are represented
* gain confidence before building fully manual queries

A useful learning exercise is:

1. Enter a plain language query
2. Generate the Smart Search result
3. Review which fields Smart Search used
4. Compare that with how you would build the same Exploration manually

This helps analysts learn the underlying structure of the platform over time.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Common%20Smart%20Search%20Use%20Cases&fontSize=26&fontColor=ffffff"/>
</p>

---

| Use Case | Purpose | Example Smart Search Query |
|---|---|---|
| Alert follow-up | Investigate additional activity from a user after an alert has been triggered | Show all activity for this user in the last 24 hours related to DLP |
| User risk review | Review behavior of high-risk users such as VAP users over a longer period | Show high risk activity for VAP users over the past month |
| Website investigation | Identify users accessing specific website categories such as generative AI tools | Find users browsing generative AI sites this week |
| File exposure review | Investigate files that may have been shared externally or exposed | Show file sharing activity involving external users |
| Anomaly follow-up | Investigate abnormal data movement detected by anomaly detection | Show anomalous data exfiltration activity for the last 30 days |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Common%20Pitfalls%20&fontSize=26&fontColor=ffffff"/>
</p>


Smart Search is powerful, but it can produce misleading results if queries are not written clearly or if the generated exploration is not reviewed carefully.

| Pitfall | Description | Example / Impact | Recommended Practice |
|---|---|---|---|
| Query is too vague | A vague request may return a broad or irrelevant result set because Smart Search cannot infer the intended fields or filters. | Example query: `Show suspicious things` | Be specific about the activity, user, and timeframe. Example: `Show file upload activity to external cloud storage in the last 7 days`. |
| No time range provided | Without a clear time range, the query may search too much data or not align with the event being investigated. | Results may contain irrelevant historic activity or miss the relevant event. | Always include a time window such as `last 24 hours`, `last 7 days`, or `last 30 days`. |
| Assuming the generated query is correct | Smart Search generates a suggested query, but it may not perfectly match the intended investigation logic. | The generated filters may reference incorrect fields or incomplete conditions. | Always review the generated exploration filters before accepting the results. |
| Using Smart Search for highly precise work without checking | Complex investigations may require exact field logic that Smart Search cannot perfectly interpret. | Important filters may be missing or incorrectly interpreted. | Validate and refine the query manually after Smart Search generates it. |
| Treating Smart Search as a replacement for platform knowledge | Smart Search assists with building explorations but does not replace understanding how Proofpoint activity fields and detections work. | Analysts may misinterpret results or rely on incorrect assumptions. | Use Smart Search as a starting point, then verify the results using manual exploration filters and investigation tools. |

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Example%20Investigation%20Walkthrough&fontSize=26&fontColor=ffffff"/>
</p>


The example below demonstrates how Smart Search can be used as a **fast starting point for a real investigation**, particularly when responding to alerts involving privileged users.

## Scenario

An alert indicates that a **privileged user may have triggered DLP activity**.  
Because privileged users often have broader system access, it is important to determine:

- whether the activity was legitimate administrative work
- whether sensitive data may have been accessed or transferred
- whether the alert is part of a larger pattern of risky behavior

Rather than manually building multiple filters, Smart Search can quickly generate a starting Exploration.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

## Smart Search Query

```
Show DLP activity for admin users in the last 7 days
```

This query attempts to identify **recent DLP-related activity involving privileged accounts**, which can help determine whether the alert is isolated or part of repeated behavior.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

## Validate the Generated Exploration

After Smart Search generates the exploration, the analyst should verify that the query was interpreted correctly.

Key checks include:

- **Source**  
  Ensure the data source reflects the activity type being investigated (for example endpoint activity if the DLP signal originated from endpoint telemetry).

- **Time range**  
  Confirm the query covers an appropriate window for investigation. Expanding to 7–30 days can reveal patterns that are not visible in shorter windows.

- **User filter**  
  Confirm the query correctly references the **admin group** or relevant privileged users.

- **Activity or signal type**  
  Verify the filter is actually looking for **DLP-related signals** rather than unrelated activity.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

## Investigation Follow-up

If the generated results are relevant, the analyst can pivot deeper into the investigation by:

- reviewing individual activity records in the results table
- opening activity details for metadata and contextual information
- pivoting into **Timeline** to review surrounding user behavior
- checking for **repeated signals or patterns**
- reviewing any associated alerts or anomaly detections

If the Exploration proves useful, it can be saved as a reusable query such as:

```
Privileged User DLP Activity – 7 Day Review
```

Saved explorations allow analysts to quickly repeat investigations when similar alerts occur in the future.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

## Why This Example Is Useful

This scenario demonstrates how Smart Search can:

- quickly generate a meaningful investigation query
- reduce the time required to build complex filters
- help analysts pivot from alerts into deeper behavioral analysis
- identify patterns of risky activity among privileged accounts

Smart Search is most effective when used as a **starting point for investigation**, followed by manual validation and refinement of the generated Exploration.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=Relationship%20to%20Manual%20Explorations&fontSize=26&fontColor=ffffff"/>
</p>


Smart Search and manual Explorations are not competing features. 

They work well together.

| Approach                    | Best Use                                          |
| --------------------------- | ------------------------------------------------- |
| Smart Search                | Fast first-pass query building                    |
| Manual Exploration building | Precise field-level control and deeper refinement |

A mature analyst workflow often uses both:

* use Smart Search to get started quickly
* manually tune the Exploration once the investigation direction is clear

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>

<p align="center">
<img src="https://capsule-render.vercel.app/api?type=soft&color=0:0EA5E9,100:2563EB&height=90&section=header&text=When%20to%20Save%20a%20Smart%20Search%20Exploration&fontSize=26&fontColor=ffffff"/>
</p>


You should save the generated Exploration when:

* the results are useful and accurate
* the query supports a recurring investigation pattern
* other analysts are likely to reuse it
* it supports a runbook or monitoring workflow

Examples:

* VAP user activity over 30 days
* admin DLP activity review
* gaming site browsing review
* external sharing review

Saved Explorations can become team investigation templates.

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:0EA5E9,100:2563EB&height=3"/>
