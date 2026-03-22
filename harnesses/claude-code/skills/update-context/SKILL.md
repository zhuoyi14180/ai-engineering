---
name: update-context
description: Distill insights from code reviews, debugging sessions, or observations into reusable context files. Bridges the gap between the "fix" and "solidify" phases of the development loop.
allowed-tools: Read, Edit, Write, Glob
---

Extract reusable engineering knowledge from $ARGUMENTS and persist it to the appropriate context file.

## Usage

```
/update-context <description of finding or paste review output>
```

## Steps

1. **Understand the input**: Parse $ARGUMENTS to identify the category of finding:
   - Security issue → `context/security-checklist.md`
   - Coding pattern or anti-pattern → `context/coding-standards.md`
   - Testing approach → `context/testing-patterns.md`
   - Git or workflow issue → `context/git-workflow.md`
   - AI engineering principle → `context/ai-engineering-principles.md`

2. **Read the target file**: Use Read to load the current content of the relevant context file.

3. **Check for duplicates**: Scan existing content to confirm the insight is not already captured. If it is, report the existing entry and stop.

4. **Draft the addition**: Write a concise, actionable entry in the same style as existing entries in that file:
   - Use imperative or descriptive phrasing (not "I noticed that...")
   - Be specific enough to act on, not generic advice
   - Include a code example if the finding is language-specific

5. **Show the proposed addition**: Present the exact text to be added and the insertion location (which section, after which line).

6. **Ask for confirmation**: Ask the user: "Add this to `<file>`? (yes / edit / skip)"

7. **Write on confirmation**: If confirmed, use Edit to insert the entry into the file at the proposed location.

## Rules

- Never overwrite existing entries — only append or insert
- If the finding spans multiple categories, add to each file separately and ask for confirmation for each
- If $ARGUMENTS is empty or too vague to extract a concrete finding, ask the user to provide more detail
- Prefer updating an existing section over creating a new one

## Trigger Scenarios

This skill is most useful after:
- Running `/review-pr` and finding a recurring issue pattern
- Debugging a non-obvious bug that took significant time
- Discovering a framework behavior or language gotcha worth remembering
- Completing a feature where a better pattern emerged mid-implementation
