---
name: transcript-ingest
description: Ingest one raw meeting or handover transcript file (often Hebrew, often 60+ minutes, often auto-transcribed with errors) into the brain in one pass: read it to the end, write sessions/YYYY-MM-DD-<topic>.md with covered, decisions, action items, promises both ways, verbatim worth keeping, screens shown, new people, systems and terms, open questions, then propagate every delta to DASHBOARD.md and the context files (people, systems, terms, dilemmas, stories). Use when asked to ingest a transcript, file this recording, or process a handover session into the brain. Not for short pasted notes that need one note and no propagation (meeting-digest), or for a recorded self-debrief that is a recollection, not a transcript (debrief-memo).
---

# Transcript ingest

## What this skill does
Takes one raw transcript file and leaves the brain fully updated, so the user never has to remember where a fact goes. The raw file stays untouched in `transcripts/`. The output is one dated note in `sessions/` plus edits to `DASHBOARD.md` and the `context/` files. The difference from `meeting-digest`: this skill reads long and noisy input, works in chunks, and does the propagation itself. The reader is the user, later, when she needs what was agreed, who owes what, and what the previous owner said never to do.

## When to use it
- "Ingest this transcript" or "file this recording"
- "Process the handover session into the brain"
- A new file appears in `transcripts/` and the user says "file it"

Do not use it for a short pasted summary; use `meeting-digest`. Do not use it for a 2 to 4 minute self-debrief; use `debrief-memo`. The propagation rules are the `brain` skill's update mode; follow them, do not reinvent them.

## How to do it
1. Read, in this order: `CLAUDE.md` and `DASHBOARD.md` of the brain, then `context/people.md` (the name authority), `context/systems.md`, `context/terms.md`. Then the transcript, in chunks of about 300 lines, to the very end. Decisions and action items cluster at the end; a note written from the first chunk is wrong. After each chunk, append to a running list under a `## Scratch` heading at the bottom of the draft note: facts, decisions, actions, promises, names heard, terms heard, screens or systems shown, quotes worth keeping, questions. Delete the scratch heading before finishing.
2. Decide: for every item in the running list, which bucket: fact (with source), decision (who decided), action item (owner, date or `no date`), promise to the user or by the user, verbatim worth keeping (a rule, a warning, a number, a name of a thing), screen or system shown (what was seen, not just said), new person, new system, new term, story (a win or before/after moment), dilemma (an open decision with options), open question, or noise. Speaker attribution: when the transcript has no speaker labels, infer from content and write `(speaker inferred)`; when it cannot be inferred, write `(speaker unknown)`. Never assign a quote to a person on a guess.
3. Check: names against `context/people.md`; the brain's spelling wins. A name heard but not in the brain gets the transcript spelling plus `spelling unconfirmed`. A term heard in Hebrew gets the English term plus the Hebrew once. Verbatim lines are translated and keep the original in parentheses once. Every new fact carries `[?]` until a named source confirms it; a fact the user saw on screen is confirmed by `(seen on screen, YYYY-MM-DD)`. No secrets: a password, token or key read aloud becomes `<secret said in meeting, not recorded>` plus where it lives. Dates absolute. Nothing appears that the transcript did not say.
4. Ask: one batched question when the date is missing, when two known people could match a garbled name, or when an action has no owner. Do not guess a date; use the file's modification date only if the user agrees, and say so in the note header.
5. Write the note at `sessions/YYYY-MM-DD-<topic>.md` in the format below. Then propagate with the `brain` update rules: `DASHBOARD.md` (Last updated line, Now, This week row marked DONE with a link, Open questions add or close), `context/people.md` (new rows, spelling fixes with the trail `(prev. "X")`), `context/systems.md`, `context/terms.md`, `context/dilemmas.md` (new or changed decisions), `context/stories.md` (any win worth telling). Only touch files where something changed. Report every file touched, one line each, then the action items owned by the user.

## What not to do
- Do not summarize from the first screen of a long file; read to the end before writing a single section.
- Do not retell the meeting in prose; use the sections.
- Do not drop the verbatim lines; they are the part the user cannot regenerate.
- Do not "correct" a confirmed spelling in the brain back to a transcript variant.
- Do not invent owners, dates, or speakers; write `owner: TODO`, `no date`, `(speaker unknown)`.
- Do not modify or move the raw transcript file.
- Do not put a transcribed secret anywhere, not even masked.
- Do not file content that belongs to another engagement or to private life; skip it and tell the user what was skipped.

## Output format
`sessions/YYYY-MM-DD-<topic>.md`:
```
# <Topic> (YYYY-MM-DD)   source: transcripts/<file>, auto-transcribed, <language>
Participants: <names as in the brain; new ones with "spelling unconfirmed">. Length: <minutes or lines>.

## Covered
- <topic>: <two lines max>

## Decisions
- <decision> (<who decided>)

## Action items
- [ ] <action> -> <owner>, <date or "no date">

## Promises
- To me: <what> (<who>, <when said>)
- By me: <what> (<to whom>, <by when>)

## Verbatim worth keeping
- "<English>" (<original, once>) -> <who said it | speaker inferred | speaker unknown>

## Screens and systems shown
- <system or screen>: <what was seen, one line> (seen on screen)

## New people, systems, terms   -> copied to context/
- Person: <name>, <role> [?] spelling unconfirmed
- System: <name>, <what it does, one line> [?]
- Term: <term> = <meaning> (<original>) [?]

## Stories and dilemmas   -> copied to context/
- Story: <date, what, evidence, who saw it>
- Dilemma: <decision open, options, who decides, by when>

## Open questions
- <question> -> <who can answer>

## Next session's first topic
- <topic>
```
Then the report in chat:
```
Filed:
- sessions/YYYY-MM-DD-<topic>.md   created
- DASHBOARD.md                    Last updated, Now (+1), This week (DONE row), Open questions (+2, closed 1)
- context/people.md               added <name> (spelling unconfirmed), fixed <name> (prev. "<X>")
- context/systems.md              <system>: <what changed>
- context/terms.md                +<n> terms
- context/dilemmas.md             <dilemma>: <open | decided>
- context/stories.md              +1 (<what>)
Mine to do:
- [ ] <action> by <date>
```
