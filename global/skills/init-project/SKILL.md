---
name: init-project
description: Initialize a new project with proper structure, toolchain configuration, feature list, and progress tracking. Based on the Initializer Agent pattern from Anthropic's effective harnesses methodology.
allowed-tools: Bash, Read, Write, Edit
---

Initialize a new project following the Initializer Agent pattern.

## Usage

```
/init-project <project description or requirements>
```

## Steps

### Step 1: Gather requirements

Read the user's description from $ARGUMENTS. Confirm:
- Project type (web app, CLI tool, library, API service, etc.)
- Tech stack (language, framework, database)
- Key features (high-level list)

If any of the above is unclear, **ask the user before proceeding**. Do not assume.

After collecting the feature list, assess complexity:
- **>= 5 features AND involves API endpoints or a data model** → recommend creating `docs/design.md` before Step 2. Say: "This project has multiple features with a data model. Consider drafting `docs/design.md` first using the `templates/design-doc.md` template to align on API contracts and data structures."
- **Has a significant architectural decision** (auth method, storage choice, framework selection) → recommend: "Consider capturing this in `docs/adr-001.md` using `templates/adr.md`."

Do not block on this — if the user wants to proceed without design docs, proceed.

### Step 2: Scaffold the project

- Initialize project structure appropriate to the tech stack
- Configure package manager and dependencies
- Configure formatter and linter (prettier/ruff/gofmt/Spotless)
- Configure test runner — ensure `npm test` / `pytest` / `go test ./...` runs without error
- Create `.gitignore` covering `.env`, `node_modules`, build artifacts, IDE files

### Step 3: Create feature-list.json

Create a structured feature list. All features start as `"failing"`.

```json
{
  "project": "<name>",
  "version": "1.0.0",
  "created_at": "<ISO datetime>",
  "features": [
    {
      "id": "F001",
      "name": "<feature name>",
      "description": "<what it does and why it's needed>",
      "acceptance_criteria": [
        "<specific, testable criterion — see note below>",
        "<another criterion>"
      ],
      "status": "failing",
      "priority": "high|medium|low",
      "depends_on": [],
      "spec_ref": "",
      "notes": ""
    }
  ]
}
```

**Writing good acceptance_criteria** — each criterion must be:
- Testable: can be verified by running code or checking output
- Specific: names the exact behavior, not a vague goal
- Independent: can be checked without running other criteria first

Good: `"POST /api/users returns 201 and the created user object when given valid name and email"`
Bad: `"User creation works correctly"`

Use JSON (not Markdown checklist) — models follow JSON structure more reliably.

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
- Create feature-list.json with N features
- Create progress.json for session tracking
- All features status: failing (ready for implementation)"
```

The test command in progress.json MUST succeed before committing (an empty test suite passing is acceptable).

### Step 6: Output handoff summary

Report to the user:
1. Project structure overview
2. Feature list summary (total count, priority breakdown)
3. Dev environment commands
4. First feature to implement (ID + name from feature-list.json)

## Constraints

- Do NOT implement any features — only set up the environment
- Do NOT mark any feature as `"passing"` — that is the Coding Agent's job
- Do NOT skip test framework configuration, even for simple projects

$ARGUMENTS
