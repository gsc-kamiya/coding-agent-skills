# {{SITE_TITLE}}

{{SITE_DESCRIPTION}}

## 開発

```bash
npm install
npm run dev          # http://localhost:4321/{{SITE_NAME}}/
```

## ビルド & プレビュー

```bash
npm run build        # → dist/ に静的サイトを出力
npm run preview      # ビルド結果をローカルでプレビュー
```

## 公開

`main` ブランチへ push すると、`.github/workflows/deploy.yml` 経由で
GitHub Pages へ自動デプロイされます。

公開 URL: `https://{{OWNER}}.github.io/{{SITE_NAME}}/`

## エージェント駆動の更新

```text
# サイトを起動した coding-agent CLI 内で:
/site-update トップページの見出しを「○○」に変更してください
/site-preview                   # ローカルでプレビュー
/site-publish                   # 公開サイトに反映
```

## ディレクトリ構成

```
src/
├── layouts/Layout.astro     # 全ページ共通レイアウト
├── components/              # 再利用可能なコンポーネント
├── pages/                   # ルーティング (Astro file-based routing)
└── styles/global.css        # グローバルスタイル
public/                      # 静的アセット (favicon, 画像など)
astro.config.mjs             # Astro 設定 (site / base URL)
```

## ライセンス

このサイトの雛形は MIT。コンテンツ部分は各自で設定してください。
