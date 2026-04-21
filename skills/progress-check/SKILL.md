---
name: progress-check
description: "Update WBS progress from project management tickets, detect delays, and generate a Gantt chart"
argument-hint: "[target milestone or 'all']"
disable-model-invocation: true
---

# WBS Progress Update & Delay Detection

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{PROJECT_NAME}` | Project name | `MyProject` |
| `{SLACK_CHANNELS}` | Target Slack channels (name -> ID) | `#dev: C012345` |
| `{SLACK_USERS_INTERNAL}` | Internal team members (name -> ID -> role) | (project-specific) |
| `{SLACK_USERS_EXTERNAL}` | External partners (name -> ID -> org -> role) | (project-specific) |
| `{TICKET_SYSTEM}` | Ticket management system (Backlog, Jira, GitHub Issues, etc.) | `Backlog` |
| `{TICKET_PROJECT}` | Ticket project key / ID | `MY_PROJECT (ID: 12345)` |
| `{PM_DIR}` | Project management directory | `docs/pm` |
| `{DESIGN_DIR}` | Design documents directory | `docs/design` |

---

## Execution Flow

### Step 1: Load Existing WBS

1. Read the latest WBS file from `{PM_DIR}/WBS/`
2. **Important**: Do NOT start working from archives alone. Always fetch the latest data from the ticket system in Step 2.

### Step 2: Fetch All Tickets

1. Retrieve all tickets from `{TICKET_PROJECT}`
2. Filter by milestone if specified
3. Collect the following for each ticket:
   - Ticket key, title
   - Status
   - Assignee
   - Start date, due date
   - Actual hours, estimated hours
   - Parent ticket (category)
   - Recent comments

#### Status Mapping

| Ticket Status | WBS Status | Progress Estimate |
|:--|:--|:--|
| Open / Not Started | Not Started | 0% |
| In Progress | In Progress | 10%-90% (estimated from comments/hours) |
| In Review / Done | Awaiting Review | 90% |
| Closed / Resolved | Complete | 100% |

### Step 3: Generate Progress Summary Table

```markdown
# {PROJECT_NAME} WBS Progress Summary (YYYY-MM-DD)

## Overall Progress

| Metric | Value |
|:--|:--|
| Total tickets | N |
| Complete | N (XX%) |
| In Progress | N (XX%) |
| Not Started | N (XX%) |
| Delayed tickets | N |
| Due today | N |

## Milestone Progress

| Milestone | Due Date | Total | Complete | In Progress | Not Started | Progress | Status |
|:--|:--|:--|:--|:--|:--|:--|:--|
| MS1 | MM/DD | N | N | N | N | XX% | :green_circle: / :yellow_circle: / :red_circle: |

## Assignee Progress

| Assignee | Team | Total | Complete | In Progress | Not Started | Delayed |
|:--|:--|:--|:--|:--|:--|:--|
| Name | Internal/External | N | N | N | N | N |

## Ticket Details

| Key | Title | Assignee | Status | Due | Days Delayed | Notes |
|:--|:--|:--|:--|:--|:--|:--|
| PRJ-001 | Title | Name | In Progress | MM/DD | 0 | Status from comments |
```

### Step 4: Generate Mermaid Gantt Chart

Generate a Mermaid-format Gantt chart from WBS data:

```markdown
## Gantt Chart

\`\`\`mermaid
gantt
    title {PROJECT_NAME} Development Schedule
    dateFormat YYYY-MM-DD
    axisFormat %m/%d

    section Milestone 1
    Task 1           :done,    task1, 2026-03-01, 2026-03-07
    Task 2           :active,  task2, 2026-03-05, 2026-03-14
    Task 3           :         task3, after task2, 5d

    section Milestone 2
    Task 4           :crit,    task4, 2026-03-10, 2026-03-20
\`\`\`
```

Gantt chart rules:
- Completed tasks: `:done`
- In-progress tasks: `:active`
- Delayed tasks: `:crit` (shown in red)
- Not-started tasks: no marker
- Dependencies: use `after taskX`

### Step 5: Delay Detection & Alerts

Detect delays using the following conditions:

1. **Overdue**: Tickets past their due date and not yet complete
2. **Behind schedule**: Low progress relative to remaining time
   - Less than 25% time remaining with < 50% progress -> Warning
   - Due today with < 90% progress -> Critical
3. **Not started risk**: Tickets past their planned start date but not started
4. **Blockers**: Tickets that cannot proceed because dependencies are incomplete

```markdown
## Delay & Risk Alerts

### :red_circle: Critical (Immediate Action Required)
| Ticket | Assignee | Due | Status | Recommended Action |
|:--|:--|:--|:--|:--|

### :yellow_circle: Warning (Address This Week)
| Ticket | Assignee | Due | Status | Recommended Action |
|:--|:--|:--|:--|:--|

### :blue_circle: Info (Awareness)
| Ticket | Assignee | Due | Status | Notes |
|:--|:--|:--|:--|:--|
```

### Step 6: Save Updated WBS

1. Update WBS file: `{PM_DIR}/WBS/WBS_{PROJECT_NAME}_YYYY-MM-DD.md`
2. Output diff from previous WBS (newly completed, newly delayed, status changes)

---

## Rules

- **Never send emails** (drafts only)
- **Never include cost/rate/margin information**
- **All timestamps should use the project's local timezone**
- **Always get user confirmation before writing to external services**
- **Do NOT start from archives alone** — always fetch latest data first
- **Estimate progress using comments and actual hours**, not just ticket status
