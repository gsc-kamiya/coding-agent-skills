---
name: site-create
description: GitHub Pages で公開する新規サイトを作成 — リポ同梱のリッチな Astro 雛形を展開し、デプロイワークフロー + agent config を配置してリポ作成・push・Pages 有効化まで自動実行
argument-hint: "[サイト名（半角英数 + ハイフン、例: my-site）]"
---

# 新規 GitHub Pages サイト作成

「サイトを作って公開したい」と一言で済ませるためのスキル。`coding-agent-skills` リポに同梱された **リッチな Astro 雛形**（`templates/starter-sites/astro/`）を展開し、GitHub リポジトリを作成し、GitHub Actions のデプロイワークフローを設定し、Pages を有効化して、ライブ URL を返します。

> **設計方針**: `npm create astro` の素の minimal 雛形は `<h1>Astro</h1>` だけで魅力に乏しいため、**事前にデザイン済みのランディングページ**を雛形として持っています。展開直後から「すぐ見せられる」サイトが立ち上がります。

## Configuration

オプション（プロジェクトの `CLAUDE.md` で上書き可）:

| 変数 | 説明 | デフォルト |
|:--|:--|:--|
| `{SITES_PARENT_DIR}` | 新規サイトを置く親ディレクトリ | `~/sites` |
| `{DEFAULT_VISIBILITY}` | リポジトリ公開設定 | `public`（GH Pages 無料利用のため） |
| `{DEFAULT_OWNER}` | リポジトリ owner | （`gh api user` で自動検出） |
| `{GH_USER}` | git push に使う GitHub アカウント | （現在の `gh auth status` から検出） |
| `{SKILLS_REPO_DIR}` | このリポのローカルパス（雛形読み込み元） | `~/coding-agent-skills` |

## 引数

- `$0`: サイト名（半角英数 + ハイフン）。未指定ならユーザーに対話で確認。

## 前提（Step 0 で自動チェック）

- `node --version` ≥ 22（Astro 5 要件）
- `gh --version` がインストール済み
- `gh auth status` で認証済み
- `{SKILLS_REPO_DIR}/templates/starter-sites/astro/` が存在

未充足の場合は `/agent-setup-check` または `/agent-setup` の実行を案内する。

## 実行フロー

### Step 0: 環境チェック

```bash
node --version    # >= v22.12.0 を確認
gh --version
gh auth status
test -d "${HOME}/coding-agent-skills/templates/starter-sites/astro"
```

Node.js が 20 以下なら中断して案内（Astro 5 が動かない）。雛形が見つからない場合は最新へ pull するよう案内:

```bash
cd ~/coding-agent-skills && git pull
```

### Step 1: 必要情報の確認

`$ARGUMENTS` でサイト名が指定されていればそれを使う。未指定なら以下を順に対話で確認（既定値は即 Enter で OK）:

| 質問 | 既定値 |
|:--|:--|
| サイト名（リポジトリ名・ディレクトリ名） | （必須） |
| サイトのタイトル（画面に表示） | サイト名から推測（ハイフン → スペース、Title Case） |
| 説明（リポジトリ description） | "Static site published via GitHub Pages" |
| リポジトリ owner | 自動検出値（`gh api user -q .login`） |
| 公開範囲 (private/public) | `public`（**重要**: 無料プランの GitHub では Private リポの Pages は不可） |

> **無料 GitHub プランで Private を選んだ場合**: Pages 有効化が `Your current plan does not support GitHub Pages for this repository.` で 422 エラーになります。その場合は確認のうえ Public に切り替えるか、ユーザーに方針を確認してください。

確認: 「以下の内容で作成します。よろしいですか？ (y/n)」

### Step 2: 雛形を展開（リッチ版 Astro）

`coding-agent-skills` リポに同梱の Astro 雛形をコピーし、プレースホルダを置換:

```bash
mkdir -p {SITES_PARENT_DIR}
SRC=~/coding-agent-skills/templates/starter-sites/astro
DST={SITES_PARENT_DIR}/{SITE_NAME}

# 既存ディレクトリがあれば中断
[ -e "$DST" ] && { echo "ERROR: $DST already exists"; exit 1; }

cp -R "$SRC" "$DST"
cd "$DST"
```

#### プレースホルダ置換（全テキストファイル）

| プレースホルダ | 置換値 |
|:--|:--|
| `{{SITE_NAME}}` | サイト名 |
| `{{SITE_TITLE}}` | サイトタイトル |
| `{{SITE_DESCRIPTION}}` | 説明 |
| `{{OWNER}}` | リポジトリ owner |
| `{{INITIAL}}` | サイト名の頭文字 1 文字（大文字） |

```bash
INITIAL=$(echo "{SITE_NAME}" | head -c 1 | tr '[:lower:]' '[:upper:]')

find . -type f \( -name "*.astro" -o -name "*.css" -o -name "*.json" -o -name "*.mjs" -o -name "*.md" -o -name "*.svg" -o -name "*.html" \) \
  -exec sed -i.bak \
    -e "s|{{SITE_NAME}}|{SITE_NAME}|g" \
    -e "s|{{SITE_TITLE}}|{SITE_TITLE}|g" \
    -e "s|{{SITE_DESCRIPTION}}|{SITE_DESCRIPTION}|g" \
    -e "s|{{OWNER}}|{OWNER}|g" \
    -e "s|{{INITIAL}}|${INITIAL}|g" \
    {} \;

find . -name "*.bak" -delete
```

