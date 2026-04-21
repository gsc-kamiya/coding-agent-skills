#!/bin/bash
# =============================================================================
# Coding-Agent Skills - インストールスクリプト (POSIX)
# =============================================================================
#
# このリポジトリの skills/ を、検出した各エージェント CLI の所定ディレクトリに
# リンクします。対応エージェント:
#
#   - Claude Code (Anthropic) → ~/.claude/skills/<name>/SKILL.md
#   - Gemini CLI (Google)     → ~/.gemini/commands/<name>.toml (生成)
#   - Codex CLI (OpenAI)      → ~/.codex/prompts/<name>.md     (シンボリックリンク)
#
# 使い方:
#   bash setup.sh           # インストール済みのエージェントを自動検出
#   bash setup.sh --all     # 検出に関わらず3エージェント分すべて作成
#   bash setup.sh claude    # Claude のみ
#   bash setup.sh gemini    # Gemini のみ
#   bash setup.sh codex     # Codex のみ
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="${SCRIPT_DIR}/skills"

# ---- color helpers ----
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BLUE='\033[0;34m'; RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'

print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${CYAN}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}
print_ok()    { echo -e "  ${GREEN}✓${NC} $1"; }
print_skip()  { echo -e "  ${YELLOW}→${NC} $1"; }
print_info()  { echo -e "  ${CYAN}▶${NC} $1"; }
print_err()   { echo -e "  ${RED}✗${NC} $1"; }

# ---- 引数解析 ----
INSTALL_CLAUDE=0
INSTALL_GEMINI=0
INSTALL_CODEX=0
FORCE_ALL=0

if [ $# -eq 0 ]; then
  AUTO=1
else
  AUTO=0
  for arg in "$@"; do
    case "$arg" in
      --all|-a) FORCE_ALL=1 ;;
      claude)   INSTALL_CLAUDE=1 ;;
      gemini)   INSTALL_GEMINI=1 ;;
      codex)    INSTALL_CODEX=1 ;;
      -h|--help)
        sed -n '2,18p' "$0"
        exit 0
        ;;
      *) print_err "Unknown option: $arg"; exit 1 ;;
    esac
  done
fi

if [ "$FORCE_ALL" -eq 1 ]; then
  INSTALL_CLAUDE=1; INSTALL_GEMINI=1; INSTALL_CODEX=1
fi

if [ "$AUTO" -eq 1 ]; then
  command -v claude  >/dev/null 2>&1 && INSTALL_CLAUDE=1
  command -v gemini  >/dev/null 2>&1 && INSTALL_GEMINI=1
  command -v codex   >/dev/null 2>&1 && INSTALL_CODEX=1
  if [ "$INSTALL_CLAUDE" -eq 0 ] && [ "$INSTALL_GEMINI" -eq 0 ] && [ "$INSTALL_CODEX" -eq 0 ]; then
    print_info "コーディングエージェント CLI が見つからなかったため、3エージェントすべての場所に登録します"
    INSTALL_CLAUDE=1; INSTALL_GEMINI=1; INSTALL_CODEX=1
  fi
fi

print_header "Coding-Agent Skills - インストール"
echo ""
echo "  リポジトリ: ${SCRIPT_DIR}"
echo "  対象スキル数: $(find "${SKILLS_SRC}" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
echo "  インストール先:"
[ "$INSTALL_CLAUDE" -eq 1 ] && echo "    - Claude Code  (~/.claude/skills/)"
[ "$INSTALL_GEMINI" -eq 1 ] && echo "    - Gemini CLI   (~/.gemini/commands/)"
[ "$INSTALL_CODEX"  -eq 1 ] && echo "    - Codex CLI    (~/.codex/prompts/)"

# =============================================================================
# Claude Code: ~/.claude/skills/ をリポジトリの skills/ ディレクトリへ
# シンボリックリンク。元から存在すればバックアップ。
# =============================================================================
if [ "$INSTALL_CLAUDE" -eq 1 ]; then
  print_header "Claude Code"
  CLAUDE_DST="${HOME}/.claude/skills"
  mkdir -p "${HOME}/.claude"

  if [ -e "${CLAUDE_DST}" ] && [ ! -L "${CLAUDE_DST}" ]; then
    BACKUP="${CLAUDE_DST}.bak.$(date +%Y%m%d_%H%M%S)"
    print_info "既存ディレクトリをバックアップ: ${BACKUP}"
    mv "${CLAUDE_DST}" "${BACKUP}"
    ln -s "${SKILLS_SRC}" "${CLAUDE_DST}"
    print_ok "リンク作成: ${CLAUDE_DST} → ${SKILLS_SRC}"
  elif [ -L "${CLAUDE_DST}" ]; then
    CURRENT_TARGET="$(readlink "${CLAUDE_DST}")"
    if [ "${CURRENT_TARGET}" = "${SKILLS_SRC}" ]; then
      print_skip "既にリンク済み: ${CLAUDE_DST}"
    else
      print_info "既存シンボリックリンクを更新: ${CURRENT_TARGET} → ${SKILLS_SRC}"
      rm "${CLAUDE_DST}"
      ln -s "${SKILLS_SRC}" "${CLAUDE_DST}"
      print_ok "リンク更新: ${CLAUDE_DST} → ${SKILLS_SRC}"
    fi
  else
    ln -s "${SKILLS_SRC}" "${CLAUDE_DST}"
    print_ok "リンク作成: ${CLAUDE_DST} → ${SKILLS_SRC}"
  fi
