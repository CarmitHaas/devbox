---
name: debrief-memo
description: Turn the user's own recorded debrief of an untranscribed meeting (2 to 4 minutes spoken right after the meeting, answering six fixed prompts, transcribed locally to a text file) into the dated session note and the brain deltas, every fact marked as her recollection (source: own debrief, [?] until confirmed). Includes the six prompts to read aloud. Use when asked to file my debrief, process the memo, or when a short first-person recording about a meeting arrives. Not for a real meeting transcript with other speakers (transcript-ingest) or for pasted notes with no propagation (meeting-digest).
---

# Debrief memo

## What this skill does
Closes the loop for meetings that were not recorded: a hallway conversation, a call where recording was not allowed, a daily. Right after the meeting the user records herself for 2 to 4 minutes answering the six prompts below, transcribes it locally, and hands over the text file. This skill turns that text into `sessions/YYYY-MM-DD-<topic>.md` and propagates the deltas with the `brain` update rules, while keeping one thing visible everywhere: this is her memory of the meeting, not a record of it. The reader is the user a month later, deciding whether a line can be trusted.

## When to use it
- "File my debrief" or "process the memo"
- "I recorded myself after the meeting, here is the text"
- A short first-person text about a meeting lands in `inbox/` or `transcripts/`

Do not use it on a transcript with several speakers; use `transcript-ingest`. Do not use it on pasted written notes; use `meeting-digest`.

## The six prompts (read aloud, in order, right after the meeting)
```
1. What was decided, and by whom?
2. What did I promise, to whom, by when?
3. What did they promise me, by when?
4. What surprised me, or did not match what I expected?
5. Names and terms I heard: spell each one as I heard it.
6. What must I ask next, and whom?
Then: date, meeting title, who was in the room, how long it took.
```
Say "skip" for a prompt with nothing to say. Say the date even if it feels obvious.

## How to do it
1. Read: the debrief text to the end. Then `CLAUDE.md`, `DASHBOARD.md`, `context/people.md` (the name authority) and `context/terms.md` of the brain. Match each name and term the user said to an existing entry.
2. Decide: map the text onto the six prompts even if she answered them out of order. Each statement becomes a decision (who decided, as she remembers it), a promise by her (an action item with her as owner), a promise to her (an action item with the other person as owner), a surprise (a fact, and often a story or a dilemma), a name or term (new or matched), or a question (open question with who can answer). A surprise that changes a plan is a dilemma candidate; a surprise that is a win is a story candidate. Everything else is noise.
3. Check: the note header carries `source: own debrief`. Every fact that enters a context file carries `[?]` and `(own debrief YYYY-MM-DD)` as its source, until a named person or a written record confirms it. Names not in the brain get `spelling unconfirmed`. Numbers and dates she recalled are written as she said them, with `(recalled)`. Dates absolute. No secrets: if she said one aloud, write `<secret, not recorded>`. Nothing appears that she did not say; a prompt she skipped gets `skipped` in the note, not a filled-in guess.
4. Ask: one question only if the meeting date or title is missing from the recording. Do not fill either from the file name without saying so in the header.
5. Write the note at `sessions/YYYY-MM-DD-<topic>.md` in the format below. Then propagate with the `brain` update rules: `DASHBOARD.md` (Last updated, Now, This week row, Open questions), `context/people.md`, `context/terms.md`, `context/systems.md` if a system was named, `context/dilemmas.md`, `context/stories.md`. Each propagated line ends with `[?] (own debrief YYYY-MM-DD)`. Move the debrief text file into `transcripts/` as `YYYY-MM-DD-<topic>-debrief.txt` if it is in `inbox/`. Report every file touched and the promises she made, so she sees her own list first.

## What not to do
- Do not present a recollection as a transcript; the `source: own debrief` line and the `[?]` marks stay on every derived fact.
- Do not remove a `[?]` placed by this skill without naming the person or document that confirmed it.
- Do not merge two debriefs into one note; one meeting, one note.
- Do not invent what a skipped prompt would have said.
- Do not quote the other participants verbatim; she is paraphrasing from memory, so write `she recalls <who> saying <what>`.
- Do not record a secret, not even masked.

## Output format
`sessions/YYYY-MM-DD-<topic>.md`:
```
# <Meeting title> (YYYY-MM-DD)   source: own debrief, recorded <HH:MM or "right after">, transcripts/<file>
In the room (as recalled): <names; new ones with "spelling unconfirmed">. Length: <minutes>.
Confidence: this note is my recollection, not a transcript. Every fact below is [?] until confirmed.

## Decided (as I remember it)
- <decision> (<who decided>) [?]

## I promised
- [ ] <what> -> me, <by when or "no date">

## They promised
- [ ] <what> -> <who>, <by when or "no date"> [?]

## Surprised me
- <what I expected> vs <what happened> -> <story | dilemma | fact> [?]

## Names and terms heard
- <name as heard>, <role if known> [?] spelling unconfirmed
- <term as heard> = <what I think it means> [?]

## Ask next
- <question> -> <who>

## Skipped prompts
- <number: skipped>
```
Then the report in chat:
```
Filed (own debrief, all facts [?]):
- sessions/YYYY-MM-DD-<topic>.md   created
- DASHBOARD.md                    <zones touched>
- context/people.md               +<n> (spelling unconfirmed)
- context/terms.md                +<n>
- context/dilemmas.md             <dilemma>: open
- context/stories.md              +<n>
- transcripts/YYYY-MM-DD-<topic>-debrief.txt   moved from inbox/
I promised:
- [ ] <what> by <date>
To confirm with a named source before trusting:
- <fact> -> <who>
```
