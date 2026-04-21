---
name: site-preview
description: Sync with remote, run E2E tests with auto-repair, then open local preview URLs for the user
argument-hint: "(no arguments)"
---

# Site Preview Workflow

Pull the latest, run the auto-test → repair loop, and present preview URLs.

## Configuration

Define in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{LOCAL_DEV_URL}` | Local dev URL | `http://localhost:3000/` |
| `{BASE_URL_PATH}` | GitHub Pages base path (if any) | `/my-site/` |
| `{DEV_CMD}` | Dev server command | `npm run dev` |
| `{TEST_CMD}` | Fast E2E test command | `npx playwright test --grep-invert "build"` |
| `{PREVIEW_PAGES}` | Main pages to preview (label → path) | `Top: /, About: /about` |

---

## Steps

### Step 0: Sync With Remote

```bash
git remote -v
```

Identify the matching account from the user's `~/.claude/CLAUDE.md` account map. If the repo isn't in the map, ask.

Check for local changes:
```bash
git status --short
```

**Without local changes:**
```bash
GH_TOKEN=$(gh auth token --user <account>) git pull --rebase origin main 2>&1
```

**With local changes (auto-stash):**
```bash
git stash
GH_TOKEN=$(gh auth token --user <account>) git pull --rebase origin main 2>&1
git stash pop 2>&1
```

**Conflict:**
1. `git rebase --abort && git stash pop` to restore
2. Tell the user: "Someone else updated the same area. You can publish your current changes with `/site-publish`, or describe what you want to keep so I can merge."
3. Continue with preview using the local state

To the user: just show "Checking for the latest version…".

### Step 1: Show Current Changes

```bash
git status
git diff --stat
```

Summarize any changes for the user **in business language** — e.g. "You're updating the homepage hero image", not "diff in `pages/index.vue`".

### Step 2: Auto-Test

```bash
{TEST_CMD}
```

Run silently. On failure, auto-repair (max 3 attempts), then proceed.

### Step 3: Tell the User What to Open

Brief summary, then list preview URLs:

- Open `{LOCAL_DEV_URL}{BASE_URL_PATH}` in your browser
- Main pages (from `{PREVIEW_PAGES}`):
  - Top: `{LOCAL_DEV_URL}{BASE_URL_PATH}`
  - …
- Stop the dev server with `Ctrl+C` when done

(If the dev server isn't already running, start `{DEV_CMD}` in the background.)
