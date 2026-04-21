---
name: month-end
description: "Month-end closing orchestrator: action item check -> progress update -> doc update -> work report -> invoice draft, then git commit & push"
argument-hint: "[target month, e.g. '2026-03']"
disable-model-invocation: true
---

# Month-End Closing (Master Orchestrator)

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{PROJECT_NAME}` | Project name | `MyProject` |
| `{SLACK_CHANNELS}` | Target Slack channels (name -> ID) | `#dev: C012345` |
| `{SLACK_USERS_INTERNAL}` | Internal team (name -> ID -> role) | (project-specific) |
| `{SLACK_USERS_EXTERNAL}` | External partners (name -> ID -> org -> role) | (project-specific) |
| `{TICKET_PROJECT}` | Ticket project key/ID | `MY_PROJECT` |
| `{PM_DIR}` | Project management directory | `docs/pm` |
| `{DESIGN_DIR}` | Design documents directory | `docs/design` |
| `{COST_ALLOCATION_FILE}` | Time allocation file path | `docs/pm/time-allocation.xlsx` |
| `{CLIENT_NAME}` | Client name | `Client Corp` |
| `{CONTRACT_TYPE}` | Contract type | `T&M` |
| `{BILLING_AMOUNT}` | Monthly billing amount (before tax) | `$10,000` |
| `{BILLING_ITEMS}` | Invoice line items | (project-specific) |

---

## Execution Order (Strictly Sequential)

Month-end closing runs in the following order. Each step's output feeds into the next, so **the order must not be changed**.

```
Step 1: ball-check (Action item review)
    | Understand unresolved items
Step 2: progress-check (Progress update)
    | Update WBS & Gantt chart
Step 3: design-update (Documentation update)
    | Reflect discussions in design docs
Step 4: work-report (Work report)
    | Generate monthly report
Step 5: invoice-draft (Invoice draft)
    | Prepare invoice
Step 6: Git commit & push
```

---

## Step Details

### Step 1: Action Item Review (ball-check)

**Purpose**: Inventory unresolved action items at month-end to prevent things from falling through the cracks.

1. Run `/ball-check` for the entire target month
2. Output: `{PM_DIR}/action-items/action-items_YYYY-MM-DD.md`
3. **Check**:
   - Are there blockers that should be resolved by month-end?
   - Are carryover items clearly documented for next month?

### Step 2: WBS Progress Update (progress-check)

**Purpose**: Bring progress tracking up to date and detect delays.

1. Run `/progress-check` for all milestones
2. Output: `{PM_DIR}/WBS/WBS_{PROJECT_NAME}_YYYY-MM-DD.md`
3. **Check**:
   - Are all tickets planned for this month complete?
   - Are delayed tickets documented with reasons and countermeasures?
   - Does the Gantt chart reflect reality?

### Step 3: Documentation Update (design-update)

**Purpose**: Reflect the month's discussions into design documents.

1. Run `/design-update` for the target month (if this skill is configured)
2. Output: `{DESIGN_DIR}/` updated docs + `{PM_DIR}/doc-changes/change-report_YYYY-MM-DD.md`
3. **Check**:
   - Are all agreed spec changes reflected in documentation?
   - Are client-facing documents up to date?
   - **User approval required**: Documentation changes must be approved before applying

### Step 4: Work Report (work-report)

**Purpose**: Generate the client-facing monthly work report.

1. Run `/work-report` for the target month
2. Output: `{PM_DIR}/reports/work-report_{PROJECT_NAME}_YYYY-MM.md`
3. **Check**:
   - Time allocation (master) aligns with WBS progress
   - **No cost/rate/margin information included** (strictly enforced)
   - Deliverables list is complete

### Step 5: Invoice Draft (invoice-draft)

**Purpose**: Prepare invoice information for the accounting system.

1. Run `/invoice-draft` for the target month and client
2. Output: `{PM_DIR}/invoices/invoice_YYYYMM_{CLIENT_NAME}.md`
3. **Check**:
   - Billing amount matches contract terms
   - Final checklist completed
   - **Accounting system entry is DRAFT only** (user confirms before sending)

### Step 6: Git Commit & Push

Commit and push all output files.

```bash
git add {PM_DIR}/
git add {DESIGN_DIR}/

git commit -m "month-end: {PROJECT_NAME} YYYY-MM

- Action item review
- WBS progress update + Gantt chart
- Documentation update
- Work report generated
- Invoice draft prepared"

git push origin HEAD
```

---

## Pre-Execution Checklist

Before starting month-end closing:

- [ ] `{COST_ALLOCATION_FILE}` is up to date with the target month's hours
- [ ] Ticket statuses in `{TICKET_PROJECT}` reflect reality
- [ ] Contract amount and billing terms are confirmed for the target month
- [ ] Previous month's invoice has been paid

## Post-Execution Checklist

After all steps are complete:

- [ ] Action items: Carryover items are clearly documented
- [ ] WBS: Delayed tickets have countermeasures documented
- [ ] Documentation: Client-facing versions are up to date
- [ ] Work report: No internal cost information included
- [ ] Invoice: Final checklist all OK
- [ ] Git: Commit and push successful
- [ ] Accounting system: Invoice saved as draft (not sent)

---

## Rules

- **Never send emails** (drafts only)
- **Never include cost/rate/margin information**
- **All timestamps should use the project's local timezone**
- **Always get user confirmation before writing to external services**
- **Do NOT start from archives alone** — fetch latest data first
- **Do NOT change the execution order**: Each step's output feeds the next
- **Documentation changes require user approval**
- **Accounting system invoices are DRAFT only** (user sends manually)
