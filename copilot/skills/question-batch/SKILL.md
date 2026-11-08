---
name: question-batch
description: Turn a pile of open questions into one numbered Teams message per person, ordered by priority (P1 blocks a runbook or task, P2 blocks a normal day, P3 good to know), at most five per message, each answerable in one line, with where the answer will be filed. Use when asked to batch questions, write the questions for someone, or clear the open questions list. Not for a status message or a meeting digest.
---

# Question batch

## What this skill does
Reads open questions from the brain or a pasted list, assigns each to the one person who can answer, orders by priority, and writes one short Teams message per person. The reader is a busy colleague who answers between meetings.

## When to use it
- "Batch my open questions"
- "Write the questions for <name>"
- "Clear the open questions list"

Do not use it for the weekly message; use `weekly-status`. Do not use it to file a meeting; use `meeting-digest`.

## How to do it
1. Read: the open questions (dashboard zone, dated notes, or pasted). For each, find the owner named in the notes.
2. Decide: priority. P1 blocks a runbook or a task today. P2 blocks a normal working day this week. P3 is good to know. Merge duplicates. Reword each question so a one-line answer closes it; split any that cannot be.
3. Check: at most five questions per message, P1 first. Each question names the thing precisely (job name, file path, environment) as it appears in the notes. Every question has a filing place: the dashboard line or note it updates.
4. Ask: if a question has no owner, ask the user one question: who knows this? Do not guess the owner.
5. Write one message per person in the format below. The opening line is one sentence, no apology. Questions beyond five go to a second message, dated for later.

## What not to do
- Do not send one question per message; batch.
- Do not write questions that need a meeting to answer; split or reword.
- Do not write "when you have time"; give the priority instead.
- Do not paste logs or secrets; name where they are.
- Do not invent owners; write `owner: TODO`.

## Output format
```
To: <name>  (<N> questions, <n> of them P1)
Hi <name>, <N> short questions, a one-line answer each is enough.
1. [P1] <question> (<context: job, path, env>)
2. [P2] <question>
3. [P3] <question>
Thanks.

Filing: 1 -> <dashboard zone or note>; 2 -> <...>; 3 -> <...>
```
Repeat per person. Then:
```
Not sent: <questions with no owner> -> owner: TODO
Later: <questions beyond five per person> -> second message on <date>
```
