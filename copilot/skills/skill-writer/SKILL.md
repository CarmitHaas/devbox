---
name: skill-writer
description: Turn a procedure the user has done twice into a SKILL.md in the team skeleton (front matter, what it does, when to use it, how to do it, what not to do, output format) and check the three silent failures, folder Copilot reads, file named SKILL.md, name equals folder. Use when asked to make this a skill, pack this procedure, or write a skill for a repeated task. Not for writing instructions files or prompt files.
---

# Skill writer

## What this skill does
Takes a task done at least twice (the inputs, the result the user kept, and the corrections made on the way) and packs it into one `SKILL.md` that makes Copilot do it the same way next time. Output is the file, placed where Copilot reads it, plus a test request.

## When to use it
- "Make this a skill"
- "Pack what we just did into a skill"
- "Write a skill for <repeated task>"

Do not use it for a rule that holds in every chat; that is a line in the instructions file. Do not use it for one request with a variable; in VS Code Local that is a prompt file.

## How to do it
1. Read: the two examples: input, kept result, and every correction the user made. The corrections are the rules. Read the skeleton: front matter `name` and `description`; then What this skill does; When to use it (three phrasings and one "not for"); How to do it (read, decide, check, ask, write); What not to do; Output format.
2. Decide: the name, kebab-case, a word a teammate would type. Which corrections are this skill's rules, and which are standards that belong in the instructions file (for example "no emoji"); list the standards separately. The description says what it produces and when, in the teammate's words, and ends with one "not for" clause.
3. Check the three silent failures: the folder is one Copilot reads (`~/.copilot/skills/<name>/` personal, `.github/skills/<name>/` in a repo); the file is named exactly `SKILL.md`; the `name:` line equals the folder name. Then: under 80 lines, no personal paths, no customer names, no secrets, every step is an action (not "summarize appropriately").
4. Ask: if only one example exists, ask for the second or for the correction list. One example makes a template, not a skill.
5. Write the file. Then write the test: a new chat, the second input, the request in a teammate's words with no rules. If the format comes back, the skill works. If not, try `/<name>`; if that works, the description needs fixing.

## What not to do
- Do not write steps that restate the heading; each step names what to read, decide, check, ask, or write.
- Do not repeat a standard that lives in the instructions file; reference it.
- Do not exceed 80 lines; move long templates to a file next to `SKILL.md` and reference it.
- Do not invent phrasings; take them from how the user actually asked.

## Output format
```
Skill: <name>
Path: <folder>/SKILL.md
Silent failures: folder <ok|fix>, file name <ok|fix>, name equals folder <ok|fix>
Standards found (candidate instruction lines, kept out of the skill):
- rule: <...>
Test request (new chat, second input, no rules):
"<the teammate phrasing> for this: <input B>"
```
Then the full `SKILL.md` in the skeleton, under 80 lines.
