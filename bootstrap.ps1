# =============================================================================
# Coding-Agent Skills - ワンライナーセットアップ (Windows PowerShell)
# =============================================================================
#
# 使い方 (PowerShell に1行を貼り付けて Enter):
#
#   irm https://raw.githubusercontent.com/h2o-r/coding-agent-skills/main/bootstrap.ps1 | iex
#
# このスクリプトが自動で実行する内容:
#   1. Git, Node.js (>= 20), GitHub CLI のインストール
#   2. Claude Code, Gemini CLI, Codex CLI のインストール
#   3. このリポジトリを %USERPROFILE%\coding-agent-skills\ にクローン
#   4. setup.ps1 を実行して各エージェントにスキルを登録
# =============================================================================

$ErrorActionPreference = "Continue"

function Test-Cmd($name) { $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }
function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

$repoUrl    = "https://github.com/h2o-r/coding-agent-skills.git"
$installDir = Join-Path $env:USERPROFILE "coding-agent-skills"

Write-Host ""
Write-Host ("=" * 58) -ForegroundColor Blue
Write-Host "  Coding-Agent Skills - セットアップ" -ForegroundColor Cyan
Write-Host ("=" * 58) -ForegroundColor Blue
Write-Host ""

# --- WinGet check ---
if (-not (Test-Cmd "winget")) {
    Write-Host "  [!] WinGet が見つかりません。Microsoft Store から App Installer を入れてください:" -ForegroundColor Red
    Write-Host "      https://apps.microsoft.com/detail/9NBLGGH4NNS1" -ForegroundColor Yellow
    exit 1
}

# --- Git ---
if (Test-Cmd "git") {
    Write-Host "  [1/8] Git OK" -ForegroundColor Green
} else {
    Write-Host "  [1/8] Git をインストール中..." -ForegroundColor Cyan
    winget install --id Git.Git --accept-source-agreements --accept-package-agreements --silent
    Refresh-Path
}

# --- Node.js ---
$nodeOk = $false
if (Test-Cmd "node") {
    $major = [int]((node --version) -replace 'v(\d+)\..*','$1')
    if ($major -ge 20) { $nodeOk = $true }
}
if ($nodeOk) {
    Write-Host "  [2/8] Node.js OK" -ForegroundColor Green
} else {
    Write-Host "  [2/8] Node.js をインストール中..." -ForegroundColor Cyan
    winget install --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements --silent
    Refresh-Path
}

# --- GitHub CLI ---
if (Test-Cmd "gh") {
    Write-Host "  [3/8] GitHub CLI OK" -ForegroundColor Green
} else {
    Write-Host "  [3/8] GitHub CLI をインストール中..." -ForegroundColor Cyan
    winget install --id GitHub.cli --accept-source-agreements --accept-package-agreements --silent
    Refresh-Path
}

# --- Claude Code ---
if (Test-Cmd "claude") {
    Write-Host "  [4/8] Claude Code OK" -ForegroundColor Green
} else {
    Write-Host "  [4/8] Claude Code をインストール中..." -ForegroundColor Cyan
    try { irm https://claude.ai/install.ps1 | iex } catch {
        Write-Host "      (手動: irm https://claude.ai/install.ps1 | iex)" -ForegroundColor Yellow
    }
}

# --- Gemini CLI ---
if (Test-Cmd "gemini") {
    Write-Host "  [5/8] Gemini CLI OK" -ForegroundColor Green
} else {
    Write-Host "  [5/8] Gemini CLI をインストール中..." -ForegroundColor Cyan
    npm install -g @google/gemini-cli 2>$null
}

# --- Codex CLI ---
if (Test-Cmd "codex") {
    Write-Host "  [6/8] Codex CLI OK" -ForegroundColor Green
} else {
    Write-Host "  [6/8] Codex CLI をインストール中..." -ForegroundColor Cyan
    npm install -g @openai/codex 2>$null
}

# --- リポジトリ取得 ---
Write-Host "  [7/8] リポジトリを準備中..." -ForegroundColor Cyan
if (Test-Path (Join-Path $installDir ".git")) {
    Set-Location $installDir
    git pull --quiet origin main
} else {
    git clone --quiet $repoUrl $installDir
    Set-Location $installDir
}

# --- setup.ps1 実行 ---
Write-Host "  [8/8] スキルを各エージェントに登録中..." -ForegroundColor Cyan
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $installDir "setup.ps1") -All

# --- GitHub 認証（gh auth login）---
Write-Host ""
Write-Host ("=" * 58) -ForegroundColor Blue
Write-Host "  GitHub にサインイン" -ForegroundColor Cyan
Write-Host ("=" * 58) -ForegroundColor Blue
Write-Host ""
$null = & gh auth status 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] 既にサインイン済み" -ForegroundColor Green
    & gh auth status 2>&1 | ForEach-Object { Write-Host "     $_" }
} else {
    if ([Console]::IsInputRedirected -eq $false) {
        Write-Host "  [..] ブラウザで GitHub にサインインします..." -ForegroundColor Cyan
        Write-Host "  * HTTPS / web ブラウザ ログインを推奨" -ForegroundColor Yellow
        Write-Host ""
        & gh auth login --git-protocol https --web
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  * サインインがスキップされました。後ほど次のコマンドを実行してください:" -ForegroundColor Yellow
            Write-Host "       gh auth login" -ForegroundColor White
        }
    } else {
        Write-Host "  * 非対話モードのためサインインをスキップ。次のコマンドを手動で実行してください:" -ForegroundColor Yellow
        Write-Host "       gh auth login" -ForegroundColor White
    }
}

# --- 完了 ---
Write-Host ""
Write-Host ("=" * 58) -ForegroundColor Blue
Write-Host "  セットアップ完了！" -ForegroundColor Green
Write-Host ("=" * 58) -ForegroundColor Blue
Write-Host ""
Write-Host "  試してみる:" -ForegroundColor White
Write-Host ""
Write-Host "  1. " -ForegroundColor Cyan -NoNewline; Write-Host "好きなコーディングエージェントを起動:"
Write-Host "       claude    (Anthropic)" -ForegroundColor White
Write-Host "       gemini    (Google)"    -ForegroundColor White
Write-Host "       codex     (OpenAI)"    -ForegroundColor White
Write-Host ""
Write-Host "  2. " -ForegroundColor Cyan -NoNewline; Write-Host "はじめての一歩 — 新規 GitHub Pages サイトを作って公開:"
Write-Host "       /site-create my-first-site" -ForegroundColor White
Write-Host ""
Write-Host "  3. " -ForegroundColor Cyan -NoNewline; Write-Host "その他のスキル:"
Write-Host "       /agent-setup-check     # 環境ヘルスチェック" -ForegroundColor White
Write-Host "       /site-update ...       # サイト更新" -ForegroundColor White
Write-Host "       /weekly-report         # 週次レポート" -ForegroundColor White
Write-Host ""
Write-Host "  * 各エージェントの初回起動時にログインを求められます。画面の指示に従ってください。" -ForegroundColor Yellow
Write-Host ""
Write-Host "  リポジトリ: $installDir"
Write-Host ""
