---
name: commit-changes
description: Create focused Git commits using the Conventional Commits format when changes are ready to record.
---

# Commit Changes

Use this workflow when the user asks to commit completed changes.

1. Inspect `git status`, the diff, and recent commit conventions. Do not include unrelated or user-owned changes.
2. Run focused validation appropriate to the changed files before committing.
3. Stage only the intended files and review the staged diff.
4. Create one commit with this format: `type(scope): imperative summary`. Use a standard type such as `feat`, `fix`, `docs`, `refactor`, `test`, `build`, `ci`, or `chore`; omit the scope when it adds no clarity.
5. Keep the subject concise, imperative, and without a trailing period. Add a body only when context is needed, with at most 1-3 bullets.
6. Verify the resulting commit with `git show --stat --oneline HEAD` and report the commit ID and subject.
