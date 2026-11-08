---
name: daily-prep
description: Prepare what to say in the daily standup from a Jira board export or a pasted task list, as three lines per item (yesterday, today, blockers), a flag on every item with no update in two days, and the one question to ask. Use when asked to prep the daily, get ready for standup, or turn the board into talking points. Not for the weekly status to a manager or for writing Jira tickets.
---

# Daily prep

## What this skill does
Reads the user's items on the board (CSV export, pasted list, or a query result) and produces the standup script: short, factual, per item. It also catches items that went quiet. The reader is the user, two minutes before the daily.

## When to use it
- "Prep the daily"
- "What do I say in standup"
- "Turn my board into talking points"

Do not use it for the weekly message; use `weekly-status`. Do not use it to write or fix a ticket; use `jira-story`.

## How to do it
1. Read: the input list. For each item take key, summary, status, assignee, last updated, and any comment text. For a CSV, read the header row first and map the columns; do not assume their names.
2. Decide: keep items assigned to the user or where the user is named. Order: blocked, then in progress, then to do, then done since the last daily. Compute days since the last update from the updated field and today's date.
3. Check: every "yesterday" line is a fact from the input or from the user's own notes, not a guess. Every blocker names a person or a system. Items with no update in two or more days get `[quiet N days]`.
4. Ask: if today's date or the user's notes from yesterday are missing, ask one question. Do not invent progress.
5. Write the script in the format below. Under 25 lines for a normal board. End with one question for the team: the one that unblocks the most.

## What not to do
- Do not pad with "working on it" or "continuing"; name the step.
- Do not report done items older than the last daily.
- Do not hide a blocker inside the "today" line; blockers get their own line and a name.
- Do not invent ticket keys or statuses; write `TODO:` and say what is missing.

## Output format
```
Daily YYYY-MM-DD  (<N> items, <M> quiet)

<KEY> <summary, under 60 chars> [<status>] [quiet N days]
  Yesterday: <one fact>
  Today:     <one step>
  Blockers:  <who or what, or "none">

Quiet items (no update 2+ days): <KEY, KEY> -> update or close today
One question for the team: <the question, one line, and who it is for>
```
