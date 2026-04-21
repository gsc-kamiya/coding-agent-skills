---
name: screen-tdd
description: "TDD-driven screen modification — analyze, write tests, implement, and visually compare with Playwright"
argument-hint: "[modification plan file path or description of changes]"
disable-model-invocation: true
---

# TDD-Driven Screen Modification

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{VIEW_DIR}` | Target view files directory | `modules/admin/views/` |
| `{USER_VIEW_DIR}` | Reference view files directory (comparison target) | `views/` |
| `{CSS_FILES}` | CSS file paths (comma-separated) | `web/css/main.css, web/css/color.css` |
| `{MODEL_DIR}` | Model files directory | `models/` |
| `{CONTROLLER_DIR}` | Controller files directory | `controllers/` |
| `{TEST_DIR}` | Test files directory | `tests/unit/` |
| `{TEST_CMD}` | Test execution command | `docker compose exec -T php vendor/bin/phpunit {file}` |
| `{PLAYWRIGHT_DIR}` | Playwright project directory | `playwright` |
| `{PLAYWRIGHT_CMD}` | Playwright execution command | `cd playwright && npx playwright test {file} --project=local` |
| `{LOCAL_URL}` | Local development URL | `https://localhost:8080` |
| `{LOGIN_INFO}` | Test login credentials | (project-specific) |

---

## Screen Modification Flow (7 Steps)

### Step 1: Comprehensive Analysis of Existing Implementation

Thoroughly analyze the reference screen implementation.

1. **Reference view analysis**: Read HTML structure, CSS classes, and JS behavior from `{USER_VIEW_DIR}`
2. **Model/widget analysis**: Identify model methods, shared widgets, and helpers used by the screen
3. **CSS analysis**: Extract CSS class definitions (dimensions, colors, background image paths, etc.) from `{CSS_FILES}`
4. **DB structure analysis**: Review DB structure (table definitions, relations, JSON columns) for relevant data
5. **Target screen current state**: Check the current implementation in `{VIEW_DIR}`

Use Agent tool (Explore) for parallel execution.

### Step 2: Modification Plan

Based on the analysis, identify differences and create a modification plan.

- **Core principle**: Follow the existing reference screen's design, layout, and CSS classes (exceptions only when the user explicitly specifies)
- Use the same CSS classes used in the reference screen
- Add methods to retrieve data from the data model, returning structures equivalent to the reference
- List all files to modify (models/views/controllers/tests) with planned changes

### Step 3: TDD Red Phase — Write Tests

Add test methods to the relevant test file in `{TEST_DIR}`.

- Unit tests for new model methods
- View structure tests (HTML structure validation)
- CSS class reference existence tests
- Controller action existence tests

Test execution command:
```
{TEST_CMD}
```

At this point, confirm tests FAIL (Red).

### Step 4: TDD Green Phase — Implementation

Implement the minimum code to pass the tests.

1. **Model**: Add methods
2. **View**: Modify HTML (using existing CSS classes)
3. **Controller**: Add actions (only when needed)

Re-run tests and confirm all tests pass (Green).

### Step 5: Playwright Visual Comparison

Capture screenshots with Playwright and compare the reference screen with the target screen at the image level.

1. Create test spec in `{PLAYWRIGHT_DIR}/tests/detail/`
2. Use authentication settings
3. Capture screenshots of:
   - The relevant area on the reference screen
   - The corresponding area on the target screen
4. Visually confirm both images with the Read tool and identify design differences

```bash
{PLAYWRIGHT_CMD}
```

### Step 6: Iterative Correction (Until Design Match)

If differences are found in the Playwright comparison:
1. Identify CSS/HTML differences
2. Add tests (Red)
3. Fix implementation (Green)
4. Re-run Playwright
5. Confirm match in image comparison

Repeat Steps 5-6 until design match is confirmed.

### Step 7: Final Verification

1. Run all tests (confirm Green)
2. Take final Playwright screenshots
3. Report a summary of changes (test count/assertion count, changed file list, comparison images)

## Notes

- Execute autonomously without asking the user for confirmation (unless explicitly asked)
- Prioritize existing CSS classes (minimize new CSS creation)
- Retrieve data dynamically from data models
