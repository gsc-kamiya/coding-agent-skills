---
name: site-create
description: GitHub Pages で公開する新規サイトを作成 — Astro 雛形 + デプロイワークフロー + agent config を一括セットアップしてリポジトリ作成・push・Pages 有効化まで自動実行
argument-hint: "[サイト名（半角英数 + ハイフン、例: my-site）]"
---

# 新規 GitHub Pages サイト作成

ビジネスユーザーが「サイトを作って公開したい」と言うだけで、最後の URL 表示まで全自動で進めるスキル。Astro（静的サイトジェネレーター）の雛形を作り、GitHub リポジトリを作成し、GitHub Actions のデプロイワークフローを設定し、Pages を有効化して、ライブ URL を返します。

## Configuration

オプション（プロジェクトの `CLAUDE.md` で上書き可）:

| 変数 | 説明 | デフォルト |
|:--|:--|:--|
| `{SITES_PARENT_DIR}` | 新規サイトを置く親ディレクトリ | `~/sites` |
| `{DEFAULT_FRAMEWORK}` | フレームワーク (`astro` / `nuxt` / `next` / `vite` / `html`) | `astro` |
| `{DEFAULT_VISIBILITY}` | リポジトリ公開設定 (`private` / `public`) | `private` |
| `{DEFAULT_OWNER}` | リポジトリ owner（org または username） | （`gh api user` で自動検出） |
| `{GH_USER}` | git push に使う GitHub アカウント | （現在の `gh auth status` から検出） |

## 引数

- `$0`: サイト名（半角英数 + ハイフン）。未指定ならユーザーに対話で確認。

## 前提（Step 0 で自動チェック）

- `node --version` ≥ 20
- `gh --version` がインストール済み
- `gh auth status` で認証済み

未充足の場合は `/agent-setup-check` または `/agent-setup` の実行を案内する。

## 実行フロー

### Step 0: 環境チェック

```bash
node --version
gh --version
gh auth status
```

問題があれば中断して、ユーザーに `/agent-setup` を案内。

### Step 1: 必要情報の確認

`$ARGUMENTS` でサイト名が指定されていればそれを使う。未指定なら以下を順に対話で確認（既定値は即 Enter で OK）:

| 質問 | 既定値 |
|:--|:--|
| サイト名（リポジトリ名・ディレクトリ名） | （必須） |
| サイトのタイトル（画面に表示） | サイト名から推測 |
| 説明（リポジトリ description） | "Static site published via GitHub Pages" |
| リポジトリ owner | 自動検出値 |
| 公開範囲 (private/public) | `{DEFAULT_VISIBILITY}` |
| フレームワーク | `{DEFAULT_FRAMEWORK}`（`astro` 推奨） |

確認: 「以下の内容で作成します。よろしいですか？ (y/n)」

### Step 2: ローカルプロジェクトを作成

```bash
mkdir -p {SITES_PARENT_DIR}
cd {SITES_PARENT_DIR}
```

#### 2-A: Astro（既定）

```bash
npm create astro@latest -- {SITE_NAME} \
  --template minimal \
  --typescript strict \
  --no-install \
  --no-git \
  --skip-houston \
  --yes
cd {SITE_NAME}
npm install --silent
```

`astro.config.mjs` を以下に書き換え:

```js
import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://{OWNER}.github.io',
  base: '/{SITE_NAME}/',
  output: 'static',
});
```

`src/pages/index.astro` のタイトル・h1 をユーザー指定のサイトタイトルに置換。

#### 2-B: Nuxt

```bash
npx nuxi@latest init {SITE_NAME} --packageManager npm --gitInit false
cd {SITE_NAME}
npm install --silent
```

`nuxt.config.ts` の `app` セクションに `baseURL: '/{SITE_NAME}/'`、`nitro: { preset: 'github-pages' }` を追加。

#### 2-C: Vite + Vanilla

```bash
npm create vite@latest {SITE_NAME} -- --template vanilla-ts
cd {SITE_NAME}
npm install --silent
```

`vite.config.ts` に `base: '/{SITE_NAME}/'` を追加。

#### 2-D: Plain HTML（フレームワーク不要）

```bash
mkdir -p {SITE_NAME} && cd {SITE_NAME}
```

