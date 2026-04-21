---
name: pre-meeting-proposal
description: Generate a pre-meeting briefing from a lead report PDF — research the prospect, prepare discovery questions, and create a briefing document
argument-hint: "[prospect name] [report PDF path or email search keyword]"
disable-model-invocation: true
---

# Pre-Meeting Briefing Preparation

Generate a briefing document from a lead/prospect report, focused on **discovery-first selling** for the initial meeting.

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{COMPANY_NAME}` | Your company name | `Acme Corp` |
| `{SALES_DIR}` | Sales documents directory | `sales/` |
| `{SALES_REPO}` | Sales management repository path | `~/repos/sales-internal` |
| `{GH_USER}` | GitHub username for push | `my-github-user` |
| `{COMPETITIVE_ADVANTAGES}` | Your company's key differentiators (table) | (see below) |

### Competitive Advantages Template

Define your differentiators in `CLAUDE.md`:
```markdown
| # | Advantage | Talking Point |
|:-:|:----------|:-------------|
| 1 | Deep domain expertise in X | Proven track record with Y |
| 2 | End-to-end delivery capability | Design through production and operations |
| 3 | Agile team structure | Fast decision-making, consistent point of contact |
| 4 | Enterprise client track record | Named references available |
| 5 | ... | ... |
```

---

## Core Principle: First Meeting = Discovery

> **The goal of the first meeting is discovery, not pitching.**
> - The winning pattern: thorough discovery in meeting 1, then proposal + demo in meeting 2
> - Sending prototypes before discovery locks expectations at low-resolution requirements and increases loss risk
> - Lead reports may not accurately capture the prospect's real challenges. Treat report content as **hypotheses** to validate
> - Do not present pricing or prototypes until the second meeting

## Arguments

- `$0`: Prospect/company name
- `$1`: Lead report PDF path, or email search keyword

## Execution Steps

### Step 1: Obtain & Read Lead Report

**If a file path is provided**: Read the file directly (PDF via Read tool)

**If an email search keyword is provided**:
1. Search Gmail with `mcp__google_workspace__search_gmail_messages`
2. Get email content with `mcp__google_workspace__get_gmail_message_content`
3. Download attachment with `mcp__google_workspace__get_gmail_attachment_content`

**Extract from the report**:
- Company name (official), contact person name/department/title/email
- Project overview, background, budget range (initial + recurring)
- Desired timeline, selection criteria, priorities
- Current systems/tools, competitive situation

**Important**: Treat all extracted content as **hypotheses**. Do not accept them as facts until validated in the meeting.

### Step 2: Web Research on the Prospect

1. **Company website**: Fetch the company overview page with WebFetch
2. **Job sites / databases**: Look up revenue, headcount, business segments
3. **News search**: WebSearch for "{company name} digital transformation", "{company name} AI", etc.
4. **Existing data**: Cross-reference with any existing prospect data files

### Step 3: Create Briefing Document (MD)

**Save to**: `{SALES_DIR}/meetings/{prospect_name}/{prospect_name}_briefing.md`

```markdown
# {Prospect Name} — First Meeting Briefing

| Item | Details |
|:--|:--|
| Created | {YYYY-MM-DD} |
| Meeting Date | {from calendar, or "TBD"} |
| Lead ID | {if applicable} |
| Contact | {name} ({department}) |

---

## 1. Company Overview
(Summary from web research)

## 2. Lead Report Summary (Hypotheses — Validate in Meeting)
- Project overview
- Stated challenges
- Budget / timeline indicators

## 3. Discovery Questions (Most Important Section)

### Must-Ask Questions
- What triggered this initiative? Why now?
- What's the biggest pain point in the current workflow? (Let the prospect describe it in their own words)
- Have you tried similar solutions before? If so, what didn't work?
- What does the decision-making process look like? Timeline?
- Are you speaking with other vendors? Roughly how many?

### Hypothesis Validation Questions
(For each challenge mentioned in the report, design a question to verify it)
- "The report mentions X — can you walk me through a specific situation where this comes up?"
- "How are you currently handling X?"

### Follow-Up Questions (Use Naturally in Conversation)
- "How often does that happen?"
- "Who is most affected by this?"
- "What would the ideal outcome look like?"

## 4. Competitive Advantage Mapping (Use Only If Asked)

| Report Challenge (Hypothesis) | Relevant Advantage | How to Bring It Up |
|:--|:--|:--|
| {challenge1} | {advantage} | "We had a similar situation with a client where we..." |

Note: Let the prospect ask. Do not volunteer a list of advantages.

## 5. Meeting Goals

- **Minimum goal**: Hear 3+ real challenges described in the prospect's own words
- **Ideal goal**: Secure a second meeting date and agree on data/materials sharing
- **Do NOT**: Present tiered pricing, show prototypes, dive deep into technical details
```

### Step 4: Prepare Company Introduction Materials

Place company introduction PDF in `{SALES_DIR}/materials/`.
For the first meeting, bring ONLY the company intro. No proposals, no prototypes.

### Step 5: Internal Prep Notes (Not Shared with Prospect)

**Save to**: `{SALES_DIR}/meetings/{prospect_name}/{prospect_name}_internal_prep.md`

Pre-research technical approaches so you can quickly build a proposal after the meeting.
**This document is NOT used in the first meeting. It will be rewritten based on discovery findings.**

```markdown
# {Prospect Name} — Internal Prep Notes (Confidential)

Note: This will be significantly revised after the first meeting based on actual discovery.
Do not share with the prospect.

## Technical Approach Hypotheses
- Candidate technical approaches for the reported challenges
- Candidate platforms / cloud services
- Relevant past project experience

## Rough Budget Range (Internal Reference Only)
- First step (PoC/validation): $XX-XX / X months
- Full proposal pricing to be designed after second meeting when requirements are clear

## Prototype Direction (For Second Meeting Prep)
- Build based on prospect's actual challenges (discovered in meeting)
- At this stage, just directional notes
```

### Step 6: Git Commit & Push

```bash
cd {SALES_REPO}
git add "{SALES_DIR}/meetings/{prospect_name}/"
git commit -m "add: {prospect_name} first meeting briefing"
GH_TOKEN=$(gh auth token --user {GH_USER}) git push origin main
```

## Final Checklist

- [ ] Briefing MD saved to `{SALES_DIR}/meetings/`
- [ ] Discovery questions are specific and include hypothesis-validation questions
- [ ] Internal prep notes created (confidential)
- [ ] Company intro PDF prepared
- [ ] Committed and pushed to sales repo
- [ ] No confidential internal data (cost rates, margins, hourly rates) included
- [ ] No prototypes or proposals in deliverables (this is a first-meeting prep)

## Notes

- **Never send emails** — drafts only
- **No prototypes or proposals before the first meeting**. Use `/post-meeting-proposal` after the meeting
- Lead report content is a "hypothesis" — validate it in the meeting
- Never include internal cost/rate/margin information
