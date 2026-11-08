# Claude Code to Copilot

For an engineer who lives in Claude Code and now works in GitHub Copilot: the CLI in a WSL terminal, and chat in VS Code, with the Claude Opus 5.5 model. Same method, different tool.

Verified against docs.github.com and code.visualstudio.com on 2026-11-08. Items marked "verify on your machine" depend on the Copilot version installed and on the organization's policies. Sources are at the bottom.

## The one-minute version

- Copilot is customized by files, like Claude Code. The personal layer is `~/.copilot/`. The repo layer is `.github/`. An admin can add an organization layer on top.
- In a repo, Copilot reads `AGENTS.md`, `CLAUDE.md`, `.claude/CLAUDE.md`, and `.claude/skills/` as they are. Repo habits carry over.
- It does not read `~/.claude/`. Personal instructions and skills must move to `~/.copilot/`. That is what `install.sh` does.
- All applicable instruction files are combined. There is no precedence. A contradiction is yours to fix at the source.
- A line in an instructions file is a request. What must never happen goes in a hook or a CI gate.
- VS Code chat has several "harnesses", chosen with Session Target. The Copilot harness reads the same files as the CLI. The Local harness reads VS Code profile settings and is the only one that runs prompt files.

## Mapping table

| Claude Code | Copilot CLI | Copilot in VS Code |
|---|---|---|
| `CLAUDE.md` in the repo | read as is; also `AGENTS.md`, `.github/copilot-instructions.md`, `GEMINI.md` | same; `chat.useClaudeMdFile` is on by default |
| `~/.claude/CLAUDE.md` | `~/.copilot/copilot-instructions.md`; extra files in `~/.copilot/instructions/*.instructions.md` | Copilot harness: same file. Local harness: User instructions in the VS Code profile, via Chat: Open Customizations |
| `.claude/rules/*.md` with `paths` | `.github/instructions/*.instructions.md` with `applyTo:` | same |
| `.claude/skills/<name>/SKILL.md` in the repo | read as is; also `.github/skills/`, `.agents/skills/` | same |
| `~/.claude/skills/` | `~/.copilot/skills/` or `~/.agents/skills/`. `~/.claude/skills/` is not listed for the CLI | Local harness also reads `~/.claude/skills/`; Copilot harness does not. Verify on your machine |
| `.claude/commands/*.md` | none. Write a skill; it is invocable as `/<name>` | Local harness: `.github/prompts/*.prompt.md`, run as `/name`. The Copilot harness does not load them |
| `.claude/agents/*.md` | `.github/agents/*.agent.md`; personal `~/.copilot/agents/`; pick with `/agent` or `--agent=` | same files; Agent dropdown in the chat input |
| Hooks in `settings.json` | `.github/hooks/*.json`; personal `~/.copilot/hooks/`; different JSON (`"version": 1`, `"hooks": {event: [...]}`) | same files; Preview; `chat.useHooks` on by default for Local |
| `.mcp.json` | `.mcp.json` or `.github/mcp.json` in the repo; personal `~/.copilot/mcp-config.json`; `/mcp add` | Copilot harness: same files. Local harness: `.vscode/mcp.json`, labeled deprecated in the guided flow but still read |
| Auto memory | Copilot Memory: `/memory show`, `/memory off`; off in `-p` mode unless `--enable-memory` | same feature |
| `/init` | `/init` | `/init` (VS Code 1.109 and later) |
| `/compact` | `/compact [focus]` | `/compact` |
| `/clear` | `/clear`, `/new`; `/new worktree` | `/clear`; Ctrl+N new chat |
| `/cost` | `/usage` | not documented |
| `/context` | `/context` | not documented |
| `/model` | `/model`, `--model=`, `COPILOT_MODEL` | model picker in the chat input |
| `/mcp` | `/mcp`, `/mcp list`, `copilot mcp list` | MCP Servers section in Open Customizations |
| `/agents` | `/agent` (pick), `/subagents` (models per subagent) | Agent dropdown |
| `/memory` (edit the file) | `/instructions` (view and toggle files) | Chat: Open Customizations |
| `/resume`, `claude -c` | `/resume`, `--resume`, `copilot --continue` | chat history list |
| `/add-dir` | `/add-dir PATH`, `--add-dir=PATH` | add folder to workspace |
| `/status`, `/doctor` | `/session`, `/version`, `/collect-debug-logs` | not documented |
| `/help` | `/help`; `?` on an empty prompt | `/help` (Local, Ask) |
| `/exit` | `/exit`; Ctrl+C twice; Ctrl+D | close the view |
| `/review` | `/review`, `/security-review` | Copilot code review |
| Plan mode, Shift+Tab | Shift+Tab cycles standard, plan, autopilot; `/plan`, `--plan` | Plan in the Agent dropdown |
| `@file` | `@path`, Tab completes | `#file`, drag and drop |
| `!cmd` | `!cmd`; a lone `!` enters shell mode | the terminal |
| `claude -p "..."` | `copilot -p "..."`; `-s` for clean output | not documented |
| `--allowedTools`, `--disallowedTools` | `--allow-tool='shell(git:*)'`, `--deny-tool=write` | Permissions control in the chat input |
| `--dangerously-skip-permissions` | `--allow-all`, `--yolo`, `/permissions allow-all`. An admin can block it | not documented |
| `--output-format json` | `--output-format=json` (JSONL) | not documented |
| Background tasks | `/tasks`; Ctrl+X then b | not documented |
| Subagents | built-in subagents; custom agents; `/fleet` for parallel; `/delegate` to a cloud PR | subagents via custom agents |
| Worktrees | `/worktree`, `/new worktree` | not documented |
| `/rewind` | `/undo`, `/rewind` | not documented |
| Managed settings | organization instructions, set by a GitHub admin | `github.copilot.chat.organizationInstructions.enabled` |

