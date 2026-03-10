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

## What This Skill Does

1. **Gathers requirements** — asks clarifying questions about project type, tech stack, and key features if not provided
2. **Scaffolds the project** — creates directory structure, configures toolchain (formatter, linter, test runner)
3. **Creates feature-list.json** — structured JSON list of all features to implement, all starting as `"failing"`
4. **Creates progress.json** — session state tracker for multi-session development
5. **Makes initial git commit** — establishes baseline, all tests passing (empty test suite is fine to start)
6. **Outputs handoff summary** — ready for Coding Agent to take over

## feature-list.json Structure

```json
{
  "project": "<name>",
  "version": "1.0.0",
  "created_at": "<ISO datetime>",
  "features": [
    {
      "id": "F001",
      "name": "<feature name>",
      "description": "<what it does>",
      "acceptance_criteria": ["criterion 1", "criterion 2"],
      "status": "failing",
      "priority": "high"
    }
  ]
}
```

## Constraints

- Do NOT implement any features — only set up the environment
- Do NOT mark any feature as `"passing"` — that's the Coding Agent's job
- The test command in progress.json MUST work before committing

$ARGUMENTS
