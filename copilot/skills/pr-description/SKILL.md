---
name: pr-description
description: Write a pull request description in a fixed shape, What, Why, How tested, Risk and rollback, Reviewer notes, with the ticket key and under 25 lines, from a branch, a diff, or a list of commits. Use when asked for a PR description, PR text, or to describe a change for review. Not for commit messages, release notes, or Jira tickets.
---

# PR description

## What this skill does
Turns a change (current branch, pasted diff, or commits) into a description a reviewer reads in two minutes and an on-call engineer can still use months later. Output is Markdown for the PR body.

## When to use it
- "Write the PR description"
- "Describe this branch for review"
- "Fill the PR template for this diff"

Do not use it for the commit subject; use `commit`. Do not use it for a ticket; use `jira-story`.

## How to do it
1. Read: `git diff <base>...HEAD --stat`, then the full diff, or what the user pasted. Find the ticket key in the branch name or the commits. Do not guess from file names.
2. Decide: group facts by component (pipeline, infrastructure, chart, application, docs). Each fact has a before and an after value where one exists.
3. Check: the why is a reason, not a restatement of the what. Risk names what breaks if the change is wrong and when it takes effect. Rollback is a command, a version, or a named value. Testing is evidence, or "Not tested yet:" and what to run.
4. Ask: if the reason is not in the change or the ticket, ask one question.
5. Write the format below. Under 25 lines. Ticket key in the first line. If no key exists, write `NO-TICKET` and say so.

## What not to do
- Do not paraphrase the diff line by line; summarize by effect.
- Do not write "minor change" or "no risk"; name the smallest real risk.
- Do not invent test runs, ticket keys, or reasons; leave a `TODO:` line.
- Do not describe files outside the change; list them as follow-ups if they matter.

## Output format
```
<KEY>: <one-line title, imperative>

## What
- <component>: <fact, before -> after>

## Why
<one or two sentences>

## How tested
- <evidence: command and result, or "Not tested yet: <what to run>">

## Risk and rollback
- Scope: <environments and services touched>
- Failure mode: <what breaks, when it takes effect>
- Rollback: <command, version, or value>

## Reviewer notes
- <where to look first; what to ignore; follow-ups outside this PR>
```
