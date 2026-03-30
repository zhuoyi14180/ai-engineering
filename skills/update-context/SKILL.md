---
name: update-context
description: Distill insights from code reviews, debugging sessions, or observations into reusable context files. Use when the user wants to save a lesson learned, document a pattern, or update knowledge from a review or debugging session.
allowed-tools: Read, Edit, Write, Glob
---

Extract reusable engineering knowledge from $ARGUMENTS and persist it to the appropriate context file.

## Steps

### 1. Categorize the finding

Parse $ARGUMENTS to identify the category:
- Security issue → `context/security-checklist.md`
- Coding pattern or anti-pattern → `context/coding-standards.md`
- Testing approach → `context/testing-patterns.md`
- Git or workflow issue → `context/git-workflow.md`
- AI engineering principle → `context/ai-engineering-principles.md`
- Evaluation standard → `context/evaluation-rubrics.md`

### 2. Read the target file

Load current content of the relevant context file.

### 3. Check for duplicates

Scan existing content. If the insight is already captured, report the existing entry and stop.

### 4. Draft the addition

Write a concise, actionable entry in the same style as existing entries:
- Imperative or descriptive phrasing (not "I noticed that...")
- Specific enough to act on, not generic advice
- Include a code example if the finding is language-specific

### 5. Show proposed addition

Present the exact text to be added and insertion location (which section, after which line).

### 6. Confirm and write

Ask: "Add this to `<file>`? (yes / edit / skip)"

On confirmation, use Edit to insert at the proposed location.

## Rules

- Never overwrite existing entries — only append or insert
- If finding spans multiple categories, handle each file separately with individual confirmations
- If $ARGUMENTS is empty or too vague, ask for more detail
- Prefer updating an existing section over creating a new one

## Trigger Scenarios

Most useful after:
- Running `/review-pr` and finding a recurring issue pattern
- Debugging a non-obvious bug that took significant time
- Discovering a framework behavior or language gotcha
- Completing a feature where a better pattern emerged mid-implementation

$ARGUMENTS
