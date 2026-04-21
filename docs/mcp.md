# MCP サーバー設定

スキルによっては Slack / Gmail / チケット管理などの外部サービス操作が必要です。`~/.claude.json`（Claude Code）または各エージェントの設定ファイルに MCP サーバーを定義してください。

## サーバー一覧

| MCP サーバー | パッケージ | 用途 | 利用スキル |
|:--|:--|:--|:--|
| **Google Workspace** | `workspace-mcp`（uvx） | Gmail, Calendar, Chat | pre/post-meeting-proposal, invoice-draft, ball-check, lead-* |
| **Slack** | Claude Code 標準搭載 | チャンネル/スレッド読み取り、検索 | ball-check, progress-check, work-report |
| **チケット管理** | `backlog-mcp-server`, Jira MCP など | チケット操作 | ball-check, progress-check, work-report |
| **会計システム** | `freee-mcp`, QuickBooks MCP など | 請求書ドラフト | invoice-draft, month-end |

## 設定例

### Google Workspace MCP（`~/.claude.json`）

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

### チケット管理 MCP（Backlog）

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

## オプション CLI ツール（一部スキルで必要）

| ツール | インストール | 利用スキル |
|:--|:--|:--|
| **Playwright** | `npm install -D @playwright/test && npx playwright install` | screen-*, screen-capture |
| **python-pptx** | `pip install python-pptx` | weekly-report |
| **google-genai** | `pip install google-genai pillow` | generate-slides, post-meeting-proposal |
| **Docker** | Docker Desktop | weekly-report, screen-tdd, screen-test |