fi

# =============================================================================
# Gemini CLI: ~/.gemini/commands/<name>.toml を各スキルから生成。
# Gemini CLI のカスタムコマンドは TOML 形式 (description + prompt) のため、
# SKILL.md の本文を TOML に埋め込む。
# =============================================================================
if [ "$INSTALL_GEMINI" -eq 1 ]; then
  print_header "Gemini CLI"
  GEMINI_DST="${HOME}/.gemini/commands"
  mkdir -p "${GEMINI_DST}"

  GENERATED=0; SKIPPED=0
  for skill_dir in "${SKILLS_SRC}"/*/; do
    skill_name="$(basename "${skill_dir}")"
    src_file=""
    [ -f "${skill_dir}SKILL.md" ] && src_file="${skill_dir}SKILL.md"
    [ -f "${skill_dir}skill.md" ] && src_file="${skill_dir}skill.md"
    [ -z "$src_file" ] && continue

    out="${GEMINI_DST}/${skill_name}.toml"

    # フロントマターから description を抽出（無ければスキル名で代用）
    desc=$(awk '/^description:/{sub(/^description: */,""); gsub(/^"|"$/,""); print; exit}' "$src_file" 2>/dev/null || true)
    [ -z "$desc" ] && desc="${skill_name} skill"
    # TOML 三重引用符に干渉する場合に備えてバックスラッシュとダブルクォートのみエスケープ
    desc_escaped=$(printf '%s' "$desc" | sed 's/\\/\\\\/g; s/"/\\"/g')

    # 本文に '''  が含まれているとリテラル multi-line string が壊れるため、その場合のみエスケープ用に basic string を使う。
    # 通常のスキルは '''  を含まないので、リテラル文字列で `\` も `"""` もそのまま埋め込めるルートを優先する。
    if grep -qF "'''" "$src_file"; then
      # フォールバック: basic multi-line string + '\' / '"""' をエスケープ
      esc_body=$(sed -e 's/\\/\\\\/g' -e 's/"""/\\"\\"\\"/g' "$src_file")
      {
        printf 'description = "%s"\n\n' "$desc_escaped"
        printf 'prompt = """\n%s\n"""\n' "$esc_body"
      } > "$out"
    else
      # 標準: TOML literal multi-line string ('''...''')
      # — '\' のエスケープ不要、`"""` も含められる。
      {
        printf 'description = "%s"\n\n' "$desc_escaped"
        printf "prompt = '''\n"
        cat "$src_file"
        printf "\n'''\n"
      } > "$out"
    fi
    GENERATED=$((GENERATED+1))
  done
  print_ok "${GENERATED} 件の TOML を生成: ${GEMINI_DST}"
fi

# =============================================================================
# Codex CLI: ~/.codex/prompts/<name>.md を各 SKILL.md へシンボリックリンク。
# =============================================================================
if [ "$INSTALL_CODEX" -eq 1 ]; then
  print_header "Codex CLI"
  CODEX_DST="${HOME}/.codex/prompts"
  mkdir -p "${CODEX_DST}"

  LINKED=0
  for skill_dir in "${SKILLS_SRC}"/*/; do
    skill_name="$(basename "${skill_dir}")"
    src_file=""
    [ -f "${skill_dir}SKILL.md" ] && src_file="${skill_dir}SKILL.md"
    [ -f "${skill_dir}skill.md" ] && src_file="${skill_dir}skill.md"
    [ -z "$src_file" ] && continue

    out="${CODEX_DST}/${skill_name}.md"
    if [ -L "$out" ] || [ -f "$out" ]; then
      rm -f "$out"
    fi
    ln -s "$src_file" "$out"
    LINKED=$((LINKED+1))
  done
  print_ok "${LINKED} 件のリンクを作成: ${CODEX_DST}"
fi

# =============================================================================
# 完了
# =============================================================================
print_header "セットアップ完了"
echo ""
echo "  利用可能なスキル:"
for skill_dir in "${SKILLS_SRC}"/*/; do
  skill_name="$(basename "${skill_dir}")"
  echo "    /${skill_name}"
done
echo ""
echo "  各エージェントの起動後、上記スラッシュコマンドで呼び出せます:"
[ "$INSTALL_CLAUDE" -eq 1 ] && echo -e "    ${BOLD}claude${NC} を起動 → /${skill_name}"
[ "$INSTALL_GEMINI" -eq 1 ] && echo -e "    ${BOLD}gemini${NC} を起動 → /${skill_name}"
[ "$INSTALL_CODEX"  -eq 1 ] && echo -e "    ${BOLD}codex${NC}  を起動 → /${skill_name}"
echo ""
if [ "$INSTALL_GEMINI" -eq 1 ]; then
  echo -e "  ${YELLOW}※ Gemini CLI 用の TOML はスキル更新時 (git pull 後) に再生成が必要です:${NC}"
  echo -e "     bash setup.sh gemini"
  echo ""
fi
