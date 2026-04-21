---
name: fix-pr-review
description: Fix PR review feedback (human reviews + CI), commit, push, and loop until all checks pass and all comments are addressed.
user-invocable: true
---

# PR Review Fix — CI/TDD Completion Loop

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{GITHUB_REPO}` | GitHub repository (org/repo) | `my-org/my-repo` |
| `{GH_USER}` | Your GitHub username (to filter own comments) | `my-github-user` |
| `{CI_BOT_USER}` | GitHub username of CI bot | `github-actions[bot]` |
| `{LINT_FIX_CMD}` | Auto-fix command for linting | `docker compose exec -T app vendor/bin/phpcbf {files}` |
| `{LINT_CHECK_CMD}` | Lint check command | `docker compose exec -T app vendor/bin/phpcs {files}` |
| `{STATIC_ANALYSIS_BASELINE}` | Baseline file for static analysis (optional) | `phpstan-baseline.php` |
| `{TEST_CMD}` | Test execution command | `docker compose exec -T app vendor/bin/phpunit` |

---

## Overview
Fix both human review comments and CI issues (linting/static analysis) on a GitHub PR. Commit -> push -> wait for CI -> run tests -> reply to comments. Loop until everything is resolved.

## Arguments
- `PR_NUMBER`: Target PR number (required)
- Reviewer names are auto-detected from comments

## Workflow

### Phase 1: Collect and Classify Issues

#### 1-1. Fetch Human Review Comments
```bash


# PR conversation comments (issue comments)
gh api repos/{GITHUB_REPO}/issues/{PR_NUMBER}/comments \
  --jq '.[] | select(.user.login != "{GH_USER}" and .user.login != "{CI_BOT_USER}") | {id, user: .user.login, body, created_at}'

# PR review comments (inline comments)
gh api repos/{GITHUB_REPO}/pulls/{PR_NUMBER}/comments \
  --jq '.[] | select(.user.login != "{GH_USER}" and .user.login != "{CI_BOT_USER}") | {id, user: .user.login, path, line, body, created_at}'

# PR review bodies
gh api repos/{GITHUB_REPO}/pulls/{PR_NUMBER}/reviews \
  --jq '.[] | select(.user.login != "{GH_USER}" and .user.login != "{CI_BOT_USER}" and .body != "") | {id, user: .user.login, state, body}'
```

#### 1-2. Fetch CI Issues (reviewdog)
```bash
# Unreplied CI bot comments
gh api repos/{GITHUB_REPO}/pulls/{PR_NUMBER}/comments --paginate --jq '
  [.[] | select(.user.login == "{CI_BOT_USER}") | .id] as $review_ids |
  [.[] | select(.in_reply_to_id != null) | .in_reply_to_id] as $replied_ids |
  .[] | select(.user.login == "{CI_BOT_USER}") | select(.id | IN($replied_ids[]) | not) |
  {id, path, line, body: (.body | split("\n")[0:3] | join(" "))}'
```

#### 1-3. Check CI Status
```bash
gh pr checks {PR_NUMBER} --repo {GITHUB_REPO}
gh run list --repo {GITHUB_REPO} --branch {branch} --limit 1 --json databaseId,status,conclusion
```

### Phase 2: Apply Fixes

#### 2-1. Fix Human Review Comments
- Read each comment and modify the relevant file
- Follow SOLID principles and existing coding conventions
- Accurately understand the reviewer's intent and fix without over- or under-correction

#### 2-2. Fix Linting Errors
1. **Auto-fix**:
   ```bash
   {LINT_FIX_CMD}
   ```
2. **Manual fix** (what auto-fix cannot handle):
   - Rename to match naming conventions
   - Reformat multi-line expressions
   - Add ignore/disable annotations

#### 2-3. Fix Static Analysis Errors
1. **Add type annotations**
2. **For bulk issues**: Add entries to `{STATIC_ANALYSIS_BASELINE}` (use consistent indentation)

### Phase 3: Run Tests

#### 3-1. Unit Tests
```bash
{TEST_CMD}
```

#### 3-2. Lint Check
```bash
{LINT_CHECK_CMD}
```

### Phase 4: Commit & Push

```bash
git add {modified_files}
git commit -m "$(cat <<'EOF'
fix: address review feedback — {summary}

{details}

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
git push origin {branch}
```

### Phase 5: Wait for CI

```bash

gh run list --repo {GITHUB_REPO} --branch {branch} --limit 1 --json databaseId,status,conclusion
gh run watch {run_id} --repo {GITHUB_REPO} --exit-status
```

### Phase 6: Reply to Comments

#### Human Review Replies
```bash
# Reply to PR review comments
gh api repos/{GITHUB_REPO}/pulls/{PR_NUMBER}/comments/{COMMENT_ID}/replies \
  -X POST -f body="Fixed in {commit_hash}. {description}"

# Reply to PR conversation comments
gh api repos/{GITHUB_REPO}/issues/{PR_NUMBER}/comments \
  -X POST -f body="@{reviewer} Thank you for the feedback. Fixed in {commit_hash}. {description}"
```

#### CI Comment Replies
```bash
gh api repos/{GITHUB_REPO}/pulls/{PR_NUMBER}/comments/{COMMENT_ID}/replies \
  -X POST -f body="Fixed in {commit_hash}. {description}"
```

### Phase 7: Loop Check

Return to Phase 1 until ALL of the following are satisfied:
1. **CI passes**: All checks are `pass`
2. **Zero unaddressed comments**: All reviewdog + human review comments have replies
3. **Tests pass**: All unit tests pass

## Notes
- If using multiple GitHub accounts, set `GH_TOKEN` environment variable before running `gh` commands
- **If your primary account has GitHub Actions disabled/limited** (spending limits, org-level restrictions, etc.), use a separate account with Actions enabled for CI-triggering pushes:
  ```bash
  cd <repo>
  git config user.email "<actions-account-email>"
  git config user.name "<actions-account-name>"
  GH_TOKEN=$(gh auth token --user <actions-account>) git push
  ```
  The specific account mapping is personal — check your `~/.claude/CLAUDE.md` for project-specific conventions.
- When adding to a static analysis baseline, use consistent indentation (e.g., **4 spaces**)
- Append `Co-Authored-By` to commit messages
- Reply politely to human reviewers (e.g., "Thank you for the feedback")
- If the fix intent is unclear, ask the user for clarification
