---
name: screen-capture
description: "Capture screenshots of a specified screen using Playwright and visually inspect them"
argument-hint: "[target URL or screen name]"
disable-model-invocation: true
---

# Playwright Screenshot Capture

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{PLAYWRIGHT_DIR}` | Playwright project directory | `playwright` |
| `{PLAYWRIGHT_CMD}` | Playwright execution command | `cd playwright && npx playwright test {file} --project=local` |
| `{LOCAL_URL}` | Local development URL | `https://localhost:8080` |

---

## Execution Steps

### 1. Run Playwright

```bash
{PLAYWRIGHT_CMD}
```

### 2. Display Screenshots

Display captured images using the Read tool:
- All PNG files under `{PLAYWRIGHT_DIR}/test-results/`

### 3. Comparison Report

Compare corresponding areas between the reference screen and the target screen, and report any differences.
