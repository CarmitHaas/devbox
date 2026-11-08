# Template for CLAUDE.md, the entry file of a brain

Copy everything below the line into `<name>/CLAUDE.md`. Replace every `<...>`; what is not known becomes a `TODO:` line, never a guess. Keep it under 60 lines; the entry file points, it does not store. Copilot CLI reads it through the one-line `AGENTS.md` next to it.

---

# <Engagement name> brain

<Who I am here, one sentence: role, who I report to, start date YYYY-MM-DD, capacity, through which company.>
<What the engagement is, one sentence.>
Entry point for every work session on this engagement. Read first, every time.

## Read path (start of any session)

1. `DASHBOARD.md`: current state, this week, open questions, standing facts.
2. Then as the task needs: `context/people.md` (who is who, who owns what) · `context/systems.md` (the estate, where config and secrets live, never values) · `context/terms.md` (glossary) · `context/compliance.md` (what binds me, what triggers a question) · `context/stories.md` (wins to show) · `context/dilemmas.md` (open decisions) · `sessions/` (dated notes, newest first) · `transcripts/` (raw inputs, untouched) · `docs/` (explainers and guides) · `inbox/` (dropped, not yet filed).

## Confidentiality rules (absolute)

- Everything internal to this engagement (systems, names, pipelines, incidents, code) lives in THIS folder and in chat with me only. Never into public repos, artifacts, posts, or another engagement's folder.
- Secrets and credentials are NEVER written here, not even masked. Locations only (vault path, secret name, file path).
- <Add the engagement's own rules: NDA scope, export or trade rules, data residency. TODO: confirm with <who>.>

## Update pass (after any session, meeting, or handover)

1. `sessions/YYYY-MM-DD.md`: covered, decisions with who, action items with owner, promises both ways, verbatim worth keeping, open questions. Template in `sessions/TEMPLATE.md`.
2. `DASHBOARD.md`: Now, This week, Open questions (add or close), Standing facts, the `Last updated` line.
3. `context/`: new person -> `people.md`; new system fact -> `systems.md`; new term -> `terms.md`; new constraint -> `compliance.md`; a win or before/after moment -> `stories.md`; an open decision -> `dilemmas.md`. Hypotheses carry `[?]` until a named source confirms them.
4. Empty `inbox/`.
Run it with the `brain` skill ("brain update"). A raw transcript goes through `transcript-ingest`; a spoken self-debrief goes through `debrief-memo`.

## Operating rules (the short version)

- Absorb, then operate, then improve, strictly in that order. Never criticize what the previous owner built.
- Changes are small, reversible, announced, and reverted first when in doubt.
- Blockers are named the same day. The board or the ticket is the voice.
- Weekly written status to <manager>, same weekday, unprompted.
- <TODO: add the rules this engagement taught, one line each, dated.>

## Standing facts

- Started: <YYYY-MM-DD>. Reports to: <name, role> [?]. Office days: <TODO>.
- <The three facts someone covering for me would need on day one. TODO.>
