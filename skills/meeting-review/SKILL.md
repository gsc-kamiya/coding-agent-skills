---
name: meeting-review
description: Analyze meeting minutes to detect spec changes and decisions, then batch-update GitHub Issues and documentation
argument-hint: "[meeting notes file path or URL]"
disable-model-invocation: true
---

# Meeting Minutes -> Issue Triage & Documentation Update

Parse meeting minutes (text/transcription/AI notes) to detect spec changes and new decisions,
then batch-update GitHub Issues, Wiki, and documentation.

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{PROJECT_NAME}` | Project name | `MyProject` |
| `{GITHUB_REPO}` | GitHub repository (org/repo) | `my-org/my-repo` |
| `{MEETING_DECISIONS_PATH}` | Path to meeting decisions summary file | `docs/decisions.md` |
| `{WIKI_PAGES}` | Wiki pages to potentially update | `Architecture, API-Spec` |
| `{SLACK_CHANNELS}` | Related Slack channels | `#project-dev: C012345` |
| `{MILESTONE_MAP}` | Milestone name -> ID mapping | `Phase1: 1, Phase2: 2` |

---

## Execution Steps

### Step 1: Read & Parse Meeting Minutes

1. Read the meeting notes specified by argument
   - Local file (.md/.txt) -> Read tool
   - Google Docs URL -> Google Workspace MCP
   - Meeting recording AI notes URL -> Google Workspace MCP
2. If no notes available, infer content from recent Slack/Chat messages

### Step 2: Extract Decisions & Spec Changes

Extract and classify the following from meeting minutes:

#### A. Spec Changes
- Existing functionality with changed specifications
- New requirements or constraints added
- Scope changes (additions/removals)

#### B. New Tasks
- Newly created action items
- Work not covered by existing Issues

#### C. Status Updates
- Tasks reported as complete
- Blockers resolved or created
- Assignee changes

#### D. Confirmations
- Existing specs that were reconfirmed
- Previously ambiguous points that were clarified

### Step 3: Cross-Reference with Existing Issues/Docs

1. **GitHub Issues**: Fetch all open issues and match with Step 2 items
   ```bash
   gh issue list --repo {GITHUB_REPO} --state open --json number,title,body,assignees,labels,milestone --limit 50
   ```
2. **Meeting decisions doc**: Read `{MEETING_DECISIONS_PATH}` and check consistency with existing decisions
3. **Wiki**: Identify Wiki pages that need updates

### Step 4: Generate Diff Report & Get User Confirmation

Present the following diff report to the user for approval before making changes:

```markdown
## Meeting Analysis Results — Update Diff Report

### Spec Changes (Issue Updates)
| # | Issue | Change | Impact |
|---|-------|--------|--------|
| 1 | #XX: Title | Before -> After | Related: #YY, #ZZ |

### New Issues to Create
| # | Title | Labels | Milestone | Assignee |
|---|-------|--------|-----------|----------|

### Status Updates
| # | Issue | Change | Notes |
|---|-------|--------|-------|

### Documentation Updates
| # | File | Update Content |
|---|------|---------------|

### Confirmations (No Updates Needed — Record Only)
| # | Content | Notes |
|---|---------|-------|
```

**Ask user**: "Shall I proceed with the above updates? Please let me know if any modifications are needed."

### Step 5: Update GitHub Issues

After user confirmation:

#### 5a. Update Existing Issues
- Update Issue body with new spec details
- Add/change labels (apply `spec-changed` label for spec changes)
- Change milestone (if schedule changed)
- Add comment ("YYYY-MM-DD meeting: spec changed — {change details}")

```bash
gh issue edit {NUMBER} --repo {GITHUB_REPO} --body "..." --add-label "spec-changed"
gh issue comment {NUMBER} --repo {GITHUB_REPO} --body "..."
```

#### 5b. Create New Issues
```bash
gh issue create --repo {GITHUB_REPO} \
  --title "..." --body "..." \
  --label "..." --assignee "..." --milestone "..."
```

#### 5c. Close Issues
- Close issues decided as "not needed" or "out of scope" (with comment)
```bash
gh issue close {NUMBER} --repo {GITHUB_REPO} --comment "YYYY-MM-DD meeting: decided out of scope"
```

### Step 6: Update Documentation

#### 6a. Meeting Decisions Summary
Append new decisions to `{MEETING_DECISIONS_PATH}`:
- Date, meeting type
- Decisions (numbered)
- Affected Issue numbers

#### 6b. Wiki Updates
Update Wiki pages affected by spec changes.
**Note**: Wiki cannot be directly edited via `gh` CLI. Present update content to the user and request manual updates.

#### 6c. Save Meeting Notes
- Save as `docs/meetings/YYYY-MM-DD_{type}/YYYY-MM-DD_meeting_notes.md`
- Skip if already exists

### Step 7: Output Summary

```markdown
## Meeting Review Complete

### Results
| Item | Count |
|------|-------|
| Issues updated | X |
| New issues | X |
| Issues closed | X |
| Docs updated | X |

### Updated Issues
- #XX: {Title} — {Update details}

### Manual Actions Required
- [ ] Update Wiki "{page name}": {update content}
- [ ] {Other manual actions}
```

---

## Rules

- **Always get user confirmation before making changes** (Step 4)
- **Add change history comments to Issues with spec changes**
- **Never include cost/rate/margin information**
- **Never send emails**
- **Get individual confirmation for destructive operations** (Issue close)
