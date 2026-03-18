---
name: capture-idea
description: Convert a rough idea or vague requirement into a structured feature-list.json draft. The lightweight entry point for vibe-coding sessions — no project scaffolding, just idea-to-spec conversion.
allowed-tools: Read, Write, Edit
---

Turn $ARGUMENTS into a structured feature list draft.

## Usage

```
/capture-idea <rough description of what you want to build>
```

## Steps

### Step 1: Understand the idea

Read $ARGUMENTS. If the description is too vague to extract meaningful features (e.g., just "build a web app"), ask 1-2 targeted questions:
- What is the primary user action? (what can users do?)
- What is the expected output or result?

Do not ask more than 2 questions. Work with what you have.

### Step 2: Extract features

Break the idea into discrete, implementable features. Each feature should:
- Be completable in a single focused session
- Have at least one testable outcome
- Not depend on another feature unless clearly necessary

Aim for 3-8 features. If the idea is very small (1-2 features), that is fine.

### Step 3: Draft feature-list.json

```json
{
  "project": "<inferred name from description>",
  "version": "1.0.0",
  "created_at": "<ISO datetime>",
  "features": [
    {
      "id": "F001",
      "name": "<feature name>",
      "description": "<what it does>",
      "acceptance_criteria": [
        "<specific, testable criterion>"
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

**Good acceptance_criteria**: `"POST /api/todos returns 201 and the created item when given a valid title"`
**Bad acceptance_criteria**: `"Todo creation works"`

### Step 4: Check complexity

After drafting, assess:
- **>= 5 features AND involves API endpoints or a data model** → suggest: "Consider creating `docs/design.md` before implementing. Use the `templates/design-doc.md` template."
- **Has a significant architectural decision** (auth method, storage choice, framework) → suggest: "Consider capturing this in `docs/adr-001.md`. Use the `templates/adr.md` template."

Otherwise, proceed without comment.

### Step 5: Present and confirm

Show the draft to the user. Ask: "Does this capture your intent? (yes to write / edit to adjust / skip)"

- **yes**: write `feature-list.json` to current directory
- **edit**: take the user's corrections and revise the draft, then ask again
- **skip**: discard and stop

### Step 6: Optionally create progress.json

After writing feature-list.json, ask: "Also create `progress.json` to enable multi-session tracking? (yes / no)"

If yes, create progress.json with:
- `total_features` matching the feature count
- `status: "initialized"`
- `environment` fields left as placeholders for the user to fill in

## Rules

- Do NOT scaffold the project or install dependencies — that is `/init-project`'s job
- Do NOT implement any features
- Keep the feature list focused: prefer fewer well-defined features over many vague ones
- If progress.json is created, remind the user to fill in the `environment` commands before running the Coding Agent
