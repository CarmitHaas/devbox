---
name: explain-screenshot
description: Write a two-sentence annotated caption for a screenshot or its description, for a notes wiki, covering what tool, what screen, what matters here, and what to do next. Use when asked to caption a screenshot, explain this screen, or annotate an image for the notes. Not for writing a runbook or a bug report from the image.
---

# Explain screenshot

## What this skill does
Takes a screenshot (attached image) or the user's description of one and returns a caption of exactly two sentences, plus a file name. The caption sits next to the image in the notes wiki, where the user reads it weeks later without the context.

## When to use it
- "Caption this screenshot"
- "Explain this screen for my notes"
- "Annotate this image"

Do not use it to write the procedure shown; use `runbook`. Do not use it to report the error shown; use `jira-story`.

## How to do it
1. Read: the image or description in full. Identify the tool (for example Jenkins, Grafana, Jira, a terminal, a cloud console), the specific screen (job console, dashboard panel, board), and the one element the user cares about (an error, a value, a toggle).
2. Decide: what matters is the element that changes what the user does next. If several, pick the one the user mentioned, or the one in red.
3. Check: nothing in the caption that is not visible or stated. Values quoted exactly as shown. No secrets, tokens, or internal URLs copied; write `<redact>` where one is visible and tell the user.
4. Ask: if the tool or the reason for the screenshot is unclear, ask one question. Do not guess the tool.
5. Write exactly two sentences in the format below, then the file name `YYYY-MM-DD-<tool>-<screen>.png`.

## What not to do
- Do not describe the whole screen; two sentences only.
- Do not write "this shows a screenshot of"; start with the tool and the screen.
- Do not invent what is behind a button or a tab that is not open.
- Do not add a third sentence of advice; "what to do next" is inside sentence two.

## Output format
```
<Tool>, <screen>: <what matters here, with the exact value or text seen>. <What to do next>, <why, one clause>.
File: YYYY-MM-DD-<tool>-<screen>.png
Redact: <element and where, or "nothing">
```
Example:
```
Jenkins, build console for job api-build #412: the first error is "MSB4019: imported project not found" in the Build stage, not the exit code 1 at the end. Check the .NET SDK path on the agent before rerunning, because the job itself is unchanged since #411.
File: 2026-11-09-jenkins-console-api-build-412.png
Redact: nothing
```
