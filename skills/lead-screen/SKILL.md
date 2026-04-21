---
name: lead-screen
description: Score inbound sales leads (matching services, referrals) on multiple axes and produce a Go/No-Go decision with a proposal form draft
argument-hint: "[Gmail search keyword or 'new' to auto-fetch unread leads]"
---

# Lead Screening & Go/No-Go Decision

Batch-fetch inbound lead notification emails from a matching service or referral channel, score each opportunity, and select only the leads where your team can win profitably.

> **Customization**: Override this file via your project's `.claude/skills/lead-screen/SKILL.md` to define your own technical stack, win patterns, and budget thresholds.

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{LEAD_SOURCE_NAME}` | Name of the matching service or referral channel | `MyMatchingService` |
| `{GMAIL_SEARCH_QUERY}` | Gmail search query for lead notification emails | `from:notifications@matching.example` |
| `{LEAD_REPORT_DIR}` | Output directory for screening reports | `sales/leads` |
| `{TECH_STACK}` | Your team's core technology stack | `Cloud-native, Python, React` |
| `{MIN_BUDGET}` | Minimum acceptable contract budget | (project-specific) |
| `{TARGET_BUDGET}` | Target contract budget range | (project-specific) |
| `{CORE_DOMAINS}` | Domains where your team has strong references | `Data analytics, AI integration, etc.` |
| `{OUT_OF_SCOPE_BUSINESS_TYPES}` | Business types you do not handle | `Staffing, on-site contracting, ERP selection` |

---

## Arguments

- `$0`: Gmail search keyword (e.g., `"opportunity notification"`) or `new` (auto-fetch unread leads)

## Design Principle

### Lead Channel Fundamentals

- For matching services, **selection > volume**. The cheapest mistake is the lead you should have skipped
- Roughly 80% of leads will not fit your team. Win the remaining 20% by picking carefully
- **Minimize decision cost**: 3-stage filter — subject-line skip → detail review → multi-axis scoring

### Common Win Patterns

The leads you tend to win share these traits:

1. A **specialized business process** exists (cannot be solved by generic SaaS)
2. The process is currently being **handled inefficiently by humans** (manual entry, paper, visual checks, tribal knowledge)
3. The buyer can **articulate the workflow clearly** (high digital literacy)
4. Your team can **win on speed** (you can show something working in a short timeframe)

## Execution Steps

### Step 1: Batch-Fetch Lead Notification Emails

1. Search lead notification emails with `mcp__google_workspace__search_gmail_messages` (`page_size: 25`, query = `{GMAIL_SEARCH_QUERY}`)
2. Batch-fetch message bodies with `mcp__google_workspace__get_gmail_messages_content_batch`
3. Extract from each email:
   - Lead/opportunity ID
   - Stated requirements
   - Detail-page URL (with auth tokens, if any)

### Step 1.5: Subject-Line Filter (Instant Skip)

Auto-classify as **D (skip)** if the subject or summary indicates:

- **Out of business model**: staffing, on-site contracting, subcontracting (anything in `{OUT_OF_SCOPE_BUSINESS_TYPES}`)
- **Package/SaaS selection**: ERP rollout, tool comparison, vendor selection
- **Out of technical scope**: anything clearly outside `{TECH_STACK}`

**When in doubt, advance to Step 2.** Do not decide on the subject line alone.

### Step 2: Fetch Lead Details

**You cannot judge lead quality from the email subject alone.** Always fetch the detail page or attached PDF.

- Detail page exists → Playwright scraping or WebFetch
- PDF attached → download with `mcp__google_workspace__get_gmail_attachment_content`
- Structure the following fields:
  - **Company**: name, industry, revenue scale, headcount
  - **Need**: detailed problem statement, background context
  - **Budget**: monetary range
  - **Timeline**: selection / kickoff / delivery dates
  - **Buyer**: title, decision-making flow
  - **Infrastructure**: cloud/on-prem, existing systems

### Step 3: Detail-Based Skip Filter

#### D (Instant Skip)

| Condition | Reason |
|:---|:---|
| Out of business model (staffing, etc.) | Business model mismatch |
| Completely outside `{TECH_STACK}` | Cannot deliver |
| Package/SaaS selection only | Not a build engagement |

#### C (Recommend Skip)

| Condition | Reason |
|:---|:---|
| Infrastructure requirements you cannot meet | Technical constraint |
| Budget below `{MIN_BUDGET}` | Cannot recover effort |
| Kickoff is more than 12 months out | No near-term cash impact |
| Explicit "information gathering" + no concrete schedule | High risk of wasted sales effort |
| Clear preference for SaaS / packaged solution | No room for custom build |

### Step 3.5: Required-Capability Match Check

Cross-check the lead's **must-have** requirements against your team's capability matrix:

- Any unmet must-have → auto-classify as C
- All must-haves covered → proceed to Step 4

> **Project-specific**: Define your own capability matrix in your project's `CLAUDE.md`.

### Step 4: 5-Axis Scoring

Each axis 0-5 points; total 25 points.

#### Axis 1: Need Specificity (0-5) — Most Important

| Score | Criteria |
|:---:|:---|
| 5 | Need is quantified. KPIs / numbers cited. Phasing already defined |
| 4 | Need is specific and the desired solution is articulated |
| 3 | Need exists but the solution direction is unclear |
| 2 | Vague "we want efficiency" type need |
| 1 | Explicitly states "information gathering" |
| 0 | No need described |

**Axis 1 ≤ 2 → auto-classify as C.**

#### Axis 2: Budget / Investment Intent (0-5)

| Score | Criteria |
|:---:|:---|
| 5 | Specific budget cited (top of `{TARGET_BUDGET}` range) |
| 4 | Budget cited within `{TARGET_BUDGET}` range, or "expansion possible" noted |
| 3 | "Budget being secured" or "next fiscal year request planned" |
| 2 | Budget near `{MIN_BUDGET}` |
| 1 | No budget cited and the company size suggests it will be tight |
| 0 | No budget cited and the need is also vague |

#### Axis 3: Timeline / Urgency (0-5) — Most Important

| Score | Criteria |
|:---:|:---|
| 5 | Selection date set + kickoff within 3 months + external deadline exists |
| 4 | Selection date set + kickoff likely within 3 months |
| 3 | Kickoff fuzzy but a selection schedule exists |
| 2 | No date set but real intent. Effective kickoff > 3 months |
| 1 | No schedule. Explicitly "information gathering" |
| 0 | "Just gathering info first" + nothing scheduled |

**Axis 3 ≤ 2 → auto-classify as C. High scores on other axes do not override this.**

#### Axis 4: Distance to Decision-Maker (0-5)

| Score | Criteria |
|:---:|:---|
| 5 | The decision-maker is the meeting attendee |
| 4 | Department head decides; in-budget purchases can be approved on the spot |
| 3 | IT/DX office is the contact; internal approval required |
| 2 | Contact is gathering info; nothing has been escalated |
| 1 | Contact says "I haven't told my boss yet" |
| 0 | Cannot tell |

#### Axis 5: Technical Fit (0-5)

> **Project-specific**: Tune the scoring criteria to match your team's strengths in `{CORE_DOMAINS}`.

| Score | Criteria |
|:---:|:---|
| 5 | Hits your core technology head-on. Demo can be built in days |
| 4 | Falls in your strong domain. References available |
| 3 | Doable but not your sweet spot |
| 2 | Adjacent technology. Partner needed |
| 1 | Technically very difficult |
| 0 | Total mismatch |

### Step 5: Total Decision

| Total | Decision | Action |
|:---:|:---|:---|
| **20-25** | **S: Apply immediately** | Generate proposal form right away |
| **15-19** | **A: Apply (recommended)** | Generate proposal form |
| **10-14** | **B: Consider applying** | Depends on pipeline state |
| **5-9** | **C: Skip (recommended)** | Only if pipeline is dry |
| **0-4** | **D: Skip** | Do not apply |

### Additional Flags

| Flag | Condition | Effect |
|:---|:---|:---|
| Adjacent expansion | Same family as an existing won deal | +2 |
| Large account | Listed company or revenue above your threshold | +2 (void if budget is low) |
| Repeat customer | Add-on for an existing client | +5 |
| Info-gathering + no schedule | "Information gathering" stated + nothing scheduled | Auto C |
| Trial trap | Tiny trial budget with promise of "company-wide rollout after results" | -3 |
| Far-future kickoff | Kickoff > 12 months out | -3 |

### Step 6: Generate Output Document

Save to: `{LEAD_REPORT_DIR}/screening_{YYYYMMDD}.md`

For each S- or A-rated lead:

- 5-axis score table (with rationale)
- 1-line summary
- Similarity to past won deals
- Risks / cautions
- Required-capability checklist

### Step 7: Generate Proposal Form Text (S / A only)

Save to: `{LEAD_REPORT_DIR}/proposal_form_{YYYYMMDD}.txt`

```
=== Lead ID: {ID} / {Company} ===
[Decision: {S/A}]

[Pitch (max ~400 chars)]
{Map your team's capability and references directly to the stated need}

[Approach (max ~400 chars)]
{Your solution approach + a phased rollout outline}

[Estimated price range]
To be discussed in the meeting

[Suggested meeting times]
{Slots from your calendar}
```

## Rules

- **Never send emails.** Search, read, and download attachments only
- **Never include internal cost / hourly rate / margin information**
- "To be discussed in the meeting" is the default for pricing
- Leads with insufficient information → mark as "decision deferred"