## Copilot CLI cheat sheet

### Install (WSL)

| Method | Command | Note |
|---|---|---|
| script | `curl -fsSL https://gh.io/copilot-install \| bash` | no Node needed; `PREFIX=` for a custom directory, `VERSION=` to pin |
| npm | `npm install -g @github/copilot` | Node.js 22 or later |
| brew | `brew install --cask copilot-cli` | macOS and Linux |
| winget | `winget install GitHub.Copilot` | the Windows side, needs PowerShell 6 or later |

Update from inside a session: `/update`. Prerequisites: a Copilot subscription, and the org has not disabled the CLI.

### Login

`copilot`, then `/login`, follow the browser or device flow. `/user` shows the account. Token alternative for scripts: `COPILOT_GITHUB_TOKEN` (then `GH_TOKEN`, `GITHUB_TOKEN`), a fine-grained PAT with the "Copilot Requests" permission.

### Start

`cd <repo>` then `copilot`. Trust prompt: 1 this session, 2 remember this folder, 3 no. `copilot -i "prompt"` starts interactive and runs a first prompt. `copilot --plan` starts in plan mode.

### Model

`/model` or `/models` opens the picker. `--model=claude-opus-5.5` or `export COPILOT_MODEL=claude-opus-5.5` sets it for a session. `--effort=low|medium|high|xhigh|max` sets reasoning effort. The docs list `claude-opus-5.5` as the high-capability choice; the list you see depends on plan and policy. Verify on your machine.

### Slash commands that matter

| Command | Does |
|---|---|
| `/help`, `?` | commands and shortcuts |
| `/instructions` | which instruction files loaded; toggle them |
| `/skills list`, `/skills info NAME`, `/skills reload` | loaded skills; reload after editing one |
| `/model` | pick the model |
| `/plan [PROMPT]` | plan before coding |
| `/compact [FOCUS]` | summarize the conversation to free context |
| `/context`, `/usage` | context window use; token and credit use |
| `/clear`, `/new` | fresh conversation |
| `/resume`, `/continue` | switch to a saved session |
| `/session` | session info, checkpoints, rename |
| `/cwd PATH`, `/add-dir PATH` | change working dir; add a trusted dir |
| `/mcp`, `/mcp add`, `/mcp list` | MCP servers |
| `/agent` | pick a custom agent |
| `/permissions [default\|assisted\|allow-all\|show]` | permission mode |
| `/memory show`, `/memory off` | Copilot Memory |
| `/tasks` | background subagent and shell tasks |
| `/diff`, `/review` | review local changes |
| `/undo` | roll back to an earlier turn |
| `/share FILE` | export the transcript |
| `/feedback` | report a problem |
| `/exit` | leave |

