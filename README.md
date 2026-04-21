# Claude Code Skills

業務ワークフロー向けの再利用可能な Claude Code スキル集です。各スキルは **汎用かつ設定可能** に設計されており、自社・自プロジェクト・利用ツールに合わせてプロジェクト直下の `CLAUDE.md` 内のプレースホルダ変数で挙動をカスタマイズできます。

## セットアップ

### 1. リポジトリをクローン

```bash
cd ~/repos
git clone git@github.com:{YOUR_ORG}/claude-skills.git
```

### 2. スキルをインストール

```bash
cd claude-skills
./setup.sh
```

`setup.sh` は `~/.claude/skills/` をこのリポジトリの `skills/` ディレクトリへのシンボリックリンクに置き換えます。
既存のスキルが存在する場合は、先に `~/.claude/skills.bak.{timestamp}` としてバックアップを作成します。

```
~/.claude/skills/ -> ~/repos/claude-skills/skills/
```

### 3. MCP サーバー

多くのスキルは MCP（Model Context Protocol）サーバーに依存しています。`~/.claude.json`（グローバル）またはプロジェクト直下の `.claude/settings.json` に設定してください。

| MCP サーバー | パッケージ | 用途 | 利用スキル |
|:--|:--|:--|:--|
| **Google Workspace** | `workspace-mcp`（uvx） | Gmail, Calendar, Chat | pre/post-meeting-proposal, invoice-draft, ball-check |
| **Slack** | Claude Code 標準搭載 | チャンネル/スレッド読み取り、検索 | ball-check, progress-check, work-report |
| **チケット管理** | `backlog-mcp-server`, Jira MCP など | チケット操作 | ball-check, progress-check, work-report |
| **会計システム** | `freee-mcp`, QuickBooks MCP など | 請求書ドラフト | invoice-draft, month-end |

#### Google Workspace MCP の例（`~/.claude.json`）

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

> **重要**: `WORKSPACE_MCP_PORT` は `"0"`（自動割当）にしてください。複数の Claude Code インスタンスを同時起動する際のポート競合を防ぎます。

#### Slack MCP

Claude Code 標準搭載の Slack MCP を使用します。Claude Code の設定画面から有効化してください。

#### チケット管理 MCP の例（Backlog）

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

### 4. CLI ツール

| ツール | インストール | 利用スキル |
|:--|:--|:--|
| **GitHub CLI** (`gh`) | `brew install gh` | fix-pr-ci, fix-pr-review, meeting-review, ball-check |
| **Playwright** | `npm install -D @playwright/test && npx playwright install` | screen-*, screen-capture |
| **python-pptx** | `pip install python-pptx` | weekly-report |
| **google-genai** | `pip install google-genai pillow` | generate-slides, post-meeting-proposal |
| **Docker** | Docker Desktop | weekly-report, screen-tdd, screen-test |

> **複数 GitHub アカウントの使い分け**: 複数の Claude Code インスタンスを同時に動かす場合、グローバルに認証状態を変更する `gh auth switch` ではなく、ターミナルごとに `GH_TOKEN` を使ってください:
> ```bash
> # NG: 他のターミナルにも影響する
> gh auth switch --user my-account
>
> # OK: このターミナルだけに影響する
> export GH_TOKEN=$(gh auth token --user my-account)
> git push origin main
> ```

#### Google Workspace CLI（任意）

MCP の範囲を超える Google Workspace 操作には、以下の CLI が利用できます:

