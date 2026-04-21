---
name: ball-check
description: "Cross-platform action item tracking — scan Slack, Google Chat, GitHub Issues, email, and ticket systems to identify who owns what and what's overdue"
argument-hint: "[time period, e.g. 'last week' or '2026-03-01 to 2026-03-07']"
disable-model-invocation: true
---

# Action Item Tracking & Ownership Analysis

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{PROJECT_NAME}` | Project name | `MyProject` |
| `{SLACK_CHANNELS}` | Target Slack channels (name -> ID) | `#dev: C012345` |
| `{SLACK_USERS_INTERNAL}` | Internal team (name -> ID -> role) | (project-specific) |
| `{SLACK_USERS_EXTERNAL}` | External partners (name -> ID -> org -> role) | (project-specific) |
| `{PM_DIR}` | Project management directory | `docs/pm` |
| `{DESIGN_DIR}` | Design documents directory | `docs/design` |
| `{SLACK_WORKSPACE}` | Slack workspace subdomain (for links) | `my-workspace` |

### Optional (Enable Per-Project)

| Variable | Description | When to Enable |
|:--|:--|:--|
| `{GCHAT_SPACES}` | Google Chat spaces (name -> ID) | If using Google Chat |
| `{GITHUB_REPO}` | GitHub repository (org/repo) | If using GitHub Issues |
| `{GH_USER}` | GitHub username | If using GitHub Issues |
| `{TICKET_PROJECT}` | Ticket system project key/ID (Backlog, Jira, etc.) | If using external ticket system |
| `{GMAIL_SEARCH_QUERY}` | Gmail search query for project emails | If tracking email threads |
| `{DEBUG_SHEET_ID}` | Google Drive spreadsheet ID for shared tracking | If using shared debug/tracking sheets |

---

## Execution Flow

### Step 1: Load Previous Action Item List (Archive)

1. Read the latest action item list from `{PM_DIR}/action-items/`
2. **Important**: Do NOT work from the archive alone. Always fetch fresh data in Step 2+ before analyzing.

### Step 2: Read All Slack Channel Threads (Pagination Required)

Fetch all messages from `{SLACK_CHANNELS}` for the target period.

#### Pagination (Strictly Required)

> **Strictly Required**: `slack_read_channel` returns a maximum of 100 messages per request.
> If `pagination_info` contains `next_cursor`, you **must** fetch the next page using the `cursor` parameter.
> Repeat until "There are no more messages available."
>
> **Skipping pagination creates time gaps in message coverage, causing missed action items.**

#### Time Range Completeness Check

After fetching, verify:
1. Oldest message timestamp is near the `oldest` parameter
2. Newest message timestamp is near the current time
3. No unnatural time gaps (e.g., 3 days with no messages)
4. If gaps exist, fetch that period specifically with `oldest`/`latest` parameters

#### Thread Reading Rules (Strictly Required)

1. Use **`slack_read_channel`** to get posts (with pagination)
2. For any post with `reply_count >= 1`, **always** read the full thread with `slack_read_thread`
3. **No summaries or abbreviations**: Read every message in full
4. Use **`response_format: "detailed"`** to get reaction data

#### Reaction Interpretation Table

Slack reactions carry meaning for action item tracking:

| Reaction | Meaning | Action Item Impact |
|:--|:--|:--|
| :white_check_mark: / :heavy_check_mark: | Done / Addressed | Item resolved |
| :eyes: | Looking into it | Item held (in progress) |
| :raised_hands: / :pray: | Thanks / Acknowledged | Noted as received |
| :+1: / :thumbsup: | Approved / Agreed | Approval complete (move to next action) |
| :-1: / :thumbsdown: | Rejected / Needs revision | Item bounced back |
| :warning: | Caution / Risk | Flag for attention |
| :question: / :thinking_face: | Question / Considering | Response-pending item created |
| :rocket: | Started / Launched | Item held (work in progress) |
| :hourglass: / :hourglass_flowing_sand: | Waiting | External dependency wait |
| :no_entry: / :x: | Blocked / Not possible | Blocker identified |
| :memo: | Note / Record | Information sharing only |
| :tada: / :clap: | Celebration / Praise | Completion acknowledged |
| (No reaction) | Unacknowledged | **Most dangerous**: May be unseen. Flag for verification. |

### Step 2.5: Fetch Google Chat History (If `{GCHAT_SPACES}` Is Set)

Fetch all Google Chat space messages for the target period.

#### Fetch Rules
1. Use a high message limit (e.g., 500) to ensure recent messages are captured
2. Filter to target period
3. Execute for all configured spaces
4. Thread replies are part of the analysis — check parent-child message relationships

### Step 2.7: Check Gmail (If `{GMAIL_SEARCH_QUERY}` Is Set)

1. Search Gmail with `{GMAIL_SEARCH_QUERY} after:YYYY/MM/DD`
2. Read email content for each result
3. Check for:
   - Unanswered requests or questions directed at your team
   - Whether already handled via Slack/Chat/GitHub
4. Add email-sourced items alongside other action items
5. **Never send emails** (drafts only)

### Step 3: Fetch GitHub Issues (If `{GITHUB_REPO}` Is Set)

1. Get open Issues by milestone
2. Check assignees, labels, milestones, due dates
3. Cross-reference Slack discussions with GitHub Issues

```bash
GH_TOKEN=$(gh auth token --user {GH_USER}) gh issue list --repo {GITHUB_REPO} --state open --json number,title,assignees,labels,milestone --limit 50
```

### Step 3.5: Fetch Tickets + All Comments (If `{TICKET_PROJECT}` Is Set)

