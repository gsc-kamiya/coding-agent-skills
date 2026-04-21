#!/bin/bash
# =============================================================================
# Coding-Agent Project — One-Liner Bootstrap (macOS / Linux / WSL)
# =============================================================================
#
# Usage (paste a single line into your terminal):
#
#   curl -fsSL https://raw.githubusercontent.com/{ORG}/{REPO}/main/templates/scripts/bootstrap.sh | bash
#
# No prerequisites — installs Git / Homebrew / Node.js / GitHub CLI /
# Claude Code / Gemini CLI / Codex CLI, then clones the repo and installs
# project dependencies.
#
# Customize for your project: replace {ORG}, {REPO}, and INSTALL_DIR below.
# =============================================================================

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${CYAN}  Coding-Agent Project — Bootstrap${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Customize these for your project:
REPO_URL="https://github.com/{ORG}/{REPO}.git"
INSTALL_DIR="$HOME/{REPO}"

# --- Homebrew ---
if [[ "$(uname -s)" == "Darwin" ]]; then
  if ! command -v brew &>/dev/null; then
    echo -e "${CYAN}[1/10]${NC} Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
    fi
  else
    echo -e "${GREEN}[1/10]${NC} Homebrew ✓"
  fi
else
  echo -e "${GREEN}[1/10]${NC} Homebrew (skipped — Linux/WSL)"
fi

# --- Git ---
if ! command -v git &>/dev/null; then
  echo -e "${CYAN}[2/10]${NC} Installing Git..."
  if [[ "$(uname -s)" == "Darwin" ]]; then
    brew install git
  else
    sudo apt-get update -qq && sudo apt-get install -y -qq git
  fi
else
  echo -e "${GREEN}[2/10]${NC} Git ✓"
fi

# --- Node.js ---
if ! command -v node &>/dev/null || [ "$(node --version | sed 's/v//' | cut -d. -f1)" -lt 20 ]; then
  echo -e "${CYAN}[3/10]${NC} Installing Node.js..."
  if [[ "$(uname -s)" == "Darwin" ]]; then
    brew install node@22
  else
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y -qq nodejs
  fi
else
  echo -e "${GREEN}[3/10]${NC} Node.js $(node --version) ✓"
fi

# --- GitHub CLI ---
if ! command -v gh &>/dev/null; then
  echo -e "${CYAN}[4/10]${NC} Installing GitHub CLI..."
  if [[ "$(uname -s)" == "Darwin" ]]; then
    brew install gh
  else
    (type -p wget >/dev/null || (sudo apt-get update -qq && sudo apt-get install -y -qq wget)) \
      && sudo mkdir -p -m 755 /etc/apt/keyrings \
      && out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
      && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
      && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
      && sudo apt-get update -qq \
      && sudo apt-get install -y -qq gh
  fi
else
  echo -e "${GREEN}[4/10]${NC} GitHub CLI ✓"
fi

# --- Claude Code ---
if ! command -v claude &>/dev/null; then
  echo -e "${CYAN}[5/10]${NC} Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo -e "${GREEN}[5/10]${NC} Claude Code ✓"
fi

# --- Gemini CLI ---
if ! command -v gemini &>/dev/null; then
  echo -e "${CYAN}[6/10]${NC} Installing Gemini CLI..."
  npm install -g @google/gemini-cli 2>/dev/null
else
  echo -e "${GREEN}[6/10]${NC} Gemini CLI ✓"
fi

# --- Codex CLI ---
if ! command -v codex &>/dev/null; then
  echo -e "${CYAN}[7/10]${NC} Installing Codex CLI..."
  npm install -g @openai/codex 2>/dev/null
else
  echo -e "${GREEN}[7/10]${NC} Codex CLI ✓"
fi

# --- Repo clone & npm install ---
echo -e "${CYAN}[8/10]${NC} Setting up the project..."
if [ -d "$INSTALL_DIR/.git" ]; then
  cd "$INSTALL_DIR"
  git pull --quiet origin main
else
  git clone --quiet "$REPO_URL" "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi
npm install --silent

# --- Optional: Playwright browsers ---
if [ -f "playwright.config.ts" ] || [ -f "playwright.config.js" ]; then
  echo -e "${CYAN}[9/10]${NC} Installing Playwright browsers..."
  npx playwright install chromium 2>/dev/null
else
  echo -e "${GREEN}[9/10]${NC} Playwright (skipped — not used)"
fi

# --- Git user identity ---
GIT_USER_NAME=$(git config user.name 2>/dev/null || true)
GIT_USER_EMAIL=$(git config user.email 2>/dev/null || true)
if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
  echo -e "${GREEN}[10/10]${NC} Git user: $GIT_USER_NAME <$GIT_USER_EMAIL> ✓"
else
  echo -e "${CYAN}[10/10]${NC} Setting Git user identity..."
  read -p "  Your name: " INPUT_NAME
  read -p "  Your email: " INPUT_EMAIL
  git config --global user.name "$INPUT_NAME"
  git config --global user.email "$INPUT_EMAIL"
  echo -e "${GREEN}  ✓${NC} Git user set: $INPUT_NAME <$INPUT_EMAIL>"
fi

# --- Done ---
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  Bootstrap complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Two steps to get started:${NC}"
echo ""
echo -e "  ${CYAN}Step 1:${NC} cd into the project"
echo -e "         ${BOLD}cd $INSTALL_DIR${NC}"
echo ""
echo -e "  ${CYAN}Step 2:${NC} Launch any agent CLI"
echo -e "         ${BOLD}claude${NC}    (Anthropic)"
echo -e "         ${BOLD}gemini${NC}    (Google)"
echo -e "         ${BOLD}codex${NC}     (OpenAI)"
echo ""
echo -e "  Then try inside the agent:"
echo -e "  ${BOLD}/site-update Change the homepage hero${NC}"
echo ""
echo -e "  ${YELLOW}First-time launch will prompt for sign-in. Follow the on-screen steps.${NC}"
echo ""
