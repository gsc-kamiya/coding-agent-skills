---
name: screen-test
description: "Run TDD tests and perform Playwright visual comparison for a specified screen"
argument-hint: "[target test file or screen]"
disable-model-invocation: true
---

# Test Execution & Visual Comparison

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{TEST_CMD}` | Test execution command | `docker compose exec -T php vendor/bin/phpunit {file}` |
| `{PLAYWRIGHT_DIR}` | Playwright project directory | `playwright` |
| `{PLAYWRIGHT_CMD}` | Playwright execution command | `cd playwright && npx playwright test {file} --project=local` |
| `{LOCAL_URL}` | Local development URL | `https://localhost:8080` |

---

## Execution Steps

### 1. Unit Test Execution

```bash
{TEST_CMD}
```

Confirm all tests pass (Green). If any FAIL, identify the cause and fix.

### 2. Playwright Screenshot Capture

```bash
{PLAYWRIGHT_CMD}
```

### 3. Visual Comparison

Display captured screenshots using the Read tool and compare the reference screen with the target screen. Report any design differences found.

### 4. Fix Differences (If Needed)

1. Identify difference -> Add test (Red) -> Fix implementation (Green)
2. Re-run Playwright -> Re-compare images
3. Repeat until match