**選択肢 A: `gws`** -- [Google 公式 CLI](https://github.com/googleworkspace/cli)
```bash
npm install -g @googleworkspace/cli
gws auth setup && gws auth login
```

**選択肢 B: `gog`** -- [コミュニティ製 CLI](https://github.com/steipete/gogcli)
```bash
brew install gogcli
gog auth credentials ~/Downloads/client_secret_*.json
gog auth add you@gmail.com
```

> **ヒント**: MCP と CLI は併用可能です。MCP がカバーしていない API 操作が必要な場合は、Bash ツール経由で CLI を呼び出してください。

---

## スキル一覧（全 23 スキル / 5 カテゴリ）

### 開発ワークフロー（8 スキル）

TDD ベースの画面修正、CI 自動修正、ビジュアル比較、スライド生成、進捗レポート。

| コマンド | 概要 | 前提 |
|:--|:--|:--|
| `/screen-tdd` | TDD ベースの画面修正（分析 → テスト → 実装 → Playwright ビジュアル比較） | Docker, Playwright |
| `/screen-analyze` | 既存画面実装の網羅分析と修正計画の作成 | -- |
| `/screen-test` | 単体テスト + Playwright ビジュアル比較を実行し、差分を反復的に修正 | Docker, Playwright |
| `/screen-capture` | Playwright でスクリーンショットを取得して目視確認 | Playwright |
| `/fix-pr-ci` | PR の CI 指摘（lint/静的解析）を自動修正し、全チェック通過までループ | GitHub CLI |
| `/fix-pr-review` | PR の人間レビュー + CI 指摘の両方を解消するまでループ | GitHub CLI |
| `/generate-slides` | Gemini 画像生成でプロ品質のスライドを作成し、PDF に結合 | Vertex AI, google-genai |
| `/weekly-report` | コードベース解析から週次進捗レポート（MD + PPTX）を自動生成 | Docker, python-pptx |

### プロジェクト管理（3 スキル）

Slack・チケットシステム・ドキュメントを横断したプロジェクト状況分析。

| コマンド | 概要 | 前提 |
|:--|:--|:--|
| `/progress-check` | チケットシステムから WBS を更新、遅延検知、Mermaid ガントチャート生成 | チケット管理 MCP |
| `/meeting-review` | 議事録を解析 → 仕様変更を検出 → GitHub Issue とドキュメントを一括更新 | GitHub CLI |
| `/work-report` | 工数表 + WBS + チケットから月次稼働報告書を生成 | チケット管理 MCP |

### 営業ワークフロー（4 スキル）

ディスカバリー先行型の営業プロセス: リードスクリーニング、週次パイプラインレビュー、商談前ブリーフィング、商談後の提案資料作成。

| コマンド | 概要 | 前提 |
|:--|:--|:--|
| `/lead-screen` | インバウンドリード（マッチングサービス、紹介案件）を5軸でスコアリングし、Go/No-Go 判定と提案フォーム下書きを出力 | Gmail MCP |
| `/lead-analyze` | 週次リードパイプラインレビュー: 新規スクリーニング + 進行中ステータス更新 + 休眠検知 | Gmail MCP |
| `/pre-meeting-proposal` | 商談前ブリーフィング: 顧客リサーチ + ディスカバリー質問 + 社内向け準備メモ | Gmail MCP |
| `/post-meeting-proposal` | 商談後提案: 議事録解析 + 提案ドキュメント + Gemini スライド + メール下書き | Gmail MCP, Vertex AI |

### オペレーション（3 スキル）

アクションアイテム追跡、請求書発行、月次決算オーケストレーション。

| コマンド | 概要 | 前提 |
|:--|:--|:--|
| `/ball-check` | プラットフォーム横断のアクションアイテム追跡（Slack + Chat + GitHub + チケット + メール） | Slack MCP, チケット MCP |
| `/invoice-draft` | 請求書ドラフト + 会計システム入力ガイドの生成 | 会計 MCP |
| `/month-end` | 月次クロージングのオーケストレーション: ball-check → progress → docs → report → invoice → git push | 全 MCP サーバー |

### サイト運用（5 スキル）

非エンジニア向けのコーディングエージェント環境セットアップと、「自然言語で要件を伝える → GitHub Pages へ公開」までを安全に回すワークフロー。`templates/scripts/` にクロスプラットフォーム対応のセットアップスクリプト、`templates/.github/workflows/` に静的サイトプロジェクトに流用できる汎用デプロイワークフローを同梱しています。

| コマンド | 概要 | 前提 |
|:--|:--|:--|
| `/agent-setup` | Node.js / GitHub CLI / Claude Code / Gemini CLI / Codex CLI とプロジェクト依存パッケージのガイド付きインストール | -- |
| `/agent-setup-check` | 開発環境が正常に整っているかをヘルスチェック | -- |
| `/site-update` | 自然言語の要件をコード変更に翻訳し、自動テスト → 自動修復 → プレビューまで実施 | GitHub CLI, プロジェクトのテストコマンド |
| `/site-preview` | リモートと同期 → テスト（自動修復付き）→ プレビュー URL を案内 | GitHub CLI, プロジェクトのテストコマンド |
| `/site-publish` | テストゲート → 競合回避 rebase → ユーザー確認 → コミット → push → デプロイ監視 | GitHub CLI, プロジェクトのテストコマンド |

---

## プロジェクト設定（`CLAUDE.md`）

ほとんどのスキルは `{PROJECT_NAME}` や `{SLACK_CHANNELS}` などのプレースホルダ変数を使います。プロジェクト直下の `CLAUDE.md` で定義してください。

### 共通設定テンプレート

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

---

## ディレクトリ構成

```
claude-skills/
├── README.md
├── setup.sh                  # ~/.claude/skills/ → このリポにシンボリックリンク
├── skills/
│   ├── screen-tdd/           # 開発
│   ├── screen-analyze/       # 開発
│   ├── screen-test/          # 開発
│   ├── screen-capture/       # 開発
│   ├── fix-pr-ci/            # 開発
│   ├── fix-pr-review/        # 開発
│   ├── generate-slides/      # 開発
│   ├── weekly-report/        # 開発
│   ├── progress-check/       # プロジェクト管理
│   ├── meeting-review/       # プロジェクト管理
│   ├── work-report/          # プロジェクト管理
│   ├── lead-screen/          # 営業
│   ├── lead-analyze/         # 営業
│   ├── pre-meeting-proposal/ # 営業
│   ├── post-meeting-proposal/# 営業
│   ├── ball-check/           # オペレーション
│   ├── invoice-draft/        # オペレーション
│   ├── month-end/            # オペレーション
│   ├── agent-setup/          # サイト運用
│   ├── agent-setup-check/    # サイト運用
│   ├── site-update/          # サイト運用
│   ├── site-preview/         # サイト運用
│   └── site-publish/         # サイト運用
└── templates/                # 新規プロジェクトに流用できるテンプレート
    ├── scripts/              # クロスプラットフォーム bootstrap & setup（sh + ps1）
    ├── .github/workflows/    # GitHub Pages デプロイ workflow
    └── agent-config/         # CLAUDE.md / AGENTS.md / GEMINI.md ひな形
```

---

## スキルの追加・更新

### 既存スキルの更新

```bash
cd ~/repos/claude-skills
vim skills/{skill-name}/SKILL.md
git add -A && git commit -m "update: {skill-name}" && git push
```

他の端末では: `cd ~/repos/claude-skills && git pull`

### 新規スキルの追加

1. `skills/{skill-name}/SKILL.md` を作成
2. フロントマターに `name`, `description`, `argument-hint` を定義
3. この README のスキル一覧表を更新
4. コミット & push

### SKILL.md テンプレート

```markdown
---
name: my-new-skill
description: スキルが何をするかを 1 行で説明
argument-hint: "[引数の説明]"
disable-model-invocation: true
---

# Skill Name

## Configuration
- `{VARIABLE}`: 説明

## Execution Steps
### Step 1: ...
```

---

## 全スキル共通ルール

- **メールは絶対に送信しない** — 下書き作成までに留める
- **原価・単価・利益率・時給などの内部金額情報を一切出力しない**
- **外部サービスへの書き込みは必ずユーザーの承認を得てから実施する**
- **クレデンシャル・API キー・トークンを出力に含めない**
- **Slack スレッドは要約せず全件読む** — 省略・要約禁止
- **アーカイブだけを起点に作業を始めない** — 必ず最新データをライブのソースから取得する