### Keys

| Key | Does |
|---|---|
| Shift+Tab | cycle standard, plan, autopilot |
| Shift+Enter, Alt+Enter | new line. If Enter sends anyway, run `/terminal-setup` once. Verify on your machine |
| `@path` then Tab | attach a file |
| `#123` | attach a GitHub issue or PR |
| Ctrl+V | paste clipboard as an attachment; Alt+V pastes an image |
| `!cmd` | run a shell command, no model |
| Esc, Esc | interrupt the running turn |
| Ctrl+C twice | exit |
| Ctrl+R | search command history |
| Ctrl+G | edit the prompt in `$EDITOR` |
| Ctrl+X then b | background task panel |

### Non-interactive

```
copilot -p "Write a commit message in plain text for the staged changes" -s --allow-tool='shell(git:*)'
echo "Explain this file: ./pipeline.groovy" | copilot
copilot -p "Summarize what deploy.sh does in 100 words" -s --model=claude-opus-5.5
copilot -p "..." --output-format=json
copilot -p "..." --share='./report.md'
```

`-s` strips session metadata. `--no-ask-user` stops clarifying questions. Memory is off in `-p` mode unless `--enable-memory`. Piped input is ignored when `-p` is also given.

### Allow tools

| Flag | Meaning |
|---|---|
| `--allow-tool=shell` | all shell commands |
| `--allow-tool='shell(git:*)'` | all git subcommands |
| `--allow-tool='shell(git status)'` | one command |
| `--allow-tool='read, write(.github/copilot-instructions.md)'` | reads, plus writes to one file |
| `--deny-tool='shell(git push)'`, `--deny-tool=write` | block; deny always beats allow |
| `--allow-all-tools` | every tool, no prompts; deny rules still apply |
| `--allow-all`, `--yolo` | tools, paths and URLs; sandbox only; an admin can block |

Interactive approvals: 1 once, 2 for the rest of the session, 3 no and redirect. Saved approvals live in `~/.copilot/permissions-config.json`, scoped to the repo root.

### Resume

`copilot --continue` resumes the most recent session in this directory. `copilot --resume` lists saved sessions. `/resume` does the same from inside. `--continue` and `--resume` conflict. Sessions live in `~/.copilot/session-state/`.

### MCP

```
/mcp add                                          # form: name, type, command or URL, env or headers, tools; Ctrl+S saves
copilot mcp add <name> -- <command> [args]        # stdio server, written to ~/.copilot/mcp-config.json
copilot mcp add --transport http <name> <url>     # remote server
copilot mcp list ; copilot mcp remove <name>
```

`~/.copilot/mcp-config.json` uses a top-level `mcpServers` object; each server has `type` (`local`, `stdio`, `http`, `sse`), `command` and `args` or `url`, optional `env` or `headers`, and `tools` (`["*"]` for all). Project files: `.mcp.json` (local) or `.github/mcp.json` (committed); they load only in trusted folders and override the user file on a name clash. The GitHub MCP server is built in. The CLI does not read `.vscode/mcp.json`.

### `~/.copilot/` layout

| Path | Holds |
|---|---|
| `copilot-instructions.md` | personal instructions, every session |
| `instructions/*.instructions.md` | extra personal instruction files |
| `skills/<name>/SKILL.md` | personal skills |
| `agents/*.agent.md` | personal custom agents |
| `hooks/*.json` | personal hooks |
| `mcp-config.json` | personal MCP servers |
| `settings.json` | user settings (JSONC) |
| `permissions-config.json` | saved tool approvals |
| `session-state/` | sessions for `--resume` and `--continue` |
| `logs/` | per-session logs |

`COPILOT_HOME` moves the whole directory. The CLI reads the repo's `.github/copilot-instructions.md`, `AGENTS.md`, `CLAUDE.md`, `.claude/CLAUDE.md`, `GEMINI.md`, `.github/instructions/*.instructions.md`, `.github/skills/`, `.claude/skills/`, `.agents/skills/`, `.github/agents/`, `.github/hooks/`, `.mcp.json`, `.github/mcp.json`. Inside instruction files, `@relative/path` imports another file; absolute and `~/` paths are not loaded. Edits to instruction files reach new sessions only.

