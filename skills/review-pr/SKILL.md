---
name: review-pr
description: Perform a thorough code review of a pull request or the current branch's changes. Checks for bugs, security issues, code quality, test coverage, and adherence to project conventions. Use when the user asks to review a PR, review changes, or check code quality.
allowed-tools: Bash, Read, Grep
---

Perform a systematic code review of $ARGUMENTS (PR number, branch name, or current changes if no argument).

## Review Checklist

### 1. Understand the Change
- What is the intent of this change?
- Does it match what the PR/commit message describes?

### 2. Correctness
- [ ] Does the logic handle edge cases?
- [ ] Are there obvious bugs or off-by-one errors?
- [ ] Is error handling appropriate at system boundaries?

### 3. Security
- [ ] No SQL injection, command injection, or XSS vectors
- [ ] No secrets or credentials in code
- [ ] Input validation at system boundaries
- [ ] See `context/security-checklist.md` for full list

### 4. Tests
- [ ] Are new features covered by tests?
- [ ] Do existing tests still pass?
- [ ] Are tests verifying behavior, not implementation details?
- [ ] No tests deleted or disabled

### 5. Code Quality
- [ ] Is the code readable and well-named?
- [ ] Any unnecessary complexity or premature abstraction?
- [ ] Any dead code or unused imports?

### 6. Conventions
- [ ] Follows project coding standards
- [ ] Commit messages in correct format
- [ ] ADR created if a significant architectural decision was made

## Output Format

- **Summary**: 2-3 sentence overview
- **Issues** (if any): Categorized as Critical / Major / Minor
- **Suggestions** (optional): Non-blocking improvements
- **Verdict**: Approve / Request Changes / Needs Discussion

> If this review surfaces a recurring issue pattern, run `/update-context` to persist the finding to the relevant context file.

$ARGUMENTS
