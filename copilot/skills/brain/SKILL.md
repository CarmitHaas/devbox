---
name: brain
description: Create or maintain an engagement brain, the one folder that is a project's whole memory. "brain new <name>" scaffolds it (CLAUDE.md entry file, AGENTS.md, DASHBOARD.md, context/ for people, systems, terms, compliance, stories and dilemmas, sessions/, transcripts/, docs/, inbox/). "brain update" propagates one session or meeting into the dated note, the dashboard and the context files. Use when asked to start a brain for a new client or project, to file this, to run the update pass, or to update the brain. Not for digesting a raw transcript (transcript-ingest), a spoken debrief (debrief-memo), or a plain end-of-day log with no brain (session-log).
---

# Brain

## What this skill does
Two modes, one folder. A brain is the single memory of one engagement: an entry file read first every session, a dashboard of current state, context files for people, systems, terms, compliance, stories and dilemmas, dated session notes, raw transcripts, and docs. `brain new <name>` creates that folder from the templates. `brain update` takes what just happened (a work session, a meeting, a chat) and propagates it so nothing is remembered in only one head. The reader is the user next week, or on a new machine where this folder is the only guidance.

## When to use it
- "brain new <name>" or "start a brain for <client or project>"
- "brain update", "file this", "run the update pass", "update the brain"
- "Where does this fact go?" when a brain exists

Do not use it on a raw transcript file; use `transcript-ingest`. Do not use it on a recorded self-debrief; use `debrief-memo`. Both of those end by calling the update rules below, so the propagation happens once, here.

## How to do it

### Mode 1: brain new <name>
1. Read: the folder the user points at, or the current folder. If `CLAUDE.md` or `DASHBOARD.md` already exists, stop and switch to update mode; never overwrite a brain. Read `TEMPLATE-ENTRY.md` next to this file. Collect what is known: engagement name, role, start date, who the user reports to, the one-line goal.
2. Decide: the folder name, kebab-case. Which known facts fill the entry file and which become `TODO:` lines. A fact heard but not confirmed in writing gets `[?]`.
3. Check: no secret, token, password or credential anywhere, not even masked. No fact invented to fill a template placeholder; an unknown stays `TODO:`.
4. Ask: one question only if the engagement name or the start date is missing. Everything else is scaffolded with `TODO:` and listed for the user to chase.
5. Write the tree below. `CLAUDE.md` comes from `TEMPLATE-ENTRY.md` with placeholders filled. `AGENTS.md` is one line. Every context file gets its header, its one-line purpose, and the `[?]` legend. `sessions/TEMPLATE.md` uses the note format below. Create `transcripts/`, `docs/`, `inbox/` with a `.gitkeep`. Report the file list and the open `TODO:` lines.

### Mode 2: brain update
1. Read: `CLAUDE.md` (the read path and rules), `DASHBOARD.md`, today's note in `sessions/` if any, and the context files the topic touches. Then reread the conversation or the input for what actually happened. Check `inbox/` for anything dropped there and not yet filed.
2. Decide: sort every statement into a fact, a decision (who decided), an action item (owner, date or `no date`), a promise (made to the user or by the user), a story (a win or a before/after moment worth telling later), a dilemma (an open decision with options), a new person, system or term, or noise. One fact lives in one place: detail in the dated note, one line plus a link everywhere else.
3. Check: every fact names its source (a person, a file, a command, a date). Hypotheses carry `[?]` until a named source confirms them; a confirmed fact drops the mark and gains the source. Dates are absolute (`2026-03-14`, never "next Tuesday"). No secrets. A fact that contradicts the brain is superseded by annotation (`(was X, changed YYYY-MM-DD, source)`), never by silent deletion.
4. Ask: one batched question if an owner, a date, or the right person for a garbled name is unknown. Do not guess; file with `owner: TODO` or `spelling unconfirmed` if no answer comes.
5. Write, in this order: the dated note `sessions/YYYY-MM-DD.md` (append a section, never edit earlier ones); `DASHBOARD.md` (Now, This week, Open questions add or close, Standing facts); `context/people.md`, `systems.md`, `terms.md`, `compliance.md` for new facts; `context/stories.md` for each win; `context/dilemmas.md` for each open decision (new or status change). Update the `Last updated` line. Report every file touched, one line each, and the action items owned by the user.

## What not to do
- Do not invent a fact, an owner, or a date to make a template look complete.
- Do not write a fact twice; link to where it lives.
- Do not strip a `[?]` without naming who confirmed it.
- Do not create a new tracking file; a new need goes into an existing file or is raised to the user.
- Do not put anything from this brain into a public repo, a post, or another engagement's folder.
- Do not record a secret said aloud or seen on screen; write `<secret, not recorded>` and the location it lives in.

## Output format
Tree created by `brain new <name>`:
```
<name>/
  CLAUDE.md          entry file: who, what, read path, confidentiality, update pass
  AGENTS.md          "Read CLAUDE.md first. It is the entry file for this folder."
  DASHBOARD.md       Now / This week / Open questions / Standing facts
  context/people.md     who, role, what they own, how to reach, [?] marks
  context/systems.md    the estate: what runs where, who owns it, locations of config and secrets (never values)
  context/terms.md      glossary: term = meaning, source, [?]
  context/compliance.md what binds the user (NDA, export rules, data rules), what triggers a question
  context/stories.md    wins to show: date, what, before/after, evidence, who saw it
  context/dilemmas.md   open decisions: dilemma, options with trade-offs, who decides, by when, status
  sessions/TEMPLATE.md  the dated note skeleton below
  transcripts/          raw inputs, untouched, named YYYY-MM-DD-<topic>.<ext>
  docs/                 explainers, guides, anything rendered for reading
  inbox/                dropped items not yet filed; empty after every update pass
```
`DASHBOARD.md` skeleton:
```
# <Name> dashboard
Last updated: YYYY-MM-DD (<one line: what changed>)
## Now
- <active item, one line>                          (1 to 3 lines)
## This week
| Day | Moves |
|---|---|
| Mon YYYY-MM-DD | <planned or DONE: what, link to sessions/ note> |
## Open questions
1. <question> -> <who answers> (asked YYYY-MM-DD) [?]
## Standing facts
- <fact that does not change weekly> (source)
```
`sessions/TEMPLATE.md` and every dated note:
```
# <Topic> (YYYY-MM-DD)   source: <transcript file | own debrief | live session>
## Covered
- <topic>: <two lines max>
## Decisions
- <decision> (<who decided>)
## Action items
- [ ] <action> -> <owner>, <date or "no date">
## Promises
- To me: <what> (<who>, by when)
- By me: <what> (<to whom>, by when)
## Verbatim worth keeping
- "<English>" (<original, once>) -> <who>
## New people, systems, terms   -> copied to context/
- Person: <name>, <role> [?]
## Stories and dilemmas   -> copied to context/stories.md, context/dilemmas.md
- Story: <date, what, evidence, who saw it>
## Open questions
- <question> -> <who can answer>
## Next session's first topic
- <topic>
```
`context/stories.md` row: `| YYYY-MM-DD | <what happened> | <before -> after> | <evidence: link, number, screenshot path> | <who saw it> |`
`context/dilemmas.md` block: `## <dilemma>` then `Options:` (each with trade-off), `Decides:`, `By:` (absolute date), `Status: open | decided YYYY-MM-DD (<choice>, <who>)`.