#### npm install

```bash
npm install --silent
```

### Step 3: GitHub Actions デプロイワークフローを配置

`coding-agent-skills` 同梱の GitHub Pages デプロイワークフローをコピー:

```bash
mkdir -p .github/workflows
cp ~/coding-agent-skills/templates/.github/workflows/deploy-github-pages.yml .github/workflows/deploy.yml
```

このワークフローは Astro 用にビルド設定済み（Node 22, `npx astro build`, `dist` を artifact）。

### Step 4: agent config を配置

```bash
cp ~/coding-agent-skills/templates/agent-config/CLAUDE.md ./CLAUDE.md
cp ~/coding-agent-skills/templates/agent-config/AGENTS.md ./AGENTS.md
cp ~/coding-agent-skills/templates/agent-config/GEMINI.md ./GEMINI.md
```

`{SITE_NAME}`, `{BASE_URL_PATH}`（= `/{SITE_NAME}/`）, `{DEV_CMD}`（`npm run dev`）, `{TEST_CMD}` などのプレースホルダを実際の値に置換。

### Step 5: Git 初期化・初回コミット

```bash
git init -b main
git add -A
git commit -m "init: 新規 GitHub Pages サイト ({SITE_NAME})"
```

### Step 6: GitHub リポジトリを作成して push

```bash
GH_TOKEN=$(gh auth token --user {GH_USER}) gh repo create {OWNER}/{SITE_NAME} \
  --{VISIBILITY} \
  --description "{DESCRIPTION}" \
  --source . \
  --remote origin \
  --push
```

### Step 7: GitHub Pages を有効化

GitHub Actions ベースのデプロイに設定:

```bash
GH_TOKEN=$(gh auth token --user {GH_USER}) gh api -X POST \
  /repos/{OWNER}/{SITE_NAME}/pages \
  -f build_type=workflow 2>&1
```

#### エラーハンドリング

| エラー | 原因 | 対処 |
|:--|:--|:--|
| `409` | 既に有効化済み | `PUT` で update |
| `422` `plan does not support` | 無料プラン × Private リポ | ユーザーに Public 化の確認 → `gh repo edit {OWNER}/{SITE_NAME} --visibility public --accept-visibility-change-consequences` の後に再試行 |
| `403` | 権限不足 | リポ owner（組織）の admin に依頼 |

### Step 8: 初回デプロイの完了を待つ

```bash
sleep 8

RUN_ID=$(GH_TOKEN=$(gh auth token --user {GH_USER}) gh run list \
  --repo {OWNER}/{SITE_NAME} --limit 1 --json databaseId --jq '.[0].databaseId')

GH_TOKEN=$(gh auth token --user {GH_USER}) gh run watch "$RUN_ID" \
  --repo {OWNER}/{SITE_NAME} --exit-status
```

ワークフロー完了後、Pages の URL を取得:

```bash
GH_TOKEN=$(gh auth token --user {GH_USER}) gh api /repos/{OWNER}/{SITE_NAME}/pages \
  --jq '.html_url'
```

### Step 9: 完了報告

```
✅ サイト作成完了！

📁 ローカル:    {SITES_PARENT_DIR}/{SITE_NAME}
📦 リポジトリ:  https://github.com/{OWNER}/{SITE_NAME}
🌐 公開 URL:    https://{OWNER}.github.io/{SITE_NAME}/

ライブ反映まで 1〜2 分かかる場合があります。

次の操作:

  cd {SITES_PARENT_DIR}/{SITE_NAME}
  claude    # または gemini / codex

エージェント内で:
  /site-update トップページの見出しを「○○」に変更
  /site-preview        ローカルで確認
  /site-publish        本番へ反映
```

## ルール

- 既に同名のローカルディレクトリがある場合は中断（上書きしない）
- 既に同名の GitHub リポジトリがある場合は中断（上書きしない）
- **既定の公開範囲は Public**（無料プランで Pages を使うため）。Private を希望されたら、無料プランでは Pages が使えないことを必ず伝える
- `gh repo edit --visibility` を呼ぶ場合は **`--accept-visibility-change-consequences`** を必ず付ける
- `gh auth status` で未認証の場合、`gh auth login` の実行を案内（自動実行はしない、ブラウザログインが必要なため）
- 失敗した場合はクリーンアップ（ローカルディレクトリ削除）するか、ユーザーに方針を確認

## トラブルシュート

| 症状 | 対処 |
|:--|:--|
| `Node.js vXX is not supported by Astro!` | Node 22 以上が必要。`brew upgrade node` または nvm で v22.12.0+ に更新 |
| `gh repo create` が 404 | `{OWNER}` が存在するか、`gh auth status` のスコープに `repo` が含まれるか確認 |
| Pages 有効化が 422 (plan) | 上記表のとおり Public 化を案内 |
| Pages 有効化が 403 | リポジトリの owner が組織で、Pages 作成権限がないアカウントの可能性。組織管理者に依頼 |
| `Get Pages site failed` (initial run) | Pages 有効化前に push が走った可能性。Pages 有効化後に `gh workflow run deploy.yml` で再実行 |
| デプロイ後 404 | `https://{OWNER}.github.io/{SITE_NAME}/` の末尾スラッシュ必須。3〜5 分の伝播待ちが必要な場合あり |
