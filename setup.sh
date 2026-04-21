#!/bin/bash
# Claude Code Skills setup script
#
# Symlinks ~/.claude/skills/ to this repository's skills/ directory.
# If existing skills are found, they are backed up first.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="${SCRIPT_DIR}/skills"
SKILLS_DST="${HOME}/.claude/skills"

echo "=== Claude Code Skills Setup ==="
echo ""
echo "Link source:      ${SKILLS_SRC}"
echo "Link destination: ${SKILLS_DST}"
echo ""

# Verify ~/.claude/ exists
if [ ! -d "${HOME}/.claude" ]; then
    echo "ERROR: ${HOME}/.claude/ does not exist. Install Claude Code first."
    exit 1
fi

# Back up any existing skills directory
if [ -e "${SKILLS_DST}" ] && [ ! -L "${SKILLS_DST}" ]; then
    BACKUP="${SKILLS_DST}.bak.$(date +%Y%m%d_%H%M%S)"
    echo "Backing up existing skills directory: ${BACKUP}"
    mv "${SKILLS_DST}" "${BACKUP}"
elif [ -L "${SKILLS_DST}" ]; then
    CURRENT_TARGET="$(readlink "${SKILLS_DST}")"
    if [ "${CURRENT_TARGET}" = "${SKILLS_SRC}" ]; then
        echo "Already linked. No changes needed."
        exit 0
    fi
    echo "Updating existing symlink: ${CURRENT_TARGET} -> ${SKILLS_SRC}"
    rm "${SKILLS_DST}"
fi

# Create the symlink
ln -s "${SKILLS_SRC}" "${SKILLS_DST}"
echo ""
echo "Setup complete!"
echo ""
echo "Available skills:"
for skill_dir in "${SKILLS_SRC}"/*/; do
    skill_name="$(basename "${skill_dir}")"
    echo "  /${skill_name}"
done
echo ""
echo "Invoke any skill from any Claude Code instance via /{skill-name}."
