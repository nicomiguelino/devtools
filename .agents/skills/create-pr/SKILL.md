---
name: create-pr
description: Create and assign a concise GitHub pull request against the repository default branch using Conventional Commits.
---

# Create Pull Request

Use this workflow when the user asks to open a GitHub pull request.

1. Determine the repository default branch with `gh repo view --json defaultBranchRef`; do not assume it is `main`.
2. Inspect the current branch, status, and commits. The branch name must have exactly two slash-separated parts: `<type>/<descriptor>`, where `<type>` is a Conventional Commits type such as `feat`, `fix`, or `chore`, and `<descriptor>` is a short kebab-case description. Ensure the branch is pushed and contains only the requested work. Commit outstanding changes with the `commit-changes` skill when needed.
3. Use a Conventional Commits title such as `chore: organize x86 installer and add workflow skills`.
4. Create the PR with `gh pr create --base <default-branch> --head <current-branch> --title '<title>' --body '<body>'`.
5. Keep the description to 1-2 sections, prefer concise bullets, and do not include a test plan section. Mention only the implemented changes and relevant validation.
6. Assign the PR to the authenticated user with `gh pr edit <number> --add-assignee @me`, then verify the URL, base branch, title, and assignee with `gh pr view <number>`.
