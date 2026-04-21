# CLAUDE.md — Project Configuration for Claude Code

> Replace `{...}` placeholders with your project's actual values, then drop this file at your repo root.
>
> The same content can be duplicated into `AGENTS.md` (for Codex) and `GEMINI.md` (for Gemini CLI).

## Project Overview

`{SITE_NAME}`. Built with `{FRAMEWORK}` ({STACK_DETAIL}).
Deployed to `{HOSTING}` (`baseURL: {BASE_URL_PATH}`).

## Tech Stack

- **Framework**: `{FRAMEWORK}`
- **Styling**: `{STYLING}` (e.g., Tailwind CSS)
- **Hosting**: `{HOSTING}` (e.g., GitHub Pages, static)
- **CI/CD**: GitHub Actions (`.github/workflows/{WORKFLOW_FILE}`)
- **External data**: `{EXTERNAL_DATA_SOURCES}` (e.g., RSS → JSON, headless CMS)
- **E2E tests**: `{TEST_FRAMEWORK}` (e.g., Playwright)

## Directory Layout

```
pages/          # Routes
layouts/        # Shared layouts
composables/    # Composables / hooks
assets/         # CSS, fonts, etc.
public/         # Static assets (images, JSON)
scripts/        # Build / data-fetch scripts
e2e/            # E2E tests
docs/           # Documentation
```

(Adjust to match your framework's conventions.)

## Common Commands

```bash
{DEV_CMD}       # Dev server
{BUILD_CMD}     # Build / generate static
{PREVIEW_CMD}   # Preview build output
{TEST_CMD}      # Run tests
```

## Testing Policy

Always run `{TEST_CMD}` after a code change and confirm everything passes before committing or pushing.
Update `{TEST_FILE}` to cover new behavior.

## Coding Conventions

- Language: `{CONTENT_LANG}` (e.g., Japanese)
- Component style: `{COMPONENT_STYLE}` (e.g., `<script setup lang="ts">`, function components)
- Prefer utility classes over custom CSS where the framework supports it
- Color tokens / design tokens: see `{DESIGN_TOKENS_FILE}` (e.g., `tailwind.config.ts`)

## Deploy

- Push to `{DEPLOY_BRANCH}` triggers automatic deploy via the GitHub Actions workflow above
- Optional daily scheduled rebuild for sites that fetch external data
- Manual run available via `workflow_dispatch`

## Protected Paths (Never Edit)

- `{PROTECTED_PATHS}` (e.g., `nuxt.config.ts:baseURL`, `public/data/*.auto.json`)

## Coding-Agent Skill Configuration

These placeholders are consumed by the `claude-skills` workflows
(`/site-update`, `/site-preview`, `/site-publish`, `/agent-setup`, `/agent-setup-check`):

- `{SITE_NAME}`
- `{LOCAL_DEV_URL}` (e.g., `http://localhost:3000/`)
- `{BASE_URL_PATH}` (e.g., `/my-site/`)
- `{DEV_CMD}` / `{TEST_CMD}` / `{TEST_FULL_CMD}` / `{BUILD_CMD}`
- `{PAGES_MAP}` (page → file mapping)
- `{TEST_FILE}`
- `{DESIGN_TOKENS}`
- `{PROTECTED_PATHS}`
- `{DEPLOY_BRANCH}` / `{DEPLOY_WAIT_HINT}`
- `{INSTALL_AGENTS}` / `{NODE_MIN_VERSION}` / `{POST_SETUP_HINT}` / `{REPAIR_HINT}`
