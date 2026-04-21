# Claude Code Skills

A collection of reusable Claude Code skills for business workflows. These skills are designed to be **generic and configurable** -- customize them for your own company, projects, and tools via placeholder variables in your project's `CLAUDE.md`.

## Setup

### 1. Clone the Repository

```bash
cd ~/repos
git clone git@github.com:{YOUR_ORG}/claude-skills.git
```

### 2. Install Skills

```bash
cd claude-skills
./setup.sh
```

`setup.sh` replaces `~/.claude/skills/` with a symlink to this repository's `skills/` directory.
If existing skills are found, a backup (`~/.claude/skills.bak.{timestamp}`) is created first.

```
~/.claude/skills/ -> ~/repos/claude-skills/skills/
```

### 3. MCP Servers

Many skills depend on MCP (Model Context Protocol) servers. Configure them in `~/.claude.json` (global) or per-project `.claude/settings.json`.

| MCP Server | Package | Purpose | Used By |
|:--|:--|:--|:--|
| **Google Workspace** | `workspace-mcp` (uvx) | Gmail, Calendar, Chat | pre/post-meeting-proposal, invoice-draft, ball-check |
| **Slack** | Claude Code built-in | Channel/thread reading, search | ball-check, progress-check, work-report |
| **Ticket System** | `backlog-mcp-server`, Jira MCP, etc. | Ticket management | ball-check, progress-check, work-report |
| **Accounting** | `freee-mcp`, QuickBooks MCP, etc. | Invoice drafts | invoice-draft, month-end |

#### Google Workspace MCP Example (`~/.claude.json`)

```json
{
  "mcpServers": {
    "google_workspace": {
      "command": "uvx",
      "args": ["workspace-mcp"],
      "env": {
        "WORKSPACE_MCP_OAUTH_CLIENT_ID": "xxx.apps.googleusercontent.com",
        "WORKSPACE_MCP_OAUTH_CLIENT_SECRET": "xxx",
        "WORKSPACE_MCP_PORT": "0"
      }
    }
  }
}
```

> **Important**: Set `WORKSPACE_MCP_PORT` to `"0"` (auto-assign) to prevent port conflicts when running multiple Claude Code instances.

#### Slack MCP

Use Claude Code's built-in Slack MCP. Enable it from the Claude Code settings.

#### Ticket System MCP Example (Backlog)

```json
{
  "mcpServers": {
    "backlog": {
      "command": "npx",
      "args": ["-y", "backlog-mcp-server"],
      "env": {
        "BACKLOG_HOST": "xxx.backlog.com",
        "BACKLOG_API_KEY": "xxx"
      }
    }
  }
}
```

### 4. CLI Tools

| Tool | Install | Used By |
|:--|:--|:--|
| **GitHub CLI** (`gh`) | `brew install gh` | fix-pr-ci, fix-pr-review, meeting-review, ball-check |
| **Playwright** | `npm install -D @playwright/test && npx playwright install` | screen-*, screen-capture |
| **python-pptx** | `pip install python-pptx` | weekly-report |
| **google-genai** | `pip install google-genai pillow` | generate-slides, post-meeting-proposal |
| **Docker** | Docker Desktop | weekly-report, screen-tdd, screen-test |

> **Multiple GitHub accounts**: If using multiple Claude Code instances simultaneously, use `GH_TOKEN` per-terminal instead of `gh auth switch` (which affects all terminals globally):
> ```bash
> # Bad: affects other terminals
> gh auth switch --user my-account
>
> # Good: this terminal only
> export GH_TOKEN=$(gh auth token --user my-account)
> git push origin main
> ```

#### Google Workspace CLI (Optional)

Two CLI options for Google Workspace operations beyond MCP:

