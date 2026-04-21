---
name: site-update
description: Business-user-friendly site update — translate natural-language requirements into code changes, auto-test, auto-repair, then preview
argument-hint: "[natural-language description of what to change]"
---

# Site Update Workflow

Translate a non-engineer user's natural-language requirement into code changes for a static site (Nuxt / Next / Astro / Vite / Hugo / Jekyll), then run an automatic test → repair → preview loop.

## Configuration

Define in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{SITE_NAME}` | Site display name | `MyOrg Official Site` |
| `{LOCAL_DEV_URL}` | Local development URL | `http://localhost:3000/` |
| `{BASE_URL_PATH}` | GitHub Pages base path (if any) | `/my-site/` |
| `{DEV_CMD}` | Dev server command | `npm run dev` |
| `{TEST_CMD}` | Test command (fast, screen-only) | `npx playwright test --grep-invert "build"` |
| `{TEST_FULL_CMD}` | Test command (full, includes build) | `npx playwright test` |
| `{PAGES_MAP}` | Page-to-file mapping table | (see below) |
| `{TEST_FILE}` | Path to E2E test spec | `e2e/site.spec.ts` |
| `{DESIGN_TOKENS}` | Brand color / token hints | `primary, secondary, accent` |
| `{PROTECTED_PATHS}` | Files Claude must not edit | `nuxt.config.ts:baseURL`, `public/data/*.auto.json` |

### Pages Map Template (`{PAGES_MAP}`)

```markdown
| Change target | File |
|:---|:---|
| Top page (hero, stats, CTA)   | `pages/index.vue` |
| Navigation / footer           | `layouts/default.vue` |
| About / mission / history     | `pages/about.vue` |
| Contact                       | `pages/contact.vue` |
| News index                    | `pages/news/index.vue` |
| Privacy policy                | `pages/privacy.vue` |
| CMS / dynamic data            | `public/data/cms-data.json` |
| Global CSS / animations       | `assets/css/main.css` |
| Tailwind tokens               | `tailwind.config.ts` |
| E2E tests                     | `{TEST_FILE}` |
```

---

## Steps

### Step 0: Sync With Remote (Conflict Prevention)

> **Important: Pull other contributors' changes before working.**

```bash
git remote -v
```

Identify the matching GitHub account from your `CLAUDE.md` account map (see `~/.claude/CLAUDE.md`). If the repo isn't in the map, ask the user.

```bash
GH_TOKEN=$(gh auth token --user <account>) git pull --rebase origin main 2>&1
```

Branches:

- **Clean pull** → proceed to Step 1
- **Local uncommitted changes** → auto-stash:
  ```bash
  git stash
  GH_TOKEN=$(gh auth token --user <account>) git pull --rebase origin main 2>&1
  git stash pop 2>&1
  ```
- **Conflict** →
  1. `git rebase --abort && git stash pop` to restore
  2. Tell the user: "Someone else changed the same area, so I couldn't auto-merge. Please tell me what you wanted to change so I can adapt."
  3. Stop here

**To the user**: only show "Checking for the latest version…". Hide the git internals.

### Step 1: Understand the Requirement

User input: `$ARGUMENTS`

Extract:
- Which page / section is being changed
- What kind of change (text / image / layout / color / link)
- Likely impact area

### Step 2: Inspect Current State

Open the relevant files using the `{PAGES_MAP}` and confirm the current contents.

### Step 3: Apply Code Changes

Modify the relevant files. Rules:

- Keep the existing component / SFC style (e.g., `<script setup lang="ts">` for Vue, function components for React)
- Prefer existing utility classes (Tailwind / CSS modules) over new CSS
- Use only design tokens listed in `{DESIGN_TOKENS}` for colors / spacing
- Preserve responsive (mobile) layout
- Reflect copy / Japanese text **exactly** as the user provided
- **Do not edit anything in `{PROTECTED_PATHS}`**

Update `{TEST_FILE}` accordingly:
- New section added → assert it renders
- Text changed → assert the new text appears
- Page added → add to the pages list test

### Step 4: Auto-Test (TDD Loop)

```bash
{TEST_CMD}
```

Run the loop **silently** (don't show the user raw test output):

- All pass → Step 5
- Failure → analyze, fix, re-run, up to 3 iterations
- After 3 failed iterations → escalate to the user with a summary

To the user: just show "Running tests…" / "Applying fixes…" status updates.

### Step 5: Local Preview

After tests pass, prompt the user:

- Open `{LOCAL_DEV_URL}{BASE_URL_PATH}` in your browser to verify
- Reply "OK" to proceed, or describe any further changes

(Dev server should already be running because `{TEST_CMD}` started it; if not, start `{DEV_CMD}` in the background.)

### Step 6: Confirm

- **OK** → tell the user: "You can publish with `/site-publish`"
- **More changes requested** → return to Step 3

## Rules

- Do not edit anything in `{PROTECTED_PATHS}`
- Auto-generated data files (e.g., RSS-fetched JSON) are off-limits — note in `{PROTECTED_PATHS}`
- Place new images under the project's `public/` (or equivalent static) directory
- Keep test files under the directory containing `{TEST_FILE}`
- Speak to the user in their language and avoid Git / build jargon — say "saving changes" instead of "commit", "publishing" instead of "push"
