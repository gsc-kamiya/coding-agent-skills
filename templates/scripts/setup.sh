#!/bin/bash
# =============================================================================
# Coding-Agent Project — Development Environment Setup (POSIX)
# =============================================================================
#
# Usage (paste into a terminal):
#   bash templates/scripts/setup.sh
#
# Or, if the repo isn't cloned yet:
#   bash <(curl -fsSL https://raw.githubusercontent.com/{ORG}/{REPO}/main/templates/scripts/setup.sh)
#
# This script will install / verify:
#   1. Homebrew (macOS only)
#   2. Node.js (>= 20)
#   3. GitHub CLI
#   4. Claude Code (Anthropic)
#   5. Gemini CLI (Google)
#   6. Codex CLI (OpenAI)
#   7. Project dependencies (npm install)
#   8. Git user identity
# =============================================================================

set -e

# ---- color helpers ----
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${CYAN}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}
print_step()   { echo -e "${GREEN}  ✓${NC} $1"; }
print_skip()   { echo -e "${YELLOW}  →${NC} $1 (already installed)"; }
print_action() { echo -e "${CYAN}  ▶${NC} $1"; }
print_info()   { echo -e "${YELLOW}  ℹ${NC} $1"; }
print_error()  { echo -e "${RED}  ✗${NC} $1"; }

detect_os() {
  case "$(uname -s)" in
    Darwin*) echo "macos" ;;
    Linux*)  echo "linux" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *) echo "unknown" ;;
  esac
}
OS=$(detect_os)

print_header "Coding-Agent Project Setup"
echo ""
echo "  This script will install the tools needed to update this project."
echo "  You may be asked for your password during installation."
echo ""

# -----------------------------------------------------------------------------
# Step 1: Homebrew (macOS only)
# -----------------------------------------------------------------------------
if [ "$OS" = "macos" ]; then
  print_header "Step 1/8: Homebrew"
  if command -v brew &>/dev/null; then
    print_skip "Homebrew $(brew --version | head -1 | awk '{print $2}')"
  else
    print_action "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    print_step "Homebrew installed"
  fi
else
  print_header "Step 1/8: Homebrew (skipped — non-macOS)"
  print_info "Will use the system package manager (apt / dnf) where available"
fi

# -----------------------------------------------------------------------------
# Step 2: Node.js
# -----------------------------------------------------------------------------
print_header "Step 2/8: Node.js"
NODE_OK=false
if command -v node &>/dev/null; then
  NODE_VERSION=$(node --version)
  NODE_MAJOR=$(echo "$NODE_VERSION" | sed 's/v//' | cut -d. -f1)
  if [ "$NODE_MAJOR" -ge 20 ]; then
    print_skip "Node.js $NODE_VERSION"
    NODE_OK=true
  fi
fi
if [ "$NODE_OK" = false ]; then
  print_action "Installing Node.js 22..."
  if [ "$OS" = "macos" ]; then
    brew install node@22
  else
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi
  print_step "Node.js $(node --version) installed"
fi

# -----------------------------------------------------------------------------
# Step 3: GitHub CLI
# -----------------------------------------------------------------------------
print_header "Step 3/8: GitHub CLI"
if command -v gh &>/dev/null; then
  print_skip "GitHub CLI $(gh --version | head -1 | awk '{print $3}')"
else
  print_action "Installing GitHub CLI..."
  if [ "$OS" = "macos" ]; then
    brew install gh
  else
    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
      && sudo mkdir -p -m 755 /etc/apt/keyrings \
      && out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
      && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
      && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
      && sudo apt update \
      && sudo apt install gh -y
  fi
  print_step "GitHub CLI $(gh --version | head -1 | awk '{print $3}') installed"
fi

# -----------------------------------------------------------------------------
# Step 4: Claude Code
# -----------------------------------------------------------------------------
print_header "Step 4/8: Claude Code (Anthropic)"
if command -v claude &>/dev/null; then
  print_skip "Claude Code $(claude --version 2>/dev/null || echo '(version unknown)')"
else
  print_action "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
  print_step "Claude Code installed"
fi

# -----------------------------------------------------------------------------
# Step 5: Gemini CLI
# -----------------------------------------------------------------------------
print_header "Step 5/8: Gemini CLI (Google)"
if command -v gemini &>/dev/null; then
  print_skip "Gemini CLI $(gemini --version 2>/dev/null || echo '(version unknown)')"
else
  print_action "Installing Gemini CLI..."
  npm install -g @google/gemini-cli
  print_step "Gemini CLI installed"
fi

# -----------------------------------------------------------------------------
# Step 6: Codex CLI
# -----------------------------------------------------------------------------
print_header "Step 6/8: Codex CLI (OpenAI)"
if command -v codex &>/dev/null; then
  print_skip "Codex CLI $(codex --version 2>/dev/null || echo '(version unknown)')"
else
  print_action "Installing Codex CLI..."
  npm install -g @openai/codex
  print_step "Codex CLI installed"
fi

# -----------------------------------------------------------------------------
# Step 7: Project dependencies
# -----------------------------------------------------------------------------
print_header "Step 7/8: Project dependencies"
if [ -f "package.json" ]; then
  print_action "Running npm install..."
  npm install
  print_step "Project dependencies installed"
else
  print_info "Run this script from the project root after cloning the repo"
fi

# -----------------------------------------------------------------------------
# Step 8: Git user identity
# -----------------------------------------------------------------------------
print_header "Step 8/8: Git user identity"
GIT_USER_NAME=$(git config user.name 2>/dev/null || true)
GIT_USER_EMAIL=$(git config user.email 2>/dev/null || true)
if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
  print_skip "Git user: $GIT_USER_NAME <$GIT_USER_EMAIL>"
else
  print_action "Setting Git user identity for commits"
  read -p "  Your name: " INPUT_NAME
  read -p "  Your email: " INPUT_EMAIL
  git config --global user.name "$INPUT_NAME"
  git config --global user.email "$INPUT_EMAIL"
  print_step "Git user set: $INPUT_NAME <$INPUT_EMAIL>"
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
print_header "Setup complete!"
echo ""
echo -e "  ${GREEN}All tools installed.${NC}"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} Sign in to GitHub (if you haven't):"
echo -e "     ${BOLD}gh auth login${NC}"
echo ""
echo -e "  ${CYAN}2.${NC} Launch your favorite agent CLI:"
echo -e "     ${BOLD}claude${NC}    (Anthropic)"
echo -e "     ${BOLD}gemini${NC}    (Google)"
echo -e "     ${BOLD}codex${NC}     (OpenAI)"
echo ""
echo -e "  ${CYAN}3.${NC} Inside the agent, try a slash command:"
echo -e "     ${BOLD}/site-update Change the homepage hero${NC}"
echo ""
echo -e "  ${YELLOW}First-time agent launch will prompt for sign-in. Follow the on-screen steps.${NC}"
echo ""
