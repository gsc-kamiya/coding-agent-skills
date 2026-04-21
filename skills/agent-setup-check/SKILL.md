---
name: agent-setup-check
description: Verify that a coding-agent development environment is correctly set up (Node.js, GitHub CLI, agent CLIs, project deps, Git)
argument-hint: "(no arguments)"
---

# Environment Health Check

Quickly verify all required tools are installed and the project is ready to work.

## Configuration

Optional overrides in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{INSTALL_AGENTS}` | Which agent CLIs to verify | `claude,gemini,codex` |
| `{REPAIR_HINT}` | Skill to suggest if any check fails | `/agent-setup` |

---

## Steps

Run the following checks (skip any agent CLI not in `{INSTALL_AGENTS}`):

```bash
echo "=== Node.js ==="     && (node --version 2>/dev/null     || echo "❌ not installed")
echo "=== npm ==="         && (npm --version 2>/dev/null      || echo "❌ not installed")
echo "=== GitHub CLI ===" && (gh --version 2>/dev/null       || echo "❌ not installed")
echo "=== gh auth ==="     && (gh auth status 2>&1            || echo "❌ not authenticated")
echo "=== Claude Code ===" && (claude --version 2>/dev/null   || echo "❌ not installed")
echo "=== Gemini CLI ==="  && (gemini --version 2>/dev/null   || echo "❌ not installed")
echo "=== Codex CLI ==="   && (codex --version 2>/dev/null    || echo "❌ not installed")
echo "=== node_modules ===" && ([ -d node_modules ] && echo "✅ installed" || echo "❌ run npm install")
echo "=== Git ==="         && (git status --short 2>/dev/null || echo "❌ not a Git repository")
```

Render the result like this:

```
🔍 Environment Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Node.js          v22.x.x
✅ npm              10.x.x
✅ GitHub CLI       2.x.x
✅ GitHub auth      logged in
✅ Claude Code      x.y.z
✅ Gemini CLI       x.y.z
✅ Codex CLI        x.y.z
✅ Project deps     installed
✅ Git              clean / changes present
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If any line is ❌:
- Explain the problem in plain language (no jargon for non-engineers)
- Suggest `{REPAIR_HINT}` (default: `/agent-setup`) to fix it automatically
