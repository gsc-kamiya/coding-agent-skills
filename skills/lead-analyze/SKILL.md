---
name: lead-analyze
description: Weekly lead pipeline review — screen new leads + update in-progress lead statuses + detect dormant leads
argument-hint: "[search window, e.g. '1w' or '2026-03-01~2026-03-31']"
---

# Weekly Lead Pipeline Review

Batch-fetch the recent lead-related emails, then run new-lead screening + in-progress status updates + cancellation/dormant detection in one pass.

> **Customization**: Define your tech stack, budget thresholds, and scoring criteria via `/lead-screen`'s configuration in your project.

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{LEAD_SOURCE_NAME}` | Name of the matching service or referral channel | `MyMatchingService` |
| `{GMAIL_SEARCH_QUERY}` | Gmail search query for lead emails | `from:notifications@matching.example` |
| `{LEAD_REPORT_DIR}` | Output directory for lead reports | `sales/leads` |
| `{DORMANT_DAYS_THRESHOLD}` | Days of inactivity before a lead is "dormant" | `21` |

---

## Arguments

- `$0`: Search window (e.g., `1w` = last week, `2w` = last 2 weeks, `2026-03-01~2026-03-31` = explicit range)

## Execution Steps

### Step 1: Batch-Fetch Emails

Fetch all lead-related emails from the target inbox for the window:

- New lead notification emails
- Follow-up emails (scheduling, application acceptance, report delivery, etc.)
- Cancellation / decline emails

### Step 2: Classify Emails

| Category | Detection | Action |
|:---|:---|:---|
| A: New lead notification | Contains lead ID + matches new-lead pattern | → Steps 3-7 (same as `/lead-screen`) |
| B: Follow-up | `Re:`, application accepted, report delivered, scheduling | → Step 8 (status update) |
| C: Other | Anything else | → Skip |

### Steps 3-7: New Lead Screening

Run the same pipeline as `/lead-screen`:

3. Instant-skip filter
4. Fetch lead detail (scraping / PDF)
5. Required-capability check
6. 5-axis scoring
7. Generate proposal form (S / A only)

### Step 8: In-Progress Status Update

Detect status changes from follow-up emails:

| Status | Detection patterns |
|:---|:---|
| Application accepted | "your application has been accepted" |
| Meeting confirmed | "scheduling", "candidate slots" |
| Report received | "report has been sent" |
| Cancelled | "declined", "cancelled", "passed" |
| Reminder | "reminder", "follow-up" |

### Step 9: Dormant Lead Detection

Flag any in-progress lead whose last contact is more than `{DORMANT_DAYS_THRESHOLD}` days ago as a "dormant candidate".

### Step 10: Weekly Report Output

Save to: `{LEAD_REPORT_DIR}/weekly_review_{YYYYMMDD}.md`

```markdown
# Weekly Lead Review ({YYYY/MM/DD})

## New Lead Screening
| Decision | Count | Companies |
|:---|:---:|:---|
| S | {n} | ... |
| A | {n} | ... |
| B | {n} | — |
| C/D | {n} | — |

## In-Progress Lead Status
| Lead ID | Company | Previous status | This week's action | Current status |
|:---|:---|:---|:---|:---|

## Dormant Candidates (no contact for >{DORMANT_DAYS_THRESHOLD} days)
| Lead ID | Company | Last contact | Days since |

## This Week's Actions
1. {Apply to S-rated leads}
2. {Follow up on in-progress leads}
3. {Decide on dormant candidates}
```

## Rules

- **Never send emails**
- **Never include confidential information** (cost rates, margins, etc.)
- Cross-check against any existing pipeline tracker
