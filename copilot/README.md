# Copilot layer

Carmit's personal GitHub Copilot setup: the working method from Claude Code, carried into Copilot CLI (WSL) and Copilot chat in VS Code, Claude Opus 5.5 model. Public repo: generic DevOps content only, no client data, no secrets.

| File | What it is |
|---|---|
| `copilot-instructions.md` | Personal instructions, installed at `~/.copilot/copilot-instructions.md` |
| `skills/<name>/SKILL.md` | Eighteen personal skills, installed at `~/.copilot/skills/<name>/` |
| `install.sh` | Copies both into place, backs up what was there; `--dry-run` prints without writing |
| `claude-code-to-copilot.md` | Mapping table, verified CLI cheat sheet, habits that transfer, honest gaps |
| `first-session.md` | A 15-minute script for the first CLI session on a new machine |

Install: `./install.sh --dry-run`, then `./install.sh`. Start `copilot` in any folder, run `/skills list` and `/instructions` to confirm both layers loaded. A running session does not pick up changes; start a new one.

Test each skill in a new chat with one sentence. If the format comes back without you repeating a rule, it works. If not, try `/<name>` first.

| Skill | Type this |
|---|---|
| `commit` | "Commit this" |
| `session-log` | "Log the session into the brain at ~/notes" |
| `meeting-digest` | "Digest this meeting" (paste the transcript) |
| `daily-prep` | "Prep the daily" (paste the board list) |
| `weekly-status` | "Weekly status for my manager" |
| `runbook` | "Write the runbook for this" (paste shell history) |
| `jira-story` | "Write the story for this" or "Write the bug for this" |
| `pr-description` | "Write the PR description for this branch" |
| `question-batch` | "Batch my open questions" |
| `explain-screenshot` | "Caption this screenshot" (attach or describe it) |
| `handover-card` | "Write the service card for the build pipeline" |
| `skill-writer` | "Make this a skill" (after doing a task twice) |
| `brain` | "brain new acme" to scaffold an engagement brain; "brain update" or "file this" after a session |
| `transcript-ingest` | "Ingest this transcript" (point at the raw file in transcripts/) |
| `debrief-memo` | "File my debrief" (the text of a 2 to 4 minute self-recording after an untranscribed meeting) |
| `deck` | "Make a deck about this" or "Build the status slides from the brain" (outline first, then a .pptx) |
| `architecture-diagram` | "Draw the architecture of this" or "Fix the arrows in this .drawio" |
| `explainer-page` | "Make a page out of this markdown" (one offline HTML file: guide, runbook, handover doc) |
