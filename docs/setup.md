# セットアップ詳細

ワンライナーのセットアップ手順は [README](../README.md) を参照してください。本ドキュメントは動作の仕組み・個別インストール・Windows 固有の注意点をまとめています。

## 動作の仕組み

`setup.sh` / `setup.ps1` は、検出した各エージェントの所定ディレクトリに同じスキル群を登録します:

| エージェント | 登録先 | 形式 |
|:--|:--|:--|
| **Claude Code** | `~/.claude/skills/<name>/SKILL.md` | リポの `skills/` ディレクトリへのシンボリックリンク（自動更新） |
| **Gemini CLI** | `~/.gemini/commands/<name>.toml` | 各 `SKILL.md` から TOML を生成（更新時は再実行が必要） |
| **Codex CLI** | `~/.codex/prompts/<name>.md` | 各 `SKILL.md` へのシンボリックリンク（自動更新） |

> **Gemini CLI の更新**: スキルを `git pull` で更新したら、`bash setup.sh gemini`（Windows: `.\setup.ps1 -Agents gemini`）で TOML を再生成してください。Claude / Codex はシンボリックリンクなので自動反映されます。

## 個別インストール（既にエージェント CLI を導入済みの場合）

```bash
git clone https://github.com/h2o-r/coding-agent-skills.git ~/coding-agent-skills
cd ~/coding-agent-skills

# macOS / Linux
bash setup.sh           # インストール済みエージェントを自動検出
bash setup.sh --all     # 3 エージェント全部に登録
bash setup.sh claude    # Claude のみ
bash setup.sh gemini    # Gemini のみ
bash setup.sh codex     # Codex のみ

# Windows
.\setup.ps1                       # 自動検出
.\setup.ps1 -All                  # 全部
.\setup.ps1 -Agents claude,gemini # 個別指定
```

## Windows シンボリックリンクについて

Windows でシンボリックリンクを作るには **Developer Mode** または **管理者 PowerShell** が必要です。

通常モードでも `setup.ps1` は動きますが、その場合は自動的に「コピー」にフォールバックします（`git pull` 後に再実行が必要）。

**Developer Mode 有効化**: 「設定 → プライバシーとセキュリティ → 開発者向け」→ Developer Mode を ON

## アップデート

```bash
cd ~/coding-agent-skills
git pull

# Gemini を使っている場合のみ TOML を再生成（Claude/Codex はシンボリックリンクなので自動反映）
bash setup.sh gemini       # macOS / Linux
.\setup.ps1 -Agents gemini # Windows
```

## 複数 GitHub アカウントの使い分け

複数の Claude Code インスタンスを同時に動かす場合、グローバル切替の `gh auth switch` ではなく、ターミナルごとに `GH_TOKEN` を使ってください:

```bash
# NG: 他のターミナルにも影響する
gh auth switch --user my-account

# OK: このターミナルだけに影響する
export GH_TOKEN=$(gh auth token --user my-account)
git push origin main
```
