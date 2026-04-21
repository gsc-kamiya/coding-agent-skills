---
name: invoice-draft
description: "Generate an invoice draft with accounting system input guide (standard template)"
argument-hint: "[target month, e.g. '2026-03'] [client name]"
disable-model-invocation: true
---

# Invoice Draft Generation

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
| `{CONTRACT_TYPE}` | Contract type (T&M / Fixed / Monthly, etc.) | `T&M` |
| `{BILLING_AMOUNT}` | Monthly billing amount (before tax) | `$10,000` |
| `{BILLING_ITEMS}` | Invoice line items | (project-specific) |
| `{BANK_INFO}` | Bank transfer details | (your bank info) |
| `{INVOICE_ISSUER}` | Issuer information (tax ID, company, representative) | (your company info) |
| `{ACCOUNTING_SYSTEM}` | Accounting system name (freee, QuickBooks, Xero, etc.) | `freee` |

---

## Execution Flow

### Step 1: Verify Billing Information

1. Read time allocation from `{COST_ALLOCATION_FILE}` for the target month
2. Calculate billing amount based on contract type:
   - **Monthly fixed**: Use `{BILLING_AMOUNT}` directly
   - **T&M (time and materials)**: Actual hours x contract rate
   - **Fixed price (milestone)**: Based on deliverable completion status
3. **Important**: Do NOT start from archives alone

### Step 2: Generate Invoice Format

```markdown
# Invoice

**Invoice Number**: INV-{PROJECT_CODE}-YYYYMM-001
**Issue Date**: YYYY-MM-DD
**Payment Due**: YYYY-MM-DD (per contract payment terms)

---

**Bill To**:
{CLIENT_NAME}

**From**:
{INVOICE_ISSUER}

---

## Line Items

| # | Description | Qty | Unit | Unit Price | Amount |
|---|-------------|-----|------|-----------|--------|
| 1 | {PROJECT_NAME} development services (YYYY-MM) | 1 | set | $XX,XXX | $XX,XXX |

| | |
|:--|--:|
| **Subtotal** | $XX,XXX |
| **Tax** | $X,XXX |
| **Total** | $XX,XXX |

---

## Payment Details

{BANK_INFO}
```

### Step 3: Generate Accounting System Input Guide

Generate step-by-step input instructions for `{ACCOUNTING_SYSTEM}`:

```markdown
## {ACCOUNTING_SYSTEM} Input Guide

### 1. Open Invoice Creation
Navigate to: Invoices -> New Invoice

### 2. Basic Information

| Field | Value |
|:--|:--|
| Invoice Number | INV-{PROJECT_CODE}-YYYYMM-001 |
| Client | {CLIENT_NAME} (select from contacts) |
| Issue Date | YYYY/MM/DD |
| Payment Due | YYYY/MM/DD |

### 3. Line Items

| Line | Description | Qty | Unit | Unit Price | Tax |
|------|-------------|-----|------|-----------|-----|
| 1 | {PROJECT_NAME} development services (YYYY-MM) | 1 | set | XX,XXX | Standard rate |

### 4. Payment Details Verification
- Confirm bank details match `{BANK_INFO}`
- Check default payment account settings

### 5. Preview Check
- Tax ID / Business number is displayed
- Tax calculation is correct
- Payment details are correct
```

### Step 4: Final Checklist

```markdown
## Final Checklist

- [ ] Client name matches the official legal name
- [ ] Billing amount matches the contract / purchase order
- [ ] Tax rate is correct
- [ ] Tax ID / Business registration number is present
- [ ] Payment details are correct
- [ ] Payment due date matches contract terms
- [ ] Invoice number is not duplicated
- [ ] Time allocation actuals align with billing
- [ ] Previous month's invoice has been paid
- [ ] Invoice is saved as DRAFT only (not sent)
```

### Step 5: Save

1. Save invoice info to `{PM_DIR}/invoices/invoice_YYYYMM_{CLIENT_NAME}.md`
2. Save accounting system guide to the same directory

---

## Rules

- **Never send emails** (drafts only)
- **Never include cost/rate/margin information**: Invoice shows contracted billing amounts only
- **All timestamps should use the project's local timezone**
- **Always get user confirmation before writing to external services**: Save invoice as draft only
- **Do NOT start from archives alone** — fetch latest data first
- **Accounting system invoices are DRAFT only**: Final review and sending is done manually by the user
