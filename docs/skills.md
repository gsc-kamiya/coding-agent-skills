# スキル一覧

全 23 スキル / 5 カテゴリ。各スキルの詳細は `skills/<name>/SKILL.md` を参照してください。

## 開発ワークフロー（8 スキル）

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

## プロジェクト管理（3 スキル）

Slack・チケットシステム・ドキュメントを横断したプロジェクト状況分析。

| コマンド | 概要 | 前提 |
|:--|:--|:--|
| `/progress-check` | チケットシステムから WBS を更新、遅延検知、Mermaid ガントチャート生成 | チケット管理 MCP |
| `/meeting-review` | 議事録を解析 → 仕様変更を検出 → GitHub Issue とドキュメントを一括更新 | GitHub CLI |
| `/work-report` | 工数表 + WBS + チケットから月次稼働報告書を生成 | チケット管理 MCP |

## 営業ワークフロー（4 スキル）

ディスカバリー先行型の営業プロセス: リードスクリーニング、週次パイプラインレビュー、商談前ブリーフィング、商談後の提案資料作成。

| コマンド | 概要 | 前提 |
|:--|:--|:--|
| `/lead-screen` | インバウンドリード（マッチングサービス、紹介案件）を5軸でスコアリングし、Go/No-Go 判定と提案フォーム下書きを出力 | Gmail MCP |
| `/lead-analyze` | 週次リードパイプラインレビュー: 新規スクリーニング + 進行中ステータス更新 + 休眠検知 | Gmail MCP |
| `/pre-meeting-proposal` | 商談前ブリーフィング: 顧客リサーチ + ディスカバリー質問 + 社内向け準備メモ | Gmail MCP |
| `/post-meeting-proposal` | 商談後提案: 議事録解析 + 提案ドキュメント + Gemini スライド + メール下書き | Gmail MCP, Vertex AI |

## オペレーション（3 スキル）

アクションアイテム追跡、請求書発行、月次決算オーケストレーション。

| コマンド | 概要 | 前提 |
|:--|:--|:--|
| `/ball-check` | プラットフォーム横断のアクションアイテム追跡（Slack + Chat + GitHub + チケット + メール） | Slack MCP, チケット MCP |
| `/invoice-draft` | 請求書ドラフト + 会計システム入力ガイドの生成 | 会計 MCP |
| `/month-end` | 月次クロージングのオーケストレーション: ball-check → progress → docs → report → invoice → git push | 全 MCP サーバー |

## サイト運用（5 スキル）

非エンジニア向けのコーディングエージェント環境セットアップと、「自然言語で要件を伝える → GitHub Pages へ公開」までを安全に回すワークフロー。

| コマンド | 概要 | 前提 |
|:--|:--|:--|
| `/agent-setup` | Node.js / GitHub CLI / Claude Code / Gemini CLI / Codex CLI とプロジェクト依存パッケージのガイド付きインストール | -- |
| `/agent-setup-check` | 開発環境が正常に整っているかをヘルスチェック | -- |
| `/site-update` | 自然言語の要件をコード変更に翻訳し、自動テスト → 自動修復 → プレビューまで実施 | GitHub CLI, プロジェクトのテストコマンド |
| `/site-preview` | リモートと同期 → テスト（自動修復付き）→ プレビュー URL を案内 | GitHub CLI, プロジェクトのテストコマンド |
| `/site-publish` | テストゲート → 競合回避 rebase → ユーザー確認 → コミット → push → デプロイ監視 | GitHub CLI, プロジェクトのテストコマンド |

## 全スキル共通ルール

- **メールは絶対に送信しない** — 下書き作成までに留める
- **原価・単価・利益率・時給などの内部金額情報を一切出力しない**
- **外部サービスへの書き込みは必ずユーザーの承認を得てから実施する**
- **クレデンシャル・API キー・トークンを出力に含めない**
- **Slack スレッドは要約せず全件読む** — 省略・要約禁止
- **アーカイブだけを起点に作業を始めない** — 必ず最新データをライブのソースから取得する
