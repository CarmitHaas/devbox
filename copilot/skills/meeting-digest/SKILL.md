---
name: meeting-digest
description: Turn raw meeting notes or a transcript, often in Hebrew, into an English dated note with Covered, Decisions, Action items with owner, Verbatim worth keeping, New terms, people and systems, and Open questions, then list the dashboard lines to update. Use when asked to digest a meeting, file a transcript, or summarize a call for the notes folder. Not for end-of-day session logs or a status message to a manager.
---

# Meeting digest

## What this skill does
Takes a transcript or raw notes from one meeting (any language, Hebrew is common) and produces one English note for the brain's `sessions/` folder, plus the list of dashboard lines the meeting changed. The reader is the user, later, when she needs what was agreed and who owes what.

## When to use it
- "Digest this meeting"
- "File this transcript"
- "Summarize the call into the brain"

Do not use it for a day's work log; use `session-log`. Do not use it for a Teams message; use `question-batch` or `weekly-status`.

## How to do it
1. Read: the whole input first. Note the date, the participants, and the purpose. If the input is a file, read it to the end, not the first screen.
2. Decide: sort each statement into fact, decision, action, opinion, or noise. A decision needs who decided. An action needs an owner and a date, or `no date` written out. Verbatim is a sentence that carries a rule, a warning, a number, or the name of a thing; translate it and keep the original in parentheses once.
3. Check: names and system names spelled as in the input. Hebrew terms get the English term plus the Hebrew once. Nothing appears that the input did not say. Mark unconfirmed facts `[?]`.
4. Ask: if the date or the participant list is missing, ask one question. Do not guess a date.
5. Write the note in the format below, then the dashboard lines. If a brain folder is open, write to `sessions/YYYY-MM-DD-<topic>.md`; otherwise print it.

## What not to do
- Do not retell the meeting in prose; use the sections.
- Do not drop the verbatim lines; they are the part the user cannot regenerate.
- Do not invent owners or dates; write `owner: TODO`.
- Do not record secrets said aloud; write `<secret said in meeting, not recorded>`.
- Do not put opinions under Decisions.

## Output format
```
# <Meeting title> (YYYY-MM-DD)
Participants: <names as given>. Source: <transcript file or "pasted notes">.

## Covered
- <topic>: <two lines max>

## Decisions
- <decision> (<who decided>)

## Action items
- [ ] <action> -> <owner>, <date or "no date">

## Verbatim worth keeping
- "<English>" (<original, once>) -> <who said it>

## New terms, people, systems
- Term: <term> = <meaning> [?]
- Person: <name>, <role>
- System: <name>, <what it does, one line>

## Open questions
- <question> -> <who can answer>

## Dashboard lines to update
- <zone>: <the exact line to add or change>
```
