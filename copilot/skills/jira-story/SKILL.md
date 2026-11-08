---
name: jira-story
description: Write a Jira story from a request or a thread, with a summary under 70 characters, description, acceptance criteria as Given/When/Then, definition of done, out of scope, dependencies; or a bug with steps to reproduce, expected, actual, impact, and logs location. Use when asked to write a story, a ticket, or a bug report. Not for PR descriptions or runbooks.
---

# Jira story

## What this skill does
Turns a request, a chat thread, or a one-line idea into a ticket the team can pick up without asking the author. Two shapes: story and bug. Output is text the user pastes into Jira.

## When to use it
- "Write the story for this"
- "Make a ticket out of this thread"
- "Write the bug for what we just saw"

Do not use it for the PR text; use `pr-description`. Do not use it for a procedure; use `runbook`.

## How to do it
1. Read: the input in full. Find who needs what and why. For a bug, find what happened, when, where, and what was expected instead.
2. Decide: story or bug. A story changes behavior or adds capability. A bug is behavior that differs from what is documented or agreed. One ticket per outcome; if the input has two outcomes, propose two tickets.
3. Check: the summary is under 70 characters and starts with a verb (story) or a component (bug). Each acceptance criterion is testable by someone else. Out of scope names the nearby thing people will assume is included. No names of people in the body. No invented keys, links, or hostnames.
4. Ask: if the "why" is not in the input, ask one question. If the environment of a bug is unknown, ask which one.
5. Write the format below. Priority is a suggestion with a one-line reason, or omitted.

## What not to do
- Do not write acceptance criteria that restate the summary; each one is a scenario.
- Do not write "as a user I want" when the actor is a pipeline or a team; name the real actor.
- Do not pad definition of done with generic lines; keep the ones this ticket needs.
- Do not invent reproduction steps; write what was observed and `TODO: reproduce`.

## Output format
Story:
```
Summary: <verb first, under 70 chars>
Description: <two to four sentences: who, what, why>
Acceptance criteria:
- Given <state>, when <action>, then <result>
- Given <...>, when <...>, then <...>
Definition of done:
- <merged; deployed to <env>; documented where; monitored how>
Out of scope: <the nearby thing not included>
Dependencies: <ticket, team, access, or "none">
Priority (suggested): <P> because <one line>
```
Bug:
```
Summary: <component>: <symptom>, under 70 chars
Environment: <env, version, date and time seen>
Steps to reproduce:
1. <step>
Expected: <what should happen>
Actual: <what happened, with the exact error line>
Impact: <who or what is affected, how often>
Logs: <where: job URL pattern, log path, dashboard; never pasted secrets>
Workaround: <if any, or "none known">
```
