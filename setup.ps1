# =============================================================================
# Coding-Agent Skills - インストールスクリプト (Windows PowerShell)
# =============================================================================
#
# このリポジトリの skills/ を、検出した各エージェント CLI の所定ディレクトリに
# リンクします。対応エージェント:
#
#   - Claude Code (Anthropic) -> %USERPROFILE%\.claude\skills\<name>\SKILL.md
#   - Gemini CLI (Google)     -> %USERPROFILE%\.gemini\commands\<name>.toml (生成)
#   - Codex CLI (OpenAI)      -> %USERPROFILE%\.codex\prompts\<name>.md     (コピー)
#
# 使い方 (PowerShell):
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; .\setup.ps1
#   .\setup.ps1 -All
#   .\setup.ps1 -Agents claude,gemini
# =============================================================================

[CmdletBinding()]
param(
    [string[]]$Agents = @(),
    [switch]$All
)

$ErrorActionPreference = "Stop"

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SkillsSrc   = Join-Path $ScriptDir "skills"

function Write-Header($text) {
    Write-Host ""
    Write-Host ("=" * 58) -ForegroundColor Blue
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host ("=" * 58) -ForegroundColor Blue
}
function Write-Ok($text)    { Write-Host "  [OK] $text" -ForegroundColor Green }
function Write-SkipMsg($t)  { Write-Host "  [->] $t" -ForegroundColor Yellow }
function Write-Step($text)  { Write-Host "  [..] $text" -ForegroundColor Cyan }
function Write-Warn2($text) { Write-Host "  [!]  $text" -ForegroundColor Yellow }
function Test-Cmd($name)    { $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }

# ---- Agent selection ----
$installClaude = $false
$installGemini = $false
$installCodex  = $false

if ($All) {
    $installClaude = $true; $installGemini = $true; $installCodex = $true
} elseif ($Agents.Count -gt 0) {
    foreach ($a in $Agents) {
        switch ($a.ToLower()) {
            "claude" { $installClaude = $true }
            "gemini" { $installGemini = $true }
            "codex"  { $installCodex  = $true }
            default  { Write-Warn2 "Unknown agent: $a"; exit 1 }
        }
    }
} else {
    # Auto-detect
    if (Test-Cmd "claude") { $installClaude = $true }
    if (Test-Cmd "gemini") { $installGemini = $true }
    if (Test-Cmd "codex")  { $installCodex  = $true }
    if (-not ($installClaude -or $installGemini -or $installCodex)) {
        Write-Step "Agent CLI が未検出のため、3エージェントすべての場所に登録します"
        $installClaude = $true; $installGemini = $true; $installCodex = $true
    }
}

Write-Header "Coding-Agent Skills - インストール"
Write-Host ""
Write-Host "  リポジトリ: $ScriptDir"
$skillCount = (Get-ChildItem -Path $SkillsSrc -Directory).Count
Write-Host "  対象スキル数: $skillCount"
Write-Host "  インストール先:"
if ($installClaude) { Write-Host "    - Claude Code  (~\.claude\skills\)" }
if ($installGemini) { Write-Host "    - Gemini CLI   (~\.gemini\commands\)" }
if ($installCodex)  { Write-Host "    - Codex CLI    (~\.codex\prompts\)" }

# シンボリックリンクの作成可否を判定 (Win10 Developer Mode または管理者権限が必要)
function Try-SymLink {
    param([string]$Source, [string]$Target)
    try {
        New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
        return $true
    } catch {
        return $false
    }
}

# =============================================================================
# Claude Code
# =============================================================================
if ($installClaude) {
    Write-Header "Claude Code"
    $claudeRoot = Join-Path $env:USERPROFILE ".claude"
    $claudeDst  = Join-Path $claudeRoot   "skills"
    if (-not (Test-Path $claudeRoot)) { New-Item -ItemType Directory -Path $claudeRoot | Out-Null }

    if (Test-Path $claudeDst) {
        $item = Get-Item $claudeDst -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $current = $item.Target
            if ($current -eq $SkillsSrc -or $current -eq @($SkillsSrc)) {
                Write-SkipMsg "既にリンク済み: $claudeDst"
            } else {
                Write-Step "既存リンクを更新: $current -> $SkillsSrc"
                Remove-Item $claudeDst -Force -Recurse
                if (Try-SymLink -Source $SkillsSrc -Target $claudeDst) {
                    Write-Ok "リンク作成: $claudeDst"
                } else {
                    Write-Step "シンボリックリンク作成不可。コピーで代替"
                    Copy-Item -Path $SkillsSrc -Destination $claudeDst -Recurse
                    Write-Ok "コピー完了: $claudeDst"
                }
            }
        } else {
            $backup = "$claudeDst.bak.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Write-Step "既存ディレクトリをバックアップ: $backup"
            Move-Item $claudeDst $backup
            if (Try-SymLink -Source $SkillsSrc -Target $claudeDst) {
                Write-Ok "リンク作成: $claudeDst"
            } else {
                Copy-Item -Path $SkillsSrc -Destination $claudeDst -Recurse
                Write-Ok "コピー完了: $claudeDst"
            }
        }
    } else {
        if (Try-SymLink -Source $SkillsSrc -Target $claudeDst) {
            Write-Ok "リンク作成: $claudeDst"
        } else {
            Write-Step "シンボリックリンク作成不可 (Developer Mode 未有効/権限なし)。コピーで代替"
            Copy-Item -Path $SkillsSrc -Destination $claudeDst -Recurse
            Write-Ok "コピー完了: $claudeDst"
        }
    }
}

