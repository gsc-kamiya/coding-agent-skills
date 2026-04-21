---
name: screen-analyze
description: "Comprehensively analyze an existing screen implementation and create a modification plan by identifying differences with a reference screen"
argument-hint: "[target screen or modification description]"
disable-model-invocation: true
---

# Screen Implementation Analysis & Modification Planning

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

---

## Execution Steps

### 1. Reference Screen Analysis (Explore Agent — Parallel Execution)

Analyze the following in parallel:

- **View**: HTML structure, CSS class usage in the reference screen (`{USER_VIEW_DIR}`)
- **CSS**: Relevant class definitions (dimensions, colors, image paths) from `{CSS_FILES}`
- **Model/Widget**: Model methods and shared widgets used
- **DB**: Table definitions, relations, JSON column structures

### 2. Target Screen Current State

- Corresponding files in `{VIEW_DIR}`
- Related models/methods in `{MODEL_DIR}`
- Related actions in `{CONTROLLER_DIR}`

### 3. Difference Analysis & Modification Plan

Output analysis results in the following format:

| Element | Reference Screen | Target Screen (Current) | Modification Needed |
|---------|-----------------|------------------------|---------------------|

**Files to change:**
- Model: Method names and descriptions to add
- View: Areas to modify
- Test: Number of test methods to add

## Core Principles

- Follow the existing reference screen's design, layout, and CSS classes
- Minimize new CSS creation; prioritize existing CSS classes
- Retrieve data dynamically from data models
