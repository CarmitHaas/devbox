---
name: session-log
description: Write the end-of-day log into the notes folder (the brain), as a verbose dated note in sessions/YYYY-MM-DD.md and a terse update of DASHBOARD.md (Now, Next, Recently done, Open questions). Use when asked to log the session, wrap up, update the dashboard, or file the day. Not for meeting transcripts or the weekly status to a manager.
---

# Session log

## What this skill does
Turns one work session into two files in the brain folder. `DASHBOARD.md` is the current state and stays terse. `sessions/YYYY-MM-DD.md` is the dated record and stays verbose and append-only. Each fact is written once: detail in the dated note, one line plus a link in the dashboard. The reader is the user next week, or the person who takes over.

## When to use it
- "Log the session" or "wrap up"
- "Update the dashboard"
- "File today in the brain"

Do not use it for a meeting or a transcript; use `meeting-digest`. Do not use it for the manager update; use `weekly-status`.

## How to do it
1. Read: find the brain folder (ask if more than one candidate). Read `DASHBOARD.md` and today's `sessions/YYYY-MM-DD.md` if it exists. In every repo touched today run `git log --since=midnight --oneline` and `git status`. Reread the conversation for what actually happened.
2. Decide: sort the material into done, dead ends and why they failed, surprising findings, decisions and who made them, and the exact commands, paths and IDs needed to redo or undo the work. The commits already tell the happy path; the note holds the rest.
3. Check: every line has a source (a command, a file, a person). No secrets, not even masked. Any date in the dashboard that is now in the past gets flagged to the user as done-but-stale or slipped; never rewrite it silently.
4. Ask: when an open question has no named owner, ask one question: who answers this?
5. Write the dated note: append a new section to `sessions/YYYY-MM-DD.md`. Never edit earlier sections. Create the file from the template if missing.
6. Write the dashboard: refresh the four zones. Drop "Recently done" lines older than seven days. Budget is 60 lines; over budget means detail that belongs in the dated note.
7. Report the paths changed and any stale date found.

## What not to do
- Do not create a third tracking file; a new need goes into one of the two files or is raised to the user.
- Do not write a diary of the happy path; write what the commits cannot tell.
- Do not invent work that was not done; write `TODO: confirm` and the question.
- Do not archive old dated notes without asking.

## Output format
Appended to `sessions/YYYY-MM-DD.md`:
```
## HH:MM <topic>
- Done: <what, with the command or path>
- Dead ends: <what failed and why>
- Found: <surprising fact and its source>
- Decided: <decision, by whom>
- Redo or undo: <exact commands, paths, IDs>
```
`DASHBOARD.md`, four zones in this order, terse:
```
## Now
- <active item, one line>                       (1 to 3 lines)
## Next
- <verb first: what the next session does>
## Recently done
- YYYY-MM-DD  <item> (sessions/YYYY-MM-DD.md)   (last 7 days only)
## Open questions
- <question> -> <who answers>
```
