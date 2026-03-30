---
name: capture-idea
description: Convert a rough idea or vague requirement into a structured feature-list.json draft. The lightweight entry point for vibe-coding sessions — no project scaffolding, just idea-to-spec conversion. Use when the user wants to capture an idea, plan features, or convert a description into a feature list.
allowed-tools: Read, Write, Edit
---

Turn $ARGUMENTS into a structured feature list draft.

## Steps

### Step 1: Understand the idea

Read $ARGUMENTS. If too vague to extract meaningful features (e.g., just "build a web app"), ask 1-2 targeted questions:
- What is the primary user action?
- What is the expected output or result?

Do not ask more than 2 questions.

### Step 2: Extract features

Break the idea into discrete, implementable features. Each feature should:
- Be completable in a single focused session
- Have at least one testable outcome
- Not depend on another feature unless clearly necessary

Aim for 3-8 features.

### Step 3: Draft feature-list.json

```json
{
  "project": "<inferred name>",
  "version": "1.0.0",
  "created_at": "<ISO datetime>",
  "features": [
    {
      "id": "F001",
      "name": "<feature name>",
      "description": "<what it does>",
      "acceptance_criteria": ["<specific, testable criterion>"],
      "status": "failing",
      "priority": "high|medium|low",
      "depends_on": [],
      "spec_ref": "",
      "notes": "",
      "replanned": false,
      "eval_report": {
        "result": null,
        "issues": [],
        "tested_at": null,
        "retry_count": 0
      }
    }
  ]
}
```

**Good criterion**: `"POST /api/todos returns 201 and created item when given valid title"`
**Bad criterion**: `"Todo creation works"`

### Step 4: Assess complexity

- >= 5 features AND involves API/data model → suggest: "Consider creating `docs/design.md` first using `templates/design-doc.md`."
- Significant architectural decision (auth, storage, framework) → suggest: "Consider creating an ADR in `docs/` using `templates/adr.md`."

### Step 5: Present and confirm

Show the draft, then:

> **Mode notice**: Once `feature-list.json` exists, the next session enters **spec-coding mode** — agent asks for confirmation before each feature and does not auto-commit. Reply `skip` to discard without writing.

Ask: "Does this capture your intent? (yes / edit / skip)"

- **yes** → write `feature-list.json` to current directory
- **edit** → take corrections, revise, ask again
- **skip** → discard and stop

### Step 6: Optionally create progress.json

After writing feature-list.json, ask: "Also create `progress.json` for multi-session tracking? (yes / no)"

If yes, create with `total_features` matching feature count, `status: "initialized"`, `environment` fields as placeholders.

## Rules

- Do NOT scaffold the project or install dependencies — that is `/init-project`'s job
- Do NOT implement any features
- Keep features focused: fewer well-defined > many vague

$ARGUMENTS