> **Strictly Required**: Fetch not just the ticket list, but **all open ticket comments** as well.
> Ticket system threads (requests, permission grants, status changes, assignment changes) are invisible from Slack alone.
> Skipping comment retrieval causes missed action items (e.g., unanswered permission requests, pending approvals).

1. Fetch tickets (status: Open, In Progress, In Review)
2. For all open tickets, fetch the 5 most recent comments (batch 5-7 tickets in parallel)
   - **Tickets with zero comments are also notable** — indicates potentially abandoned items
3. Check assignees, due dates, priorities, comment content
4. Cross-reference with Slack discussions
5. **Include unanswered requests/questions from ticket comments as action items**

### Step 3.7: Check Shared Tracking Sheet (If `{DEBUG_SHEET_ID}` Is Set)

Extract unresolved items assigned to your team from a shared Google Drive spreadsheet.

### Step 4: Action Item Analysis

#### Ownership Rules

1. **Explicit request**: "Please do X" / "Can you handle X" -> Requestee owns it
2. **Question**: "Is this X?" / "What should we do?" -> Person asked owns it
3. **Proposal**: "How about X?" -> Decision-maker owns it
4. **Report**: "X is done" / "Completed X" -> Item resolved (unless next action exists)
5. **Reaction only**: Interpret per the table above
6. **No reply**: Last message recipient owns it
7. **Multiple candidates**: The person with the most specific action request takes priority
8. **Counter-questions**: If a client answers AND asks a follow-up question, your team now owns that follow-up

#### Involvement Level Classification

| Level | Description | Response |
|:--|:--|:--|
| **Direct owner** | Your team member is the assignee | Immediate action needed |
| **Committed** | Your team committed to the deliverable | Deadline management needed |
| **Monitoring** | External partner owns it but impacts your deliverables | Progress check needed |
| **Awareness** | Good to know, no direct action needed | Note only |

### Step 5: Output (7-Section Structure)

#### Section 1: Executive Summary
- Total action items, blockers, items due this week
- Top 1-3 attention items

#### Section 2: Blockers & Urgent Items
- Issues blocking other work
- Overdue items
- Unacknowledged (no reaction) important messages

#### Section 3: Due This Week
- Items to address this week
- Format: Owner / Description / Deadline / Involvement Level / Source

#### Section 4: Future Items
- Items for next week and beyond
- Same format

#### Section 5: Recognition Gaps & Risks
- Items discussed in Slack but not ticketed
- Tickets with no recent Slack discussion
- Potential misalignment between team members
- Chat discussions not reflected in Slack/GitHub

#### Section 6: Resolved & Closed
- Items resolved during the target period
- Items from the previous list that disappeared (tracked)

#### Section 7: Per-Person Summary

```
### {Person Name} ({Team/Org})
- [ ] Item 1: Description [Due: YYYY-MM-DD] [Level: Direct owner]
- [ ] Item 2: Description [Due: None] [Level: Monitoring]
- [x] Done 1: Description [Completed: YYYY-MM-DD]
```

#### Cross-Reference (Within Section 5)

Detect discrepancies between messaging platforms and ticket systems:
- Decisions agreed in chat but not reflected in tickets
- Ticket statuses that don't match reality
- Tickets without due dates

### Step 6: Save Action Item List

1. Save to `{PM_DIR}/action-items/action-items_YYYY-MM-DD.md`
2. Show diff from the previous list (newly completed, newly delayed, status changes)

### Step 7: Final Re-Check (Strictly Required)

**After completing all output, perform the following:**

1. Re-scan all messages (Slack + Chat) from Steps 2-2.5 for missed items
2. Focus especially on:
   - Posts with no reactions (unacknowledged risk)
   - Action items buried in long threads
   - Vague commitments ("later," "next week," "eventually")
   - **Counter-questions embedded in client responses** (easy to miss)
   - **Items replied to in Chat** that may appear unresolved if only checking Slack
3. Update the output before saving if anything was missed

---

## Source Link Rules (Strictly Required)

Every action item must include a **direct link** to the source conversation. Items without source links are not acceptable.

### Link Formats

| Source | Format | Example |
|:--|:--|:--|
| **Slack message** | `https://{SLACK_WORKSPACE}.slack.com/archives/{channel_id}/p{timestamp}` | `[Slack](https://myworkspace.slack.com/archives/C012345/p1773631908214759)` |
| **Slack thread reply** | Above + `?thread_ts={parent_ts}&cid={channel_id}` | `[Slack thread](...)` |
| **Google Chat** | `https://chat.google.com/room/{space_id}/messages/{message_id}` | `[Chat](...)` |
| **GitHub Issue** | `https://github.com/{org}/{repo}/issues/{number}` | `[#42](https://github.com/org/repo/issues/42)` |
| **Ticket system** | `https://{domain}/view/{PROJECT}-{number}` | `[#89](https://tickets.example.com/view/PRJ-89)` |
| **Gmail** | `https://mail.google.com/mail/u/0/#all/{message_id}` | `[Gmail](...)` |

### Rules

1. **Every action item** must have a "Source" line with links in the above format
2. Multiple sources are OK (e.g., Chat discussion + GitHub Issue)
3. Use `permalink` fields from APIs when available (manual URL construction is error-prone)
4. Verify link accuracy — watch for timestamp mismatches

---

## Rules

- **Never send emails** (drafts only)
- **Never include cost/rate/margin information**
- **All timestamps should use the project's local timezone**
- **Always get user confirmation before writing to external services**
- **Do NOT start from archives alone** — fetch fresh data first
- **Never skip thread reading**: Read every message in full
- **Source links required**: Every action item must have a direct link to the source
- **Check both Slack and Chat** (if configured): One platform alone gives an incomplete picture
