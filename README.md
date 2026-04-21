# Coding-Agent Skills

**Claude Code (Anthropic) / Gemini CLI (Google) / Codex CLI (OpenAI)** のいずれでも同じスラッシュコマンドが使える、業務ワークフロー向けスキル集です（全 24 スキル）。

---

## 🚀 セットアップ（3 分）

ターミナル / PowerShell に **1 行貼り付けて Enter** だけ。Git / Node.js / GitHub CLI (`gh`) / Claude Code / Gemini CLI / Codex CLI とこのリポジトリが自動で入り、最後に GitHub サインインまで案内されます。

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/gsc-kamiya/coding-agent-skills/main/bootstrap.sh | bash
```

### Windows

「スタート」→「PowerShell」を開いて貼り付け:

```powershell
irm https://raw.githubusercontent.com/gsc-kamiya/coding-agent-skills/main/bootstrap.ps1 | iex
```

> **GitHub 認証**: スクリプトの最後で `gh auth login` が走り、ブラウザでサインインを促されます。8桁のワンタイムコードを画面に表示 → ブラウザで貼り付け → 完了。

---

## 🎯 はじめての一歩 — GitHub Pages サイトを作って公開

セットアップ完了後、ターミナルで好きなエージェントを起動して、`/site-create` を呼ぶだけで新規サイトが立ち上がり公開されます。

```bash
# エージェントを起動 (どれか1つ)
claude    # または gemini / codex
```

エージェントが起動したら:

```text
/site-create my-first-site
```

これだけで自動で進む内容:

1. ✅ `~/sites/my-first-site/` に Astro 雛形を作成
2. ✅ GitHub Actions のデプロイワークフローを配置
3. ✅ GitHub にリポジトリを作成（既定: Private）
4. ✅ 初回コミット & push
5. ✅ GitHub Pages を有効化
6. ✅ 初回デプロイ完了を待機
7. ✅ 公開 URL を表示 → `https://<owner>.github.io/my-first-site/`

途中で「サイト名」「公開範囲（private/public）」「フレームワーク（既定: Astro）」を1問ずつ確認されます。Enter で既定値 OK。

完成後、引き続きこんなことができます:

```text
/site-update トップページの見出しを「ようこそ！」に変更
/site-preview                 ローカルでプレビュー
/site-publish                 公開サイトに反映
```

---

## 使い方

セットアップ完了後、好きなエージェントを起動してスラッシュコマンドを呼び出すだけ。

```bash
claude    # → /site-create, /site-update, /weekly-report, ...
gemini    # → /site-create, /site-update, /weekly-report, ...
codex     # → /site-create, /site-update, /weekly-report, ...
```

### よく使うコマンドの実行例

```text
# 環境が正しく整っているか確認
/agent-setup-check

# 新規サイトを作って GitHub Pages で公開
/site-create my-first-site

# 既存サイトを「日本語の自然な指示」だけで更新
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
| [スキル一覧](docs/skills.md) | 全 24 スキルの一覧と説明（5 カテゴリ） |
| [セットアップ詳細](docs/setup.md) | 動作の仕組み、個別インストール、Windows 注意点、アップデート手順 |
| [MCP サーバー設定](docs/mcp.md) | Slack / Gmail / チケット管理などの MCP サーバー設定例 |
| [プロジェクト設定](docs/project-config.md) | `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` のテンプレートと変数定義 |
| [スキルの追加・更新](docs/contributing.md) | 新規スキルの作り方、ディレクトリ構成 |