`index.html` を最低限の内容で作成（タイトル・h1・短い説明）。`package.json` 不要。

### Step 3: デプロイワークフローと agent config を配置

リポルートにある `templates/.github/workflows/deploy-github-pages.yml` をコピーして、フレームワークに合わせてビルドコマンドと出力ディレクトリを書き換える:

| フレームワーク | build コマンド | artifact path |
|:--|:--|:--|
| Astro | `npx astro build` | `dist` |
| Nuxt | `npx nuxt generate` | `.output/public` |
| Vite | `npm run build` | `dist` |
| Plain HTML | （ビルド不要） | `.` |

```bash
mkdir -p .github/workflows
cp .../templates/.github/workflows/deploy-github-pages.yml .github/workflows/deploy.yml
# 上記の path/build を sed で置換
```

agent config も配置:

```bash
cp .../templates/agent-config/CLAUDE.md ./CLAUDE.md
cp .../templates/agent-config/AGENTS.md ./AGENTS.md
cp .../templates/agent-config/GEMINI.md ./GEMINI.md
```

`{SITE_NAME}`, `{BASE_URL_PATH}`, `{DEV_CMD}`, `{TEST_CMD}` などのプレースホルダを実際の値に置換。

### Step 4: Git 初期化・初回コミット

```bash
git init -b main
git add -A
git commit -m "init: 新規 GitHub Pages サイト ({SITE_NAME})"
```

### Step 5: GitHub リポジトリを作成して push

```bash
GH_TOKEN=$(gh auth token --user {GH_USER}) gh repo create {OWNER}/{SITE_NAME} \
  --{VISIBILITY} \
  --description "{DESCRIPTION}" \
  --source . \
  --remote origin \
  --push
```

### Step 6: GitHub Pages を有効化

GitHub Actions ベースのデプロイに設定:

```bash
GH_TOKEN=$(gh auth token --user {GH_USER}) gh api -X POST \
  /repos/{OWNER}/{SITE_NAME}/pages \
  -f build_type=workflow 2>&1 || \
GH_TOKEN=$(gh auth token --user {GH_USER}) gh api -X PUT \
  /repos/{OWNER}/{SITE_NAME}/pages \
  -f build_type=workflow
```

（既に有効な場合 POST が失敗するため PUT でフォールバック）

### Step 7: 初回デプロイの完了を待つ

```bash
GH_TOKEN=$(gh auth token --user {GH_USER}) gh run watch --exit-status \
  --repo {OWNER}/{SITE_NAME}
```

ワークフロー完了後、Pages の URL を取得:

```bash
GH_TOKEN=$(gh auth token --user {GH_USER}) gh api /repos/{OWNER}/{SITE_NAME}/pages \
  --jq '.html_url'
```

### Step 8: 完了報告

ユーザーに以下を案内:

```
✅ サイト作成完了！

📁 ローカル:    {SITES_PARENT_DIR}/{SITE_NAME}
📦 リポジトリ:  https://github.com/{OWNER}/{SITE_NAME}
🌐 公開 URL:    https://{OWNER}.github.io/{SITE_NAME}/

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
- フレームワーク選択は対話で確認、勝手に変更しない
- 公開範囲（private/public）は必ず明示的に確認する
- `gh auth status` で未認証の場合、`gh auth login` の実行を案内（自動実行はしない、ブラウザログインが必要なため）
- 失敗した場合はクリーンアップ（ローカルディレクトリ削除）するか、ユーザーに方針を確認

## トラブルシュート

| 症状 | 対処 |
|:--|:--|
| `gh repo create` が 404 | `{OWNER}` が存在するか、`gh auth status` のスコープに `repo` が含まれるか確認 |
| Pages 有効化が 403 | リポジトリの owner が組織で、Pages 作成権限がないアカウントの可能性。組織管理者に依頼 |
| ワークフロー初回失敗 | `gh run view --log` でエラー確認。よくある原因: `astro.config.mjs` の `base` 末尾スラッシュ漏れ |
| デプロイ後 404 | `https://{OWNER}.github.io/{SITE_NAME}/` の末尾スラッシュ必須。3〜5 分の伝播待ちが必要な場合あり |
