---
name: runbook
description: Write a Confluence-ready runbook from notes, shell history, or a chat, with Purpose, When to run, Preconditions, numbered Steps each with the command and the expected output, Verification, Rollback, Owners, Last tested. Use when asked to write a runbook, turn history into a procedure, or document how to do an operation. Not for architecture docs, READMEs, or Jira tickets.
---

# Runbook

## What this skill does
Takes a procedure that worked (a shell history, a chat where it was done, a page of notes) and writes it as a runbook the on-call engineer can follow at 2am without the author. Every step has a check. Output is Markdown the user pastes into Confluence.

## When to use it
- "Write the runbook for this"
- "Turn this shell history into a procedure page"
- "Document how we do <operation>"

Do not use it for a README or an architecture page; use plain chat. Do not use it for a service overview; use `handover-card`.

## How to do it
1. Read: the whole input. Identify the goal, the system, the environment, and the order of commands that actually worked. Drop typos and dead ends; they are not steps.
2. Decide: split into preconditions (access, tools, state), steps (one action each), verification (how you know it worked), and rollback (how to get back). A step that changes shared state gets a `Confirm:` line before it.
3. Check: every step has a command and an expected output or an observable result. No command uses a value that was not defined in a precondition or an earlier step. Secrets appear as a path or a vault key, never a value. Hostnames and ticket keys come from the input or are `<TBD>`.
4. Ask: if the rollback is not in the input, ask one question: how was this undone, or has it never been undone? Do not invent a rollback.
5. Write the format below. Owners and Last tested are placeholders unless given.

## What not to do
- Do not write a step without a check; split it or add the expected output.
- Do not write "verify everything is fine"; name the command and the value.
- Do not put two actions in one step.
- Do not document dead ends; a known trap goes under Notes as one line.
- Do not invent expected outputs; write `Expected: TODO, run once and paste`.

## Output format
```
# Runbook: <operation> on <system>

**Purpose:** <one sentence: what this achieves and for whom>
**When to run:** <trigger: alert, schedule, request>
**Preconditions:**
- Access: <role or group, not a credential>
- Tools: <cli and version>
- State: <what must be true before step 1, and the command that proves it>

## Steps
1. <action>
   `<command>`
   Expected: <output or observable result>
2. <action that changes shared state>
   Confirm: <who or what approves>
   `<command>`
   Expected: <...>

## Verification
- `<command>` -> <value that means success>

## Rollback
1. `<command>` -> <expected>
   Point of no return: <step after which rollback no longer applies, or "none">

## Notes (optional)
- <known trap, one line>

**Owners:** <team or role, TBD>
**Last tested:** <YYYY-MM-DD by whom, TBD>
```
