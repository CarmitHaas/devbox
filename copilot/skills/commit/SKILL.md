---
name: commit
description: Create one focused git commit from the working tree and push it, with a short imperative subject and no attribution trailers. Use when asked to commit, save progress, lock this in, or at a natural checkpoint. Not for PR descriptions or release notes.
---

# Commit

## What this skill does
Takes the current working tree, stages only what belongs to one logical change, proposes a subject line, commits after approval, and pushes. The commit log is read by reviewers now and by whoever bisects a bug months later.

## When to use it
- "Commit this"
- "Save progress" or "lock this in"
- "We reached a checkpoint, commit and push"

Do not use it for the PR text; use `pr-description`. Do not use it for release notes; use plain chat.

## How to do it
1. Read: run `git status`, `git diff --staged`, and `git diff`. Read the changes, not the file names.
2. Decide: group the changes into logical units. If the tree holds more than one unrelated change, say so and propose separate commits. Never mix them.
3. Check: before staging, look for data files, `.env` files, credentials, large binaries, and generated output. Never stage them, even if untracked. If `.gitignore` lacks the pattern, add the pattern instead of staging the file.
4. Ask: if the purpose of a change is unclear, ask one question. If the user wrote text after the request, treat it as the hint for the message.
5. Write: propose one imperative subject under 60 characters. Show it and wait for approval.
6. Commit with that subject only. Add a body only when the change needs explaining. No trailers.
7. Push the current branch. If it has no upstream, use `git push -u origin <branch>`.
8. Report the subject, the short hash, and the branch pushed. If the push failed, say why.

## What not to do
- Do not add "Co-Authored-By", "Generated with", or any attribution footer; the author is the user.
- Do not write subjects like "update files" or "fix stuff"; name what changed and where.
- Do not run `git add -A` or `git add .`; stage named paths.
- Do not commit on the default branch when the repo's rules say to branch first; say so and stop.
- Do not amend or force-push unless asked.

## Output format
Before approval:
```
Staged:   <paths>
Left out: <paths and why, or "nothing">
Subject:  <imperative, under 60 chars>
Body:     <optional, two lines max, or "none">
Push:     <branch> -> origin/<branch>
```
After approval:
```
<short hash> <subject>
pushed to origin/<branch>   (or: push failed: <reason>)
```
