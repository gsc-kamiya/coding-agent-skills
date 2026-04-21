---
name: fix-pr-ci
description: Auto-fix CI issues (linting/static analysis) on a PR, commit, push, and loop until all checks pass.
user-invocable: true
---

# PR CI Auto-Fix Workflow

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{GITHUB_REPO}` | GitHub repository (org/repo) | `my-org/my-repo` |
| `{CI_BOT_USER}` | GitHub username of CI bot (reviewdog, etc.) | `github-actions[bot]` |
| `{LINT_FIX_CMD}` | Auto-fix command for linting | `docker compose exec -T app vendor/bin/phpcbf --standard=PSR12 {files}` |
| `{LINT_CHECK_CMD}` | Lint check command | `docker compose exec -T app vendor/bin/phpcs --standard=PSR12 {files}` |
| `{STATIC_ANALYSIS_CMD}` | Static analysis command (optional) | `docker compose exec -T app vendor/bin/phpstan analyse {files}` |
| `{STATIC_ANALYSIS_BASELINE}` | Baseline file for static analysis (optional) | `phpstan-baseline.php` |
| `{TEST_CMD}` | Test execution command | `docker compose exec -T app vendor/bin/phpunit` |

---

## Overview

Automatically fix CI issues (linting/static analysis reviewdog comments) on a GitHub PR by: fix -> commit -> push -> wait for CI -> reply to comments. Loop until all checks pass.

## Arguments
- `PR_URL` or `PR_NUMBER`: Target PR URL or number (defaults to the current branch's PR)

## Workflow

### Step 1: Fetch Unresolved CI Comments
```bash

# Get unreplied CI bot comments
gh api repos/{GITHUB_REPO}/pulls/{PR_NUMBER}/comments --jq '
  [.[] | select(.user.login == "{CI_BOT_USER}") | .id] as $review_ids |
  [.[] | select(.in_reply_to_id != null) | .in_reply_to_id] as $replied_ids |
  .[] | select(.user.login == "{CI_BOT_USER}") | select(.id | IN($replied_ids[]) | not) |
  {id, path, line, body}
'
```

### Step 2: Fix Linting Errors
1. **Try auto-fix first**:
   ```bash
   {LINT_FIX_CMD}
   ```
2. **Manually fix what auto-fix cannot handle**:
   - Add ignore/disable annotations
   - Rename to match naming conventions
   - Reformat multi-line expressions

### Step 3: Fix Static Analysis Errors
1. **Add type annotations** (PHPDoc, JSDoc, TypeScript types, etc.)
2. **For bulk issues**: Add entries to `{STATIC_ANALYSIS_BASELINE}` if configured
   - Ensure consistent indentation (spaces, not tabs) to avoid linting issues on new entries

### Step 4: Run Tests
```bash
{TEST_CMD}
```

### Step 5: Commit & Push
```bash
git add {modified_files}
git commit -m "fix: CI auto-fix — {summary}"
git push origin {branch}
```

### Step 6: Wait for CI
```bash

gh run list --repo {GITHUB_REPO} --branch {branch} --limit 1 --json databaseId,status
gh run watch {run_id} --repo {GITHUB_REPO} --exit-status
```

### Step 7: Reply to CI Comments
```bash

gh api repos/{GITHUB_REPO}/pulls/{PR_NUMBER}/comments/{COMMENT_ID}/replies -X POST -f body="Fixed in {commit_hash}. {description}"
```

### Step 8: Loop Check
- CI success (conclusion == "success") -> Done
- CI failure -> Return to Step 1

## Notes
- When adding entries to a static analysis baseline, use consistent indentation (e.g., 4 spaces) to avoid triggering lint errors
- If lint ignore annotations don't work, try disable/enable block wrappers
- If using multiple GitHub accounts, set `GH_TOKEN` environment variable before running `gh` commands
- **If your primary account has GitHub Actions disabled/limited** (spending limits, org-level restrictions, etc.), use a separate account with Actions enabled for CI-triggering pushes:
  ```bash
  cd <repo>
  git config user.email "<actions-account-email>"
  git config user.name "<actions-account-name>"
  GH_TOKEN=$(gh auth token --user <actions-account>) git push
  GH_TOKEN=$(gh auth token --user <actions-account>) gh run list ...
  ```
  The specific account mapping is personal — check your `~/.claude/CLAUDE.md` for project-specific conventions.
- Append `Co-Authored-By: Claude <noreply@anthropic.com>` to commit messages
