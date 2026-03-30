---
name: init-project
description: Initialize a new project with proper structure, toolchain configuration, feature list, and progress tracking. Based on the Initializer Agent pattern from Anthropic's effective harnesses methodology. Use when the user wants to start a new project, set up a project, or initialize a codebase.
allowed-tools: Bash, Read, Write, Edit
---

Initialize a new project following the Initializer Agent pattern.

## Steps

### Step 1: Gather requirements

Read $ARGUMENTS. Confirm:
- Project type (web app, CLI tool, library, API service, etc.)
- Tech stack (language, framework, database)
- Key features (high-level list)

If any of the above is unclear, **ask the user before proceeding**. Do not assume.

### Step 2: Scaffold the project

- Initialize project structure appropriate to the tech stack
- Configure package manager and dependencies
- Configure formatter and linter (prettier / ruff / gofmt / Spotless)
- Configure test runner — ensure the test command runs without error
- Create `.gitignore` covering `.env`, `node_modules`, build artifacts, IDE files

### Step 3: Generate feature-list.json

Use the **Agent tool** to call the Planner Agent, passing:
- Project description
- Tech stack
- User-confirmed feature list

The Planner will detect that feature-list.json does not exist and enter **initial decomposition mode**, generating feature-list.json with properly structured features, acceptance_criteria, depends_on, and all required fields including `replanned: false` and `eval_report`.

After the Planner returns, verify:
- `feature-list.json` exists
- `features` array is non-empty
- Each feature has `acceptance_criteria` (non-empty array), `replanned`, and `eval_report` fields

### Step 4: Create progress.json

```json
{
  "project": "<name>",
  "last_updated": "<ISO datetime>",
  "current_session": 1,
  "total_features": <N>,
  "completed_features": 0,
  "status": "initialized",
  "last_completed": null,
  "next_steps": "Start with the first high-priority failing feature in feature-list.json",
  "notes": "",
  "environment": {
    "setup_command": "<command to set up dev environment>",
    "test_command": "<command to run tests>",
    "build_command": "<command to build>",
    "dev_command": "<command to start dev server>"
  },
  "session_history": [
    {
      "session": 1,
      "date": "<ISO date>",
      "completed": [],
      "notes": "Project initialized"
    }
  ]
}
```

### Step 5: Initial git commit

```bash
git init
git add .
git commit -m "chore: initialize project baseline

- Set up project structure and toolchain
- Create feature-list.json with N features (all failing)
- Create progress.json for session tracking"
```

The `test_command` MUST succeed before committing (empty test suite passing is acceptable).

### Step 6: Output handoff summary

Report:
1. Project structure overview
2. Feature list summary (total count, priority breakdown)
3. Dev environment commands
4. First feature to implement (ID + name)

## Constraints

- Do NOT implement any features — only set up the environment
- Do NOT mark any feature as `"passing"` — that is the Coding Agent's job
- Do NOT skip test framework configuration, even for simple projects

$ARGUMENTS
