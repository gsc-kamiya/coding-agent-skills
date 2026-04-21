---
name: work-report
description: "Generate a monthly work report from WBS and time allocation data (never include cost/rate/margin info)"
argument-hint: "[target month, e.g. '2026-03']"
disable-model-invocation: true
---

# Monthly Work Report Generator

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{PROJECT_NAME}` | Project name | `MyProject` |
| `{SLACK_CHANNELS}` | Target Slack channels (name -> ID) | `#dev: C012345` |
| `{SLACK_USERS_INTERNAL}` | Internal team members (name -> ID -> role) | (project-specific) |
| `{SLACK_USERS_EXTERNAL}` | External partners (name -> ID -> org -> role) | (project-specific) |
| `{TICKET_PROJECT}` | Ticket project key / ID | `MY_PROJECT` |
| `{PM_DIR}` | Project management directory | `docs/pm` |
| `{DESIGN_DIR}` | Design documents directory | `docs/design` |
| `{COST_ALLOCATION_FILE}` | Time allocation file path (Excel/CSV) | `docs/pm/time-allocation.xlsx` |
| `{CLIENT_NAME}` | Client name (report recipient) | `Client Corp` |

---

## Data Source Priority

1. **Time allocation table** (`{COST_ALLOCATION_FILE}`) = **Master data**
   - Official record of work hours, assignees, and task categories
   - If WBS conflicts, the time allocation table takes precedence
2. **WBS** (`{PM_DIR}/WBS/`) = Progress and status reference
3. **Project tickets** = Task details and comments reference
4. **Slack** = Supplementary info (discussion context, etc.)

---

## Execution Flow

### Step 1: Data Collection

1. Read time allocation table (`{COST_ALLOCATION_FILE}`)
2. Read WBS files for the target month
3. Fetch tickets updated during the target month from the ticket system
4. **Important**: Do NOT start from archives alone

### Step 2: Generate Report (6-Section Structure)

```markdown
# {PROJECT_NAME} Work Report
**Reporting Period**: YYYY-MM
**Report Date**: YYYY-MM-DD
**Prepared by**: {COMPANY_NAME}

---

## 1. Monthly Work Summary

3-5 line overview of work performed during the target month.
Highlight key deliverables and completed milestones.

## 2. Work Results

### 2.1 Task-Level Results

| # | Category | Task | Status | Assignee | Hours | Notes |
|---|----------|------|--------|----------|-------|-------|
| 1 | Design | Architecture design doc | Complete | Name | XX.X | |
| 2 | Development | API implementation | In Progress | Name | XX.X | 70% done |

### 2.2 Per-Assignee Results

| Assignee | Role | Hours | Main Tasks |
|----------|------|-------|------------|
| Name | Role | XX.X | Description |

### 2.3 Effort Summary

| Category | Planned (h) | Actual (h) | Diff (h) | Utilization |
|----------|-------------|------------|----------|-------------|
| Design | XX | XX | XX | XX% |
| Development | XX | XX | XX | XX% |
| Testing | XX | XX | XX | XX% |
| PM | XX | XX | XX | XX% |
| **Total** | **XX** | **XX** | **XX** | **XX%** |

## 3. Deliverables

| # | Deliverable | Type | Status | Notes |
|---|-------------|------|--------|-------|
| 1 | Architecture Design v2.0 | Design doc | Delivered | |
| 2 | API Specification | Design doc | In Review | |

## 4. Issues & Risks

| # | Issue/Risk | Impact | Status | Owner | Deadline |
|---|-----------|--------|--------|-------|----------|
| 1 | Description | High/Med/Low | In Progress/Resolved | Name | MM/DD |

## 5. Next Month's Plan

| # | Category | Task | Assignee | Planned Hours | Notes |
|---|----------|------|----------|---------------|-------|
| 1 | Development | Feature implementation | Name | XX | |

## 6. Special Notes

- Items affecting the overall project
- Schedule or scope changes
- Items requiring client confirmation or action
```

### Step 3: Cross-Check

1. Verify that time allocation totals align with WBS progress
2. Confirm completed tickets are reflected in the deliverables section
3. If discrepancies exist, use the time allocation table as the master and note in remarks

### Step 4: Save

Save report to: `{PM_DIR}/reports/work-report_{PROJECT_NAME}_YYYY-MM.md`

---

## Rules

- **Never send emails** (drafts only)
- **Never include cost/rate/margin information**: Work hours are OK, but unit costs and amounts are strictly excluded
- **All timestamps should use the project's local timezone**
- **Always get user confirmation before writing to external services**
- **Do NOT start from archives alone** — fetch latest data first
- **Time allocation table is the master**: Takes precedence over WBS when they conflict
- **Client-facing document**: Never include internal management data (cost rates, margins, hourly rates)
