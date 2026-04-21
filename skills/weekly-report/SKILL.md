---
name: weekly-report
description: Auto-generate a weekly progress report (MD + PPTX) based on comprehensive codebase analysis
argument-hint: "[--date YYYY-MM-DD] [--project project-name]"
---

# Weekly Progress Report Generator

Analyze all layers of the codebase in parallel and auto-generate a progress report (MD + PPTX).

## Configuration

Before using this skill, define the following in your project's `CLAUDE.md`:

| Variable | Description | Example |
|:--|:--|:--|
| `{PROJECT_NAME}` | Project name | `MyProject` |
| `{COMPANY_NAME}` | Company name for report footer | `Acme Corp` |
| `{TEST_CMD}` | Test execution command | `docker compose exec -T app vendor/bin/phpunit` |
| `{REPORT_DIR}` | Report output directory | `docs/reports` |

---

## Arguments

- `$0`: `--date YYYY-MM-DD` (optional: defaults to today)
- `$1`: `--project project-name` (optional: defaults to current directory's project)

## Overview

Automated workflow:
1. **Codebase analysis**: Analyze all layers in parallel
2. **MD generation**: Organize analysis results into a weekly report Markdown file
3. **PPTX generation**: Generate a presentation with python-pptx

## Execution Steps

### Step 1: Codebase Analysis (Parallel Execution)

Analyze the project codebase from 4 perspectives:
1. **View files**: Line counts, completion status, unimplemented areas
2. **Controller/Logic**: Action/method implementation status, external API integration
3. **Model/Data**: Method implementation status, validation coverage
4. **Migration/Schema**: All database-related migrations

### Step 2: Run Tests

Execute the project's test suite and capture test count / assertion count.

### Step 3: Generate MD Report

Save to: `{REPORT_DIR}/weekly-report-{YYYYMMDD}.md`

Structure:
1. **Executive Summary**: Overall progress, Phase progress bars, key topics
2. **Effort Tracking**: Planned vs. actual table, elapsed days
3. **WBS Details**: Phase-by-phase task list (progress, changes, notes)
4. **Layer Matrix**: Screen x View/Controller/Model/Test
5. **Test Results**: Test suite counts, assertions, vs. plan
6. **Milestone Progress**: Completion criteria and achievement level
7. **Code Size Summary**: File counts, total lines
8. **Critical Path**: Dependency chains, risk assessment
9. **Weekly Action Plan**: Remaining this week, next week's tasks
10. **Discussion Topics**: Points to confirm in the status meeting

### Step 4: Generate PPTX

Generate a 10-slide presentation with python-pptx.

Output: `{REPORT_DIR}/weekly-report-{YYYYMMDD}.pptx`

#### PPTX Structure (10 slides)

| # | Slide | Content |
|---|-------|---------|
| 1 | Title | Title, date, company name |
| 2 | Summary | 4 KPI cards + Phase progress bars |
| 3-5 | WBS Details | Phase-by-phase task lists |
| 6 | Layer Matrix | Implementation rate by layer |
| 7 | Test Results | KPIs + test suite list |
| 8 | Milestones | Timeline + milestone table |
| 9 | Risks & Discussion | Risk table + discussion topics |
| 10 | Action Plan | This week / next week tasks |

#### PPTX Design Specs

- Color palette: Dark blue (#1A365D), Blue (#3182CE), Light gray (#F7FAFC)
- Aspect ratio: 10:7.5 (widescreen)
- Footer: Company name, report title, date, page number
- Progress bars: 80%+ green, 50%+ blue, 30%+ yellow, <30% red

## Progress Rate Calculation

### Per-Layer Criteria

| Layer | 100% | 80%+ | 50%+ | 30%+ | 0% |
|-------|------|------|------|------|----|
| View | Full UI + validation | UI done, TODOs < 3 | Main UI done | Skeleton only | Not started |
| Controller | Logic + DB/API + validation | DB queries + validation | Render only | Stub | Not started |
| Model | All methods implemented | JSON accessors + state transitions | Basic CRUD | Schema only | Not started |
| Test | All cases passing | Key cases passing | Basic cases exist | Fixtures only | Not started |

## Requirements

- Python 3.11+ / python-pptx library
- Test execution environment (Docker, etc.)
- `{REPORT_DIR}/` directory (auto-created)

## Output Files

- `{REPORT_DIR}/weekly-report-{YYYYMMDD}.md` — Markdown report
- `{REPORT_DIR}/weekly-report-{YYYYMMDD}.pptx` — Presentation (10 slides)

## Customization

This skill is a template. Project-specific information (file paths, test commands, Phase definitions, etc.) should be overridden in the project's `CLAUDE.md` or `.claude/skills/weekly-report/SKILL.md`.