# =============================================================================
# Gemini CLI: 各 SKILL.md から TOML を生成
# =============================================================================
if ($installGemini) {
    Write-Header "Gemini CLI"
    $geminiDst = Join-Path $env:USERPROFILE ".gemini\commands"
    if (-not (Test-Path $geminiDst)) { New-Item -ItemType Directory -Path $geminiDst -Force | Out-Null }

    $count = 0
    foreach ($dir in (Get-ChildItem -Path $SkillsSrc -Directory)) {
        $src = $null
        if (Test-Path (Join-Path $dir.FullName "SKILL.md")) { $src = Join-Path $dir.FullName "SKILL.md" }
        elseif (Test-Path (Join-Path $dir.FullName "skill.md")) { $src = Join-Path $dir.FullName "skill.md" }
        if (-not $src) { continue }

        $content = Get-Content $src -Raw -Encoding UTF8
        # フロントマターから description を抽出
        $desc = $dir.Name
        if ($content -match "(?ms)^description:\s*(.+?)$") {
            $desc = $Matches[1].Trim()
            $desc = $desc -replace '^["'']', '' -replace '["'']$', ''
        }
        $descEscaped = $desc -replace '\\', '\\\\' -replace '"', '\"'

        $out = Join-Path $geminiDst ($dir.Name + ".toml")
        # 本文に ''' が含まれていれば basic multi-line string にフォールバック (\ と """ をエスケープ)。
        # 含まれていなければ literal multi-line string (''' ... ''') を使い、\ も """ もそのまま埋め込める。
        if ($content -like "*'''*") {
            $escBody = $content -replace '\\', '\\\\' -replace '"""', '\"\"\"'
            $toml = @"
description = "$descEscaped"

prompt = """
$escBody
"""
"@
        } else {
            $toml = @"
description = "$descEscaped"

prompt = '''
$content
'''
"@
        }
        Set-Content -Path $out -Value $toml -Encoding UTF8
        $count++
    }
    Write-Ok "$count 件の TOML を生成: $geminiDst"
}

# =============================================================================
# Codex CLI: <name>.md をシンボリックリンク (失敗時はコピー)
# =============================================================================
if ($installCodex) {
    Write-Header "Codex CLI"
    $codexDst = Join-Path $env:USERPROFILE ".codex\prompts"
    if (-not (Test-Path $codexDst)) { New-Item -ItemType Directory -Path $codexDst -Force | Out-Null }

    $count = 0
    foreach ($dir in (Get-ChildItem -Path $SkillsSrc -Directory)) {
        $src = $null
        if (Test-Path (Join-Path $dir.FullName "SKILL.md")) { $src = Join-Path $dir.FullName "SKILL.md" }
        elseif (Test-Path (Join-Path $dir.FullName "skill.md")) { $src = Join-Path $dir.FullName "skill.md" }
        if (-not $src) { continue }

        $out = Join-Path $codexDst ($dir.Name + ".md")
        if (Test-Path $out) { Remove-Item $out -Force }
        if (-not (Try-SymLink -Source $src -Target $out)) {
            Copy-Item -Path $src -Destination $out -Force
        }
        $count++
    }
    Write-Ok "$count 件のリンク/コピーを作成: $codexDst"
}

# =============================================================================
# 完了
# =============================================================================
Write-Header "セットアップ完了"
Write-Host ""
Write-Host "  利用可能なスキル:"
foreach ($dir in (Get-ChildItem -Path $SkillsSrc -Directory)) {
    Write-Host "    /$($dir.Name)"
}
Write-Host ""
Write-Host "  各エージェント起動後、上記スラッシュコマンドで呼び出せます:"
if ($installClaude) { Write-Host "    claude を起動 -> /<skill-name>" -ForegroundColor White }
if ($installGemini) { Write-Host "    gemini を起動 -> /<skill-name>" -ForegroundColor White }
if ($installCodex)  { Write-Host "    codex  を起動 -> /<skill-name>" -ForegroundColor White }
Write-Host ""
if ($installGemini) {
    Write-Warn2 "Gemini CLI 用の TOML はスキル更新時 (git pull 後) に再生成してください:"
    Write-Host  "  .\setup.ps1 -Agents gemini" -ForegroundColor Yellow
    Write-Host ""
}
