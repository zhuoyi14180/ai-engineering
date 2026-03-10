---
name: commit
description: Create a conventional commit with intelligent message generation. Analyzes staged/unstaged changes, drafts a commit message following conventional commits format, and creates the commit.
allowed-tools: Bash, Read
---

Analyze the current git state and create a well-formatted conventional commit.

## Steps

1. Run `git status` to see current state
2. Run `git diff` and `git diff --staged` to understand the changes
3. Run `git log --oneline -5` to match the repo's commit style
4. Analyze the changes and draft a commit message:
   - Format: `<type>(<scope>): <subject>`
   - Types: feat / fix / refactor / test / docs / chore / perf
   - Subject: imperative mood, under 72 chars, Chinese is acceptable
   - If changes are significant, add a body explaining **why** (not what)
5. Stage relevant files (prefer specific files over `git add -A`)
6. Create the commit

## Rules

- Never commit `.env`, credentials, or secret files — warn the user if present
- Never use `--no-verify` to skip hooks
- If there are no changes to commit, report the clean state and stop
- For long-running task commits, append `[progress: X/N features]` to subject if applicable

$ARGUMENTS
