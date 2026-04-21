---
name: agent-setup
description: Guided setup of a coding-agent development environment for non-engineers — installs Node.js, GitHub CLI, Claude Code, Gemini CLI, Codex CLI, and project dependencies
argument-hint: "(no arguments)"
---

# Coding-Agent Development Environment Setup

Guided setup for non-engineer users. Inspect the local environment, then install only what's missing — confirming with the user before each install.

A non-interactive bulk script is also provided at `templates/scripts/setup.sh` (POSIX) and `templates/scripts/setup.ps1` (Windows PowerShell). See `templates/scripts/bootstrap.sh` for a one-liner that bootstraps from zero.

## Configuration

Optional overrides in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{NODE_MIN_VERSION}` | Minimum required Node.js major version | `20` |
| `{INSTALL_AGENTS}` | Which agent CLIs to install | `claude,gemini,codex` |
| `{POST_SETUP_HINT}` | Suggested next command after setup completes | `/site-update Change the homepage hero` |

---

## Steps

### Step 1: Diagnose Current Environment

Run the following and present a clear summary to the user:

```bash
echo "=== OS ===" && uname -s && (sw_vers 2>/dev/null || cat /etc/os-release 2>/dev/null)
echo "=== Homebrew ===" && (brew --version 2>/dev/null || echo "not installed")
echo "=== Node.js ===" && (node --version 2>/dev/null || echo "not installed")
echo "=== npm ===" && (npm --version 2>/dev/null || echo "not installed")
echo "=== GitHub CLI ===" && (gh --version 2>/dev/null || echo "not installed")
echo "=== Claude Code ===" && (claude --version 2>/dev/null || echo "not installed")
echo "=== Gemini CLI ===" && (gemini --version 2>/dev/null || echo "not installed")
echo "=== Codex CLI ===" && (codex --version 2>/dev/null || echo "not installed")
```

Display the result as a list:
- ✅ installed (with version)
- ❌ not installed

### Step 2: Install Missing Tools

For each missing tool, **ask the user "Install this now?" before running each install command**. Install in the order below.

#### 2-1: Homebrew (macOS only)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
On Apple Silicon, also append:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
```

#### 2-2: Node.js (≥ `{NODE_MIN_VERSION}`)
```bash
# macOS
brew install node@22

# Debian/Ubuntu/WSL
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

#### 2-3: GitHub CLI
```bash
# macOS
brew install gh

# Debian/Ubuntu — see https://github.com/cli/cli/blob/trunk/docs/install_linux.md for the full keyring setup
```

#### 2-4: Claude Code
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

#### 2-5: Gemini CLI
```bash
npm install -g @google/gemini-cli
```

#### 2-6: Codex CLI
```bash
npm install -g @openai/codex
```

### Step 3: Project Dependencies

If the current directory has a `package.json` but `node_modules/` is missing or stale:

```bash
npm install
```

### Step 4: GitHub Authentication

Check status:
```bash
gh auth status
```

If not authenticated, tell the user a browser will open and ask for confirmation before running:
```bash
gh auth login
```

### Step 5: Verify Setup

Re-run the Step 1 checks and present the final state.

If everything is ✅, suggest the user's first action — for example: `{POST_SETUP_HINT}`.
If anything is still ❌, explain what failed and how to recover.

## Bulk Setup (Non-Interactive)

For users who prefer one command instead of interactive prompts:

```bash
# POSIX
bash templates/scripts/setup.sh

# Windows PowerShell
powershell -ExecutionPolicy Bypass -File templates/scripts/setup.ps1
```

Or bootstrap from zero (no Git / no Node required beforehand):

```bash
curl -fsSL https://raw.githubusercontent.com/{ORG}/{REPO}/main/templates/scripts/bootstrap.sh | bash
```

## Rules

- Always ask before installing each tool
- Never `sudo` something without explaining why
- If on Linux/WSL and `apt` is unavailable, fall back to user-level installs (e.g., nvm for Node)
- Never modify the user's shell rc files without telling them first