## VS Code cheat sheet

| Thing | Where or how |
|---|---|
| Open chat | Ctrl+Alt+I. New chat Ctrl+N. Quick chat Ctrl+Shift+Alt+L |
| Inline chat | Ctrl+I in the editor or the terminal |
| Agent mode | Agent dropdown in the chat input: Ask, Plan, Agent, custom agents. A command "Open chat in agent mode" is bound to Ctrl+Shift+I on Windows in the default keybindings. Verify on your machine |
| Harness | Session Target control: Local, Copilot, others by policy. Copilot reads the same files as the CLI |
| Model | the Language model control in the chat input |
| Every customization in one view | Command Palette, Chat: Open Customizations |
| Did my instructions load | expand References under the answer: it lists the instruction files used. Inclusion, not compliance |
| Generate repo instructions | `/init` in a Local agent session (VS Code 1.109 and later) |
| Prompt files | `.github/prompts/*.prompt.md`, run as `/name`; Local harness only |
| Custom agents | `.github/agents/*.agent.md` |
| Hooks | `.github/hooks/*.json`; Preview |
| MCP | MCP: Add Server; `.vscode/mcp.json` (Local) or `.mcp.json` and `~/.copilot/mcp-config.json` (Copilot harness) |
| Settings worth knowing | `chat.useClaudeMdFile` (on), `chat.useAgentsMdFile` (on), `chat.useAgentSkills` (on), `chat.useHooks` (on, Preview), `chat.plugins.enabled` (off) |
| CLI inside VS Code | Command Palette, Chat: New Copilot CLI Session |
| Inline completions | not affected by any instructions file |

## Habits that transfer

1. Plan before build. Shift+Tab into plan mode, or `/plan`, on anything with more than one file. Agree on the plan, then switch back.
2. Small diffs. Ask for one change, read it, commit it. The `commit` skill enforces one logical change.
3. Verify before done. Every runbook step has an expected output. Every PR says how it was tested, or says "not tested yet".
4. Ask one question. The instructions file says so; the skills repeat it where facts are commonly missing (owner, date, rollback).
5. Keep a brain. Dashboard terse, dated notes verbose, one fact once. `session-log` and `meeting-digest` write it; `weekly-status` and `daily-prep` read it.
6. Write skills from repeated work. Done twice, kept the result, know the corrections: `skill-writer`. The SKILL.md format is the same one Claude Code reads.
7. Read before changing. `@file` the thing, `!git diff` the change, then ask.
8. Never touch live. Read-only against clusters, CI servers and shared infra. `--deny-tool` makes it a rule, not a request: for example `--deny-tool='shell(kubectl apply)'`, `--deny-tool='shell(terraform apply)'`.
9. Check References (VS Code) or `/instructions` (CLI) once per new repo. It takes ten seconds and catches a silent miss.
10. Start a new session after editing an instructions file or a skill (`/new`, or `/skills reload` for a skill). The running one does not see the change.

## Honest gaps

What is different, missing, or not confirmed. Each item says whether it was verified or is unknown.

