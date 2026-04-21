#!/bin/bash
# =============================================================================
# Coding-Agent Skills - ワンライナーセットアップ (macOS / Linux / WSL)
# =============================================================================
#
# 使い方 (ターミナルにこの1行を貼り付けて Enter):
#
#   curl -fsSL https://raw.githubusercontent.com/gsc-kamiya/coding-agent-skills/main/bootstrap.sh | bash
#
# このスクリプトが自動で実行する内容:
#   1. Git, Node.js (>= 20), GitHub CLI のインストール
#   2. Claude Code, Gemini CLI, Codex CLI のインストール
#   3. このリポジトリを ~/coding-agent-skills/ にクローン
#   4. setup.sh を実行して各エージェントにスキルを登録
# =============================================================================

set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BLUE='\033[0;34m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${CYAN}  Coding-Agent Skills - セットアップ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

REPO_URL="https://github.com/gsc-kamiya/coding-agent-skills.git"
INSTALL_DIR="$HOME/coding-agent-skills"

# --- Homebrew (macOS) ---
if [[ "$(uname -s)" == "Darwin" ]]; then
  if ! command -v brew &>/dev/null; then
    echo -e "${CYAN}[1/8]${NC} Homebrew をインストール中..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
    fi
  else
    echo -e "${GREEN}[1/8]${NC} Homebrew ✓"
  fi
else
  echo -e "${GREEN}[1/8]${NC} Homebrew (Linux のためスキップ)"
fi

# --- Git ---
if ! command -v git &>/dev/null; then
  echo -e "${CYAN}[2/8]${NC} Git をインストール中..."
  if [[ "$(uname -s)" == "Darwin" ]]; then brew install git
  else sudo apt-get update -qq && sudo apt-get install -y -qq git
  fi
else
  echo -e "${GREEN}[2/8]${NC} Git ✓"
fi

# --- Node.js (>= 20) ---
if ! command -v node &>/dev/null || [ "$(node --version | sed 's/v//' | cut -d. -f1)" -lt 20 ]; then
  echo -e "${CYAN}[3/8]${NC} Node.js をインストール中..."
  if [[ "$(uname -s)" == "Darwin" ]]; then brew install node@22
  else
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y -qq nodejs
  fi
else
  echo -e "${GREEN}[3/8]${NC} Node.js $(node --version) ✓"
fi

# --- GitHub CLI ---
if ! command -v gh &>/dev/null; then
  echo -e "${CYAN}[4/8]${NC} GitHub CLI をインストール中..."
  if [[ "$(uname -s)" == "Darwin" ]]; then brew install gh
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
  echo -e "${GREEN}[4/8]${NC} GitHub CLI ✓"
fi

# --- Claude Code ---
if ! command -v claude &>/dev/null; then
  echo -e "${CYAN}[5/8]${NC} Claude Code をインストール中..."
  curl -fsSL https://claude.ai/install.sh | bash || echo -e "  ${YELLOW}(手動インストールが必要かもしれません)${NC}"
else
  echo -e "${GREEN}[5/8]${NC} Claude Code ✓"
fi

# --- Gemini CLI ---
if ! command -v gemini &>/dev/null; then
  echo -e "${CYAN}[6/8]${NC} Gemini CLI をインストール中..."
  npm install -g @google/gemini-cli 2>/dev/null || echo -e "  ${YELLOW}(npm 権限エラーの可能性: sudo npm install -g @google/gemini-cli)${NC}"
else
  echo -e "${GREEN}[6/8]${NC} Gemini CLI ✓"
fi

# --- Codex CLI ---
if ! command -v codex &>/dev/null; then
  echo -e "${CYAN}[7/8]${NC} Codex CLI をインストール中..."
  npm install -g @openai/codex 2>/dev/null || echo -e "  ${YELLOW}(npm 権限エラーの可能性: sudo npm install -g @openai/codex)${NC}"
else
  echo -e "${GREEN}[7/8]${NC} Codex CLI ✓"
fi

# --- リポジトリ取得 + setup 実行 ---
echo -e "${CYAN}[8/8]${NC} スキルをインストール中..."
if [ -d "$INSTALL_DIR/.git" ]; then
  cd "$INSTALL_DIR"
  git pull --quiet origin main
else
  git clone --quiet "$REPO_URL" "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi
bash setup.sh --all

# --- GitHub 認証（gh auth login）---
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${CYAN}  GitHub にサインイン${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
if gh auth status >/dev/null 2>&1; then
  echo -e "  ${GREEN}✓${NC} 既にサインイン済み"
  gh auth status 2>&1 | sed 's/^/     /'
else
  if [ -t 0 ]; then
    # 対話可能な端末なら gh auth login を起動
    echo -e "  ${CYAN}▶${NC} ブラウザで GitHub にサインインします..."
    echo -e "  ${YELLOW}※ HTTPS / web ブラウザ ログインを推奨${NC}"
    echo ""
    gh auth login --git-protocol https --web || {
      echo -e "  ${YELLOW}※ サインインがスキップされました。後ほど次のコマンドを実行してください:${NC}"
      echo -e "       ${BOLD}gh auth login${NC}"
    }
  else
    # curl|bash 等で stdin が無い場合はスキップ
    echo -e "  ${YELLOW}※ 非対話モードのためサインインをスキップ。次のコマンドを手動で実行してください:${NC}"
    echo -e "       ${BOLD}gh auth login${NC}"
  fi
fi

# --- 完了 ---
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  セットアップ完了！${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}試してみる:${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} 好きなコーディングエージェントを起動:"
echo -e "       ${BOLD}claude${NC}    (Anthropic)"
echo -e "       ${BOLD}gemini${NC}    (Google)"
echo -e "       ${BOLD}codex${NC}     (OpenAI)"
echo ""
echo -e "  ${CYAN}2.${NC} はじめての一歩 — 新規 GitHub Pages サイトを作って公開:"
echo -e "       ${BOLD}/site-create my-first-site${NC}"
echo ""
echo -e "  ${CYAN}3.${NC} その他のスキル:"
echo -e "       ${BOLD}/agent-setup-check${NC}     # 環境ヘルスチェック"
echo -e "       ${BOLD}/site-update ...${NC}       # サイト更新"
echo -e "       ${BOLD}/weekly-report${NC}         # 週次レポート"
echo ""
echo -e "  ${YELLOW}※ 各エージェントの初回起動時にログインを求められます。画面の指示に従ってください。${NC}"
echo ""
echo -e "  リポジトリ: $INSTALL_DIR"
echo ""
