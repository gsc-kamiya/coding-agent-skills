# =============================================================================
# Coding-Agent Project - Development Environment Setup (Windows PowerShell)
# =============================================================================
#
# Usage (paste into PowerShell):
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; .\templates\scripts\setup.ps1
#
# This script will install / verify:
#   1. Git for Windows
#   2. Node.js (>= 20)
#   3. GitHub CLI
#   4. Claude Code (Anthropic)
#   5. Gemini CLI (Google)
#   6. Codex CLI (OpenAI)
#   7. Project dependencies (npm install)
#   8. Git user identity
# =============================================================================

$ErrorActionPreference = "Stop"

function Write-Header($text) {
    Write-Host ""
    Write-Host ("=" * 58) -ForegroundColor Blue
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host ("=" * 58) -ForegroundColor Blue
}
function Write-Step($text)    { Write-Host "  [OK] $text" -ForegroundColor Green }
function Write-Skip($text)    { Write-Host "  [->] $text (already installed)" -ForegroundColor Yellow }
function Write-Action($text)  { Write-Host "  [..] $text" -ForegroundColor Cyan }
function Write-Problem($text) { Write-Host "  [!!] $text" -ForegroundColor Red }
function Write-Notice($text)  { Write-Host "  [i]  $text" -ForegroundColor Yellow }
function Test-Command($name)  { $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

Write-Header "Coding-Agent Project Setup"
Write-Host ""
Write-Host "  This script will install the tools needed to update this project."
Write-Host "  You may be prompted for confirmation during installation."
Write-Host ""

# -----------------------------------------------------------------------------
# Step 1: Git for Windows
# -----------------------------------------------------------------------------
Write-Header "Step 1/8: Git for Windows"
if (Test-Command "git") {
    $gitVer = (git --version) -replace "git version ", ""
    Write-Skip "Git $gitVer"
} else {
    Write-Action "Installing Git for Windows via WinGet..."
    try {
        winget install --id Git.Git --accept-source-agreements --accept-package-agreements
        Refresh-Path
        Write-Step "Git installed"
    } catch {
        Write-Problem "WinGet failed. Install Git manually: https://git-scm.com/downloads/win"
    }
}

# -----------------------------------------------------------------------------
# Step 2: Node.js
# -----------------------------------------------------------------------------
Write-Header "Step 2/8: Node.js"
$nodeOk = $false
if (Test-Command "node") {
    $nodeVer = (node --version)
    $nodeMajor = [int]($nodeVer -replace "v(\d+)\..*", '$1')
    if ($nodeMajor -ge 20) { Write-Skip "Node.js $nodeVer"; $nodeOk = $true }
}
if (-not $nodeOk) {
    Write-Action "Installing Node.js LTS..."
    winget install --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
    Refresh-Path
    Write-Step "Node.js $(node --version) installed"
}

# -----------------------------------------------------------------------------
# Step 3: GitHub CLI
# -----------------------------------------------------------------------------
Write-Header "Step 3/8: GitHub CLI"
if (Test-Command "gh") {
    $ghVer = ((gh --version) | Select-Object -First 1) -replace "gh version (\S+).*", '$1'
    Write-Skip "GitHub CLI $ghVer"
} else {
    Write-Action "Installing GitHub CLI..."
    winget install --id GitHub.cli --accept-source-agreements --accept-package-agreements
    Refresh-Path
    Write-Step "GitHub CLI installed"
}

# -----------------------------------------------------------------------------
# Step 4: Claude Code
# -----------------------------------------------------------------------------
Write-Header "Step 4/8: Claude Code (Anthropic)"
if (Test-Command "claude") {
    Write-Skip "Claude Code $((claude --version 2>$null) -join ' ')"
} else {
    Write-Action "Installing Claude Code..."
    try {
        irm https://claude.ai/install.ps1 | iex
        Write-Step "Claude Code installed"
    } catch {
        Write-Problem "Claude Code install failed. Try manually: irm https://claude.ai/install.ps1 | iex"
    }
}

# -----------------------------------------------------------------------------
# Step 5: Gemini CLI
# -----------------------------------------------------------------------------
Write-Header "Step 5/8: Gemini CLI (Google)"
if (Test-Command "gemini") {
    Write-Skip "Gemini CLI $((gemini --version 2>$null) -join ' ')"
} else {
    Write-Action "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
    Write-Step "Gemini CLI installed"
}

# -----------------------------------------------------------------------------
# Step 6: Codex CLI
# -----------------------------------------------------------------------------
Write-Header "Step 6/8: Codex CLI (OpenAI)"
if (Test-Command "codex") {
    Write-Skip "Codex CLI $((codex --version 2>$null) -join ' ')"
} else {
    Write-Action "Installing Codex CLI..."
    npm install -g @openai/codex
    Write-Step "Codex CLI installed"
}

# -----------------------------------------------------------------------------
# Step 7: Project dependencies
# -----------------------------------------------------------------------------
Write-Header "Step 7/8: Project Dependencies"
if (Test-Path "package.json") {
    Write-Action "Running npm install..."
    npm install
    Write-Step "Dependencies installed"
} else {
    Write-Notice "Not in the project directory. Run 'npm install' after cloning the repo."
}

# -----------------------------------------------------------------------------
# Step 8: Git user identity
# -----------------------------------------------------------------------------
Write-Header "Step 8/8: Git User Identity"
$gitUserName  = git config user.name  2>$null
$gitUserEmail = git config user.email 2>$null
if ($gitUserName -and $gitUserEmail) {
    Write-Skip "Git user: $gitUserName <$gitUserEmail>"
} else {
    Write-Action "Setting Git user identity for commits"
    $inputName  = Read-Host "  Your name"
    $inputEmail = Read-Host "  Your email"
    git config --global user.name  "$inputName"
    git config --global user.email "$inputEmail"
    Write-Step "Git user set: $inputName <$inputEmail>"
}

Write-Header "Setup Complete!"
Write-Host ""
Write-Host "  All tools installed." -ForegroundColor Green
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host ""
Write-Host "  1." -ForegroundColor Cyan -NoNewline; Write-Host " Sign in to GitHub (if not already):"
Write-Host "     gh auth login" -ForegroundColor White
Write-Host ""
Write-Host "  2." -ForegroundColor Cyan -NoNewline; Write-Host " Launch any agent CLI:"
Write-Host "     claude" -ForegroundColor White -NoNewline; Write-Host "    (Anthropic)"
Write-Host "     gemini" -ForegroundColor White -NoNewline; Write-Host "    (Google)"
Write-Host "     codex"  -ForegroundColor White -NoNewline; Write-Host "     (OpenAI)"
Write-Host ""
Write-Host "  3." -ForegroundColor Cyan -NoNewline; Write-Host " Try a slash command:"
Write-Host "     /site-update Change the homepage hero" -ForegroundColor White
Write-Host ""
Write-Host "  * First-time launch will prompt for sign-in." -ForegroundColor Yellow
