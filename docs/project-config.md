# プロジェクト設定（`CLAUDE.md` / `AGENTS.md` / `GEMINI.md`）

ほとんどのスキルは `{PROJECT_NAME}` や `{SLACK_CHANNELS}` などのプレースホルダ変数を使います。プロジェクト直下に以下のいずれかのファイルを配置し、変数を定義してください。

| ファイル名 | 対象エージェント |
|:--|:--|
| `CLAUDE.md` | Claude Code |
| `AGENTS.md` | Codex CLI |
| `GEMINI.md` | Gemini CLI |

> 3 ファイルとも同じ内容で OK です。`templates/agent-config/` に雛形があります。

## 共通設定テンプレート

```markdown
## Skill Configuration

### プロジェクト基本情報
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

### チケットシステム
- {TICKET_PROJECT}: MY_PROJECT (ID: 12345)

### 開発系（screen-* スキル）
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

### CI / GitHub（fix-pr-* スキル）
- {GITHUB_REPO}: my-org/my-repo
- {GH_USER}: my-github-user
- {CI_BOT_USER}: github-actions[bot]
- {LINT_FIX_CMD}: docker compose exec -T app vendor/bin/phpcbf {files}
- {LINT_CHECK_CMD}: docker compose exec -T app vendor/bin/phpcs {files}

### 請求（invoice-draft）
- {CLIENT_NAME}: Client Corp
- {CONTRACT_TYPE}: T&M
- {BILLING_AMOUNT}: $10,000
- {COST_ALLOCATION_FILE}: docs/pm/time-allocation.xlsx
- {BANK_INFO}: (振込先情報)
- {INVOICE_ISSUER}: (発行元の会社情報)
- {ACCOUNTING_SYSTEM}: freee

### 営業（pre/post-meeting-proposal）
- {SALES_DIR}: sales/
- {GCP_PROJECT}: my-gcp-project
- {SENDER_NAME}: 担当者名
- {SENDER_TITLE}: 役職
- {SENDER_EMAIL}: you@company.com
- {COMPANY_URL}: https://company.com

### サイト運用（agent-setup, site-* スキル）
- {SITE_NAME}: My Site
- {LOCAL_DEV_URL}: http://localhost:3000/
- {BASE_URL_PATH}: /my-site/
- {DEV_CMD}: npm run dev
- {TEST_CMD}: npx playwright test --grep-invert "build"
- {TEST_FULL_CMD}: npx playwright test
- {TEST_FILE}: e2e/site.spec.ts
- {DEPLOY_BRANCH}: main
- {DEPLOY_WAIT_HINT}: 2-3 分
- {INSTALL_AGENTS}: claude,gemini,codex
- {NODE_MIN_VERSION}: 20
- {PROTECTED_PATHS}: nuxt.config.ts:baseURL, public/data/*.auto.json
- {DESIGN_TOKENS}: primary, secondary, accent
- {PAGES_MAP}: （表形式 — テンプレートは skills/site-update/SKILL.md を参照）
```
