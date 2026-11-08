---
name: weekly-status
description: Write the weekly written status to a manager in six to eight lines, the same shape every week, Done, In progress, Blocked (with a name), Next week, Asks. Use when asked for the weekly status, the manager update, or the end-of-week summary. Not for daily standup prep or for a detailed report.
---

# Weekly status

## What this skill does
Collects the week's facts from the brain (dashboard, dated notes), the board, and the git log, and writes a short message a manager reads in one minute and can forward without editing. Same five headings every week, so changes stand out.

## When to use it
- "Weekly status"
- "Write the manager update"
- "End of week summary for my manager"

Do not use it for standup talking points; use `daily-prep`. Do not use it for a long report; this is six to eight lines.

## How to do it
1. Read: `DASHBOARD.md` and the dated notes since the last status. The board items that changed state this week. `git log --since="7 days ago" --oneline` in the repos touched.
2. Decide: Done means finished and verifiable this week. In progress means started and not done; give a fraction only when it is real, as steps done of steps total. Blocked means waiting on a named person or system. Next week is at most three items. Asks are decisions or access only the manager can give.
3. Check: every line is a fact with a noun and a verb. No adjectives. A blocker without a name is not a blocker; find the name or ask.
4. Ask: if a blocker has no clear owner, ask one question before writing.
5. Write six to eight lines in the format below. Each heading is one line. Join items with semicolons. No line over 160 characters.

## What not to do
- Do not write adjectives or adverbs ("significant", "smoothly", "very").
- Do not write "working on" without the next concrete step.
- Do not repeat last week's Done line.
- Do not include hostnames, secrets, or customer names if the message leaves the team.
- Do not claim completion when unsure; it goes under In progress.

## Output format
```
Status <YYYY-MM-DD>, week <N>
Done: <item>; <item>; <item>
In progress: <item (step X of Y)>; <item>
Blocked: <item> -> waiting on <name or system> since <date>; or "none"
Next week: <item>; <item>; <item>
Asks: <decision or access needed>, by <date>; or "none"
```
Optional seventh and eighth lines, only when true:
```
Risk: <one sentence, with the date it matters>
Note: <one fact the manager must hear from me before someone else says it>
```