**Option A: `gws`** -- [Google official CLI](https://github.com/googleworkspace/cli)
```bash
npm install -g @googleworkspace/cli
gws auth setup && gws auth login
```

**Option B: `gog`** -- [Community CLI](https://github.com/steipete/gogcli)
```bash
brew install gogcli
gog auth credentials ~/Downloads/client_secret_*.json
gog auth add you@gmail.com
```

> **Tip**: MCP and CLI can be used together. Use CLI via the Bash tool when MCP doesn't cover a needed API operation.

---

## Skills (23 skills / 5 categories)

### Development Workflow (8 skills)

TDD-driven screen modification, CI auto-fix, visual comparison, slide generation, and progress reporting.

| Command | Description | Prerequisites |
|:--|:--|:--|
| `/screen-tdd` | TDD-driven screen modification (analyze -> test -> implement -> Playwright visual compare) | Docker, Playwright |
| `/screen-analyze` | Comprehensive screen implementation analysis and modification planning | -- |
| `/screen-test` | Run unit tests + Playwright visual comparison, fix differences iteratively | Docker, Playwright |
| `/screen-capture` | Capture screenshots with Playwright and visually inspect | Playwright |
| `/fix-pr-ci` | Auto-fix CI issues (linting/static analysis) on a PR -- loop until all checks pass | GitHub CLI |
| `/fix-pr-review` | Fix human review + CI feedback on a PR -- loop until all resolved | GitHub CLI |
| `/generate-slides` | Generate professional slides with Gemini image generation, combine into PDF | Vertex AI, google-genai |
| `/weekly-report` | Auto-generate weekly progress report (MD + PPTX) from codebase analysis | Docker, python-pptx |

### Project Management (3 skills)

Cross-platform analysis of project status from Slack, ticket systems, and documentation.

| Command | Description | Prerequisites |
|:--|:--|:--|
| `/progress-check` | Update WBS from ticket system, detect delays, generate Mermaid Gantt chart | Ticket system MCP |
| `/meeting-review` | Parse meeting minutes -> detect spec changes -> batch-update GitHub Issues & docs | GitHub CLI |
| `/work-report` | Generate monthly work report from time allocation + WBS + tickets | Ticket system MCP |

### Sales Workflow (4 skills)

Discovery-first sales methodology: lead screening, weekly pipeline review, briefing prep before meetings, proposal creation after.

| Command | Description | Prerequisites |
|:--|:--|:--|
| `/lead-screen` | Score inbound leads (matching services, referrals) on 5 axes and produce Go/No-Go + proposal form draft | Gmail MCP |
| `/lead-analyze` | Weekly lead pipeline review: new lead screening + in-progress status updates + dormant detection | Gmail MCP |
| `/pre-meeting-proposal` | Pre-meeting briefing: prospect research + discovery questions + internal prep notes | Gmail MCP |
| `/post-meeting-proposal` | Post-meeting proposal: transcript analysis + proposal doc + Gemini slides + email draft | Gmail MCP, Vertex AI |

### Operations (3 skills)

Action item tracking, invoicing, and month-end orchestration.

| Command | Description | Prerequisites |
|:--|:--|:--|
| `/ball-check` | Cross-platform action item tracking (Slack + Chat + GitHub + tickets + email) | Slack MCP, Ticket MCP |
| `/invoice-draft` | Generate invoice draft + accounting system input guide | Accounting MCP |
| `/month-end` | Month-end orchestrator: ball-check -> progress -> docs -> report -> invoice -> git push | All MCP servers |

### Site Management (5 skills)

Coding-agent setup for non-engineers, plus a guarded "describe in plain language → publish to GitHub Pages" workflow. See `templates/scripts/` for cross-platform setup scripts and `templates/.github/workflows/` for a deploy workflow you can drop into any static-site project.

| Command | Description | Prerequisites |
|:--|:--|:--|
| `/agent-setup` | Guided install of Node.js / GitHub CLI / Claude Code / Gemini CLI / Codex CLI + project deps | -- |
| `/agent-setup-check` | Verify the development environment is healthy | -- |
| `/site-update` | Translate plain-language requirements into code changes; auto-test → repair → preview | GitHub CLI, project test cmd |
| `/site-preview` | Sync with remote, run tests with auto-repair, present preview URLs | GitHub CLI, project test cmd |
| `/site-publish` | Test gate → conflict-safe rebase → user confirm → commit → push → monitor deploy | GitHub CLI, project test cmd |

---

## Project Configuration (`CLAUDE.md`)

Most skills use placeholder variables like `{PROJECT_NAME}` or `{SLACK_CHANNELS}`. Define these in your project's `CLAUDE.md`.

### Common Configuration Template

```markdown
## Skill Configuration

### Project Basics
- {PROJECT_NAME}: MyProject
- {COMPANY_NAME}: Acme Corp
- {PM_DIR}: docs/pm
- {DESIGN_DIR}: docs/design

### Slack
- {SLACK_CHANNELS}:
  - #project-general: C0123456789
  - #project-dev: C0123456790
- {SLACK_USERS_INTERNAL}:
  - Alice: U0123456789 (PM)
  - Bob: U0123456790 (Engineer)
- {SLACK_USERS_EXTERNAL}:
  - Charlie: U0123456791 (Client Corp, PM)

### Ticket System
- {TICKET_PROJECT}: MY_PROJECT (ID: 12345)

### Development (screen-* skills)
- {VIEW_DIR}: modules/admin/views/
- {USER_VIEW_DIR}: views/
- {CSS_FILES}: web/css/main.css, web/css/color.css
- {MODEL_DIR}: models/
- {CONTROLLER_DIR}: controllers/
- {TEST_DIR}: tests/unit/
- {TEST_CMD}: docker compose exec -T app vendor/bin/phpunit {file}
- {PLAYWRIGHT_DIR}: playwright
- {PLAYWRIGHT_CMD}: cd playwright && npx playwright test {file} --project=local
- {LOCAL_URL}: https://localhost:8080

### CI/GitHub (fix-pr-* skills)
- {GITHUB_REPO}: my-org/my-repo
- {GH_USER}: my-github-user
- {CI_BOT_USER}: github-actions[bot]
- {LINT_FIX_CMD}: docker compose exec -T app vendor/bin/phpcbf {files}
- {LINT_CHECK_CMD}: docker compose exec -T app vendor/bin/phpcs {files}

### Invoicing (invoice-draft)
- {CLIENT_NAME}: Client Corp
- {CONTRACT_TYPE}: T&M
- {BILLING_AMOUNT}: $10,000
- {COST_ALLOCATION_FILE}: docs/pm/time-allocation.xlsx
- {BANK_INFO}: (your bank details)
- {INVOICE_ISSUER}: (your company info)
- {ACCOUNTING_SYSTEM}: freee

### Sales (pre/post-meeting-proposal)
- {SALES_DIR}: sales/
- {GCP_PROJECT}: my-gcp-project
- {SENDER_NAME}: Your Name
- {SENDER_TITLE}: CEO
- {SENDER_EMAIL}: you@company.com
- {COMPANY_URL}: https://company.com

### Site Management (agent-setup, site-* skills)
- {SITE_NAME}: My Site
- {LOCAL_DEV_URL}: http://localhost:3000/
- {BASE_URL_PATH}: /my-site/
- {DEV_CMD}: npm run dev
- {TEST_CMD}: npx playwright test --grep-invert "build"
- {TEST_FULL_CMD}: npx playwright test
- {TEST_FILE}: e2e/site.spec.ts
- {DEPLOY_BRANCH}: main
- {DEPLOY_WAIT_HINT}: 2-3 minutes
- {INSTALL_AGENTS}: claude,gemini,codex
- {NODE_MIN_VERSION}: 20
- {PROTECTED_PATHS}: nuxt.config.ts:baseURL, public/data/*.auto.json
- {DESIGN_TOKENS}: primary, secondary, accent
- {PAGES_MAP}: (table — see skills/site-update/SKILL.md for the template)
```

---

## Directory Structure

```
claude-skills/
├── README.md
├── setup.sh                  # Symlinks ~/.claude/skills/ → this repo
├── skills/
│   ├── screen-tdd/           # Development
│   ├── screen-analyze/       # Development
│   ├── screen-test/          # Development
│   ├── screen-capture/       # Development
│   ├── fix-pr-ci/            # Development
│   ├── fix-pr-review/        # Development
│   ├── generate-slides/      # Development
│   ├── weekly-report/        # Development
│   ├── progress-check/       # Project Management
│   ├── meeting-review/       # Project Management
│   ├── work-report/          # Project Management
│   ├── lead-screen/          # Sales
│   ├── lead-analyze/         # Sales
│   ├── pre-meeting-proposal/ # Sales
│   ├── post-meeting-proposal/# Sales
│   ├── ball-check/           # Operations
│   ├── invoice-draft/        # Operations
│   ├── month-end/            # Operations
│   ├── agent-setup/          # Site Management
│   ├── agent-setup-check/    # Site Management
│   ├── site-update/          # Site Management
│   ├── site-preview/         # Site Management
│   └── site-publish/         # Site Management
└── templates/                # Drop-in templates for new projects
    ├── scripts/              # Cross-platform bootstrap & setup (sh + ps1)
    ├── .github/workflows/    # GitHub Pages deploy workflow
    └── agent-config/         # CLAUDE.md / AGENTS.md / GEMINI.md skeletons
```

---

## Adding / Updating Skills

### Update an Existing Skill

```bash
cd ~/repos/claude-skills
vim skills/{skill-name}/SKILL.md
git add -A && git commit -m "update: {skill-name}" && git push
```

On other machines: `cd ~/repos/claude-skills && git pull`

### Add a New Skill

1. Create `skills/{skill-name}/SKILL.md`
2. Define `name`, `description`, `argument-hint` in the frontmatter
3. Update this README's skill table
4. Commit & push

### SKILL.md Template

```markdown
---
name: my-new-skill
description: One-line description of what this skill does
argument-hint: "[argument description]"
disable-model-invocation: true
---

# Skill Name

## Configuration
- `{VARIABLE}`: Description

## Execution Steps
### Step 1: ...
```

---

## Global Rules (All Skills)

- **Never send emails** -- draft creation only
- **Never include cost/rate/margin/hourly-rate information** in any output
- **Always get user confirmation before writing to external services**
- **Never include credentials, API keys, or tokens** in skill output
- **Read all Slack threads in full** -- no summaries or abbreviations
- **Do not start from archives alone** -- always fetch latest data from live sources first
