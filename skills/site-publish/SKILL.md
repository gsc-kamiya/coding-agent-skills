---
name: site-publish
description: Publish local changes to the production site (GitHub Pages or similar) with mandatory tests, conflict prevention, and business-friendly status updates
argument-hint: "(no arguments)"
---

# Site Publish Workflow

Publish local changes safely: full test pass → pull-with-rebase to absorb teammates' changes → confirm with user → commit → push → monitor deploy.

## Configuration

Define in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{TEST_FULL_CMD}` | Full test command (must include build) | `npx playwright test` |
| `{DEPLOY_BRANCH}` | Branch that triggers production deploy | `main` |
| `{DEPLOY_WAIT_HINT}` | Approximate deploy time to tell the user | `2-3 minutes` |

---

## Steps

### Step 1: Full Test (Quality Gate)

```bash
{TEST_FULL_CMD}
```

Silent loop, with auto-repair on failure (max 3 attempts).

> **Important: Never proceed to publish unless every test passes.**

If repair fails, escalate to the user with a summary and **stop**.

### Step 2: Sync With Remote (Conflict Prevention)

```bash
git remote -v
```

Identify the matching account from the user's `~/.claude/CLAUDE.md` account map.

Stash local changes, pull, restore:

```bash
git stash
GH_TOKEN=$(gh auth token --user <account>) git pull --rebase origin {DEPLOY_BRANCH} 2>&1
git stash pop 2>&1
```

(If there are no local changes, skip the stash.)

**Conflict:**
1. `git rebase --abort && git stash pop` to restore
2. Tell the user: "Someone else updated the same area recently. I can't auto-merge — please tell me which version to keep."
3. **Stop publishing.** Never force-push.

**No conflict:** re-run `{TEST_FULL_CMD}` once more after the rebase. If it now fails, auto-repair (max 3); if it still fails, stop and report.

To the user: only show "Checking for other updates…".

### Step 3: Show the Diff

```bash
git status
git diff
```

Summarize the change in business language: **what** changed (homepage headline, news entry added, etc.), not file diffs. Confirm tests passed: "All quality checks passed."

### Step 4: Final Confirmation

Ask the user:

- Have you confirmed the change in the local preview?
- Are you OK to publish this to the live site?

Proceed only on a clear yes.

### Step 5: Commit & Push

Choose a commit prefix that matches the change type:

- New feature: `feat: add ...`
- Update existing: `update: change ...`
- Copy / content: `content: revise ...`
- Visual / design: `style: redesign ...`
- Bug fix: `fix: ...`

```bash
git add -A
git commit -m "<prefix>: <short description>"
GH_TOKEN=$(gh auth token --user <account>) git push origin {DEPLOY_BRANCH} 2>&1
```

**If push is rejected (someone else pushed simultaneously):**
1. Pull again with rebase
2. If clean, push again
3. If conflict, `git rebase --abort` and tell the user: "Someone else published right at the same moment. Please run `/site-publish` again."

To the user: only show "Publishing to the live site…".

### Step 6: Verify Deploy

```bash
GH_TOKEN=$(gh auth token --user <account>) gh run list --limit 1
```

Tell the user:
- Publishing started — the live site should reflect the change in about `{DEPLOY_WAIT_HINT}`
- Refresh the live site after that to verify

## Rules

- **Never publish if tests are failing** — no exceptions
- **Never force-push** — data loss risk
- Translate Git terms before showing them to non-engineers:
  - commit → "saving the change"
  - push → "publishing"
  - pull → "fetching the latest"
  - conflict → "overlapping change with another person"
