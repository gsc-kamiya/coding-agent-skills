# スキルの追加・更新

## 既存スキルの編集

```bash
cd ~/coding-agent-skills
vim skills/{skill-name}/SKILL.md
git add -A && git commit -m "update: {skill-name}" && git push
```

他端末では:

```bash
cd ~/coding-agent-skills && git pull

# Gemini を使う場合のみ TOML を再生成
bash setup.sh gemini       # macOS / Linux
.\setup.ps1 -Agents gemini # Windows
```

## 新規スキルの追加

1. `skills/{skill-name}/SKILL.md` を作成
2. フロントマターに `name`, `description`, `argument-hint` を定義
3. [`docs/skills.md`](skills.md) のスキル一覧表を更新
4. コミット & push

## SKILL.md テンプレート

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

## ディレクトリ構成

```
coding-agent-skills/
├── README.md
├── bootstrap.sh / bootstrap.ps1   # ワンライナー全部入りインストール
├── setup.sh    / setup.ps1        # スキルを各エージェントに登録
├── skills/                        # スキル本体（23個）
└── templates/                     # 新規プロジェクトに流用できるテンプレート
    ├── scripts/                   # クロスプラットフォーム bootstrap & setup（sh + ps1）
    ├── .github/workflows/         # GitHub Pages デプロイ workflow
    └── agent-config/              # CLAUDE.md / AGENTS.md / GEMINI.md ひな形
```
