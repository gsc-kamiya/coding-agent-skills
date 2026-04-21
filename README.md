# Coding-Agent Skills

**Claude Code (Anthropic) / Gemini CLI (Google) / Codex CLI (OpenAI)** のいずれでも同じスラッシュコマンドが使える、業務ワークフロー向けスキル集です（全 23 スキル）。

---

## 🚀 セットアップ（3 分）

ターミナル / PowerShell に **1 行貼り付けて Enter** だけ。Git / Node.js / GitHub CLI / Claude Code / Gemini CLI / Codex CLI とこのリポジトリが自動で入ります。

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/h2o-r/coding-agent-skills/main/bootstrap.sh | bash
```

### Windows

「スタート」→「PowerShell」を開いて貼り付け:

```powershell
irm https://raw.githubusercontent.com/h2o-r/coding-agent-skills/main/bootstrap.ps1 | iex
```

---

## 使い方

セットアップ完了後、好きなエージェントを起動してスラッシュコマンドを呼び出すだけ:

```bash
claude    # → /agent-setup-check, /site-update, ...
gemini    # → /agent-setup-check, /site-update, ...
codex     # → /agent-setup-check, /site-update, ...
```

### よく使うコマンドの実行例

```bash
# 環境が正しく整っているか確認
/agent-setup-check

# 「トップページのキャッチコピーを変えて」と日本語で指示するだけでサイト更新
/site-update トップページの見出しを「未来をつくるH2O」に変更してください

# 変更内容をプレビュー
/site-preview

# 公開サイトに反映
/site-publish

# 週次の進捗レポートを自動生成（MD + PPTX）
/weekly-report

# 月末締めをまとめて実行（タスク棚卸し → 進捗更新 → 報告書 → 請求書）
/month-end 2026-04
```

---

## 📚 ドキュメント

| ドキュメント | 内容 |
|:--|:--|
| [スキル一覧](docs/skills.md) | 全 23 スキルの一覧と説明（5 カテゴリ） |
| [セットアップ詳細](docs/setup.md) | 動作の仕組み、個別インストール、Windows 注意点、アップデート手順 |
| [MCP サーバー設定](docs/mcp.md) | Slack / Gmail / チケット管理などの MCP サーバー設定例 |
| [プロジェクト設定](docs/project-config.md) | `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` のテンプレートと変数定義 |
| [スキルの追加・更新](docs/contributing.md) | 新規スキルの作り方、ディレクトリ構成 |
