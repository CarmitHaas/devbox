---
name: handover-card
description: Write a one-page service card for a critical service from notes or a session, with Does and who consumes, Runs where, Deploys how, Config and secrets locations (never values), Observability, the 2am list of failure modes with exact actions, History, First command if it breaks, and what must never be done. Use when asked for a service card, a handover page for a service, or to capture what someone knows about a system. Not for a runbook of one operation or a Jira ticket.
---

# Handover card

## What this skill does
Captures what the person leaving knows about one service into a page the person arriving can act on at 2am. Facts only, each with a source and a confidence mark. Output is Markdown for the wiki.

## When to use it
- "Write the service card for <service>"
- "Make the handover page for <system>"
- "Capture what we learned about <service> today"

Do not use it for one procedure; use `runbook`. Do not use it for a day's log; use `session-log`.

## How to do it
1. Read: the notes, transcript, or chat about the service. List every fact with its source (person, file, command output). Separate what was seen from what was said.
2. Decide: place each fact in one section below. A failure mode needs symptom, what to check, what to do, who to call. A fact that fits nowhere goes under History or is dropped.
3. Check: no secret values, only locations (vault path, secret name, file path). Hostnames and URLs as given in the input or `<TBD>`. Facts the user has not confirmed get `[?]`. The 2am list is ordered by likelihood.
4. Ask: if "first command if it breaks" or "never do" is missing, ask one question: what did the previous owner say never to do? Do not invent either.
5. Write the format below. Under 60 lines. Every empty section gets a `TODO:` line; the empty sections are the handover gaps.

## What not to do
- Do not describe the service in marketing terms; one line of what it does.
- Do not paste config; name where it lives and who owns changes.
- Do not drop a fact because it is uncertain; mark it `[?]` with the source.
- Do not merge two services into one card.

## Output format
```
# <Service> card   (updated YYYY-MM-DD by <who>)

## Does, and who consumes it
<one line of function>. Consumers: <teams, pipelines, products>.

## Runs where
<cluster or hosts, environment, region, scaling> [?]

## Deploys how
<pipeline name, trigger, approval, duration, rollback mechanism>

## Config and secrets (locations only)
- Config: <repo path, chart values, env file path>
- Secrets: <vault path or secret name>, owner <team>

## Observability
- Dashboards: <name, where>
- Alerts: <name, who receives>
- Logs: <where, retention>

## The 2am list (most likely first)
1. Symptom: <what you see>. Check: `<command>`. Do: <action>. Call: <role>.

## History
- YYYY-MM-DD: <incident or change, one line> (source)

## First command if it breaks
`<command>` -> <what the output tells you>

## Never do
- <action>, because <consequence> (<who said so>)

## Gaps
- TODO: <section with no facts yet> -> ask <who>
```