| Topic | Status | Detail |
|---|---|---|
| Personal `~/.claude/` | verified | The CLI does not read `~/.claude/CLAUDE.md` or `~/.claude/skills/`. The personal layer is `~/.copilot/`. VS Code Local reads `~/.claude/skills/` by default; the Copilot harness does not |
| Slash commands from `.claude/commands/` | verified | No equivalent in the CLI or the Copilot harness. Prompt files exist only in VS Code Local. Use a skill: skills are callable as `/<name>` |
| Precedence between instruction files | verified | None defined. All applicable files are combined. Claude Code's nested-CLAUDE.md ordering has no counterpart |
| Live reload of instructions | verified | Edits apply to new sessions only. `/new`, or exit and `copilot --continue`. Skills: `/skills reload` |
| Hooks | verified, format differs | Exist in the CLI (`~/.copilot/hooks/`, `.github/hooks/*.json`) and VS Code (Preview). JSON format differs from Claude Code's `settings.json`. The Copilot harness is documented to read `.claude/settings.json` hooks; whether a Claude Code hook runs unchanged is not verified |
| Memory | verified | Copilot Memory is managed by Copilot (citations, votes, decay) and the docs say it is not a guaranteed rule. Off in `-p` mode by default. The brain folder and the instructions file are the reliable memory |
| Permissions | verified, syntax differs | No `settings.json` allow list. Flags `--allow-tool`, `--deny-tool`, `/permissions` modes, saved approvals in `permissions-config.json`. `--allow-all` is the skip-permissions equivalent and an admin can block it |
| Inline completions | verified | Instruction files shape chat and agent mode only, not the grey autocomplete |
| Imports in instruction files | verified | `@path` must be relative and inside the repo or the config dir; absolute and `~/` paths are ignored |
| Subagents | verified, limits | Exist: built-in and custom agents, `/fleet`. A custom agent run as a subagent does not get repo instructions unless its front matter has `include-custom-instructions: true`. Concurrency depends on plan |
| Background tasks | verified exists, not exercised | `/tasks` and Ctrl+X then b exist. How they surface in practice: verify on your machine |
| Org policy | unknown | An admin can disable the CLI, MCP, hooks, memory, `--allow-all`, and specific models. Check `/model`, `/mcp`, `/skills list` on day one and write down what is off |
| Context window | partly | The docs say the latest models support 1M tokens. Which models on this plan: verify on your machine |
| WSL and Windows homes | known trap | The CLI in WSL reads the WSL `~/.copilot`. VS Code on Windows reads `%USERPROFILE%\.copilot`. Two copies unless VS Code is connected to WSL. Install on both sides or pick one |
| Model naming | partly | Docs pages disagree on names (`Claude Opus 5` vs `claude-opus-5.5`). Trust the `/model` list on the machine |

## Verified 2026-11-08 against

- Install: https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli
- Using the CLI (start, trust, `@`, `!`, Shift+Tab, `--resume`, `--continue`, `/cwd`, `/add-dir`): https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/overview
- Command reference (slash commands, options, keys): https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference
- Configuration directory (`~/.copilot/` layout, `COPILOT_HOME`): https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference
- Custom instructions for the CLI (files read, combining, `@` imports, `/instructions`): https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions
- MCP servers for the CLI: https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-mcp-servers
- Allowing and denying tools: https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/allowing-tools
- Running programmatically: https://docs.github.com/en/copilot/how-tos/copilot-cli/automate-copilot-cli/run-cli-programmatically
- Skills (locations, `/skills`, `copilot skill list`): https://docs.github.com/en/copilot/concepts/agents/about-agent-skills and https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills
- Hooks for the CLI: https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-hooks and https://docs.github.com/en/copilot/reference/hooks-reference
- Custom agents for the CLI: https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli
- Copilot Memory: https://docs.github.com/en/copilot/concepts/agents/copilot-memory
- Supported models: https://docs.github.com/en/copilot/reference/ai-models/supported-models
- Customization cheat sheet (which client reads which file): https://docs.github.com/en/copilot/reference/customization-cheat-sheet
- VS Code customization overview (Open Customizations): https://code.visualstudio.com/docs/agent-customization/overview
- VS Code custom instructions (References, inline completions): https://code.visualstudio.com/docs/agent-customization/custom-instructions and https://code.visualstudio.com/docs/agents/reference/custom-instructions-reference
- VS Code agent skills: https://code.visualstudio.com/docs/agent-customization/agent-skills
- VS Code prompt files: https://code.visualstudio.com/docs/agent-customization/prompt-files
- VS Code custom agents: https://code.visualstudio.com/docs/agent-customization/custom-agents
- VS Code hooks: https://code.visualstudio.com/docs/agent-customization/hooks
- VS Code MCP: https://code.visualstudio.com/docs/copilot/customization/mcp-servers
- VS Code harnesses and what each reads: https://code.visualstudio.com/docs/agent-customization/migrate-customizations
- VS Code settings (`chat.useClaudeMdFile` and others): https://code.visualstudio.com/docs/copilot/reference/copilot-settings
- VS Code shortcuts and slash commands (`/init`): https://code.visualstudio.com/docs/agents/reference/ai-features-cheat-sheet and https://code.visualstudio.com/docs/agents/run/chat-view
- VS Code default keybindings (Ctrl+Shift+I agent mode command): https://code.visualstudio.com/docs/reference/default-keybindings
