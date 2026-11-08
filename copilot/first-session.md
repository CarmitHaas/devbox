# First Copilot CLI session: a 15-minute script

For the first session on a new machine, in a WSL terminal. Each step says what to type and what success looks like. Commands and paths verified against docs.github.com on 2026-11-08. Where the docs leave room, the step says "verify on your machine".

Before you start: `install.sh` from this folder has run, and you have a GitHub account with a Copilot seat from the organization.

## 0. Install (2 min)

Type one of:

```
curl -fsSL https://gh.io/copilot-install | bash
```
```
npm install -g @github/copilot        # needs Node.js 22 or later
```

Success: `copilot --version` prints a version. If the org has disabled Copilot CLI, the login step fails with a policy message; stop and ask the team lead.

## 1. Scratch folders (1 min)

```
mkdir -p ~/scratch/repo ~/scratch/brain/sessions
cd ~/scratch/repo && git init -q && printf 'hello\n' > README.md
```

Success: a repo with one untracked file, and an empty brain folder. Nothing here is real work.

## 2. Start and trust (1 min)

```
cd ~/scratch/repo
copilot
```

The trust prompt offers: 1 this session, 2 remember this folder, 3 no. Pick 2 for scratch folders. For client repos, pick 1 until you know the folder.

Success: the Copilot prompt appears. `?` on an empty prompt opens quick help.

## 3. Log in (2 min)

```
/login
```

Follow the browser or device-code flow. Success: `/user` shows your account.

## 4. Pick the model (1 min)

```
/model
```

Pick `claude-opus-5.5`. The list depends on the plan and the org policy: verify on your machine. If Opus is not in the list, note it as a question for the team and continue with the default.

To make it the default for new sessions, in `~/.bashrc`: `export COPILOT_MODEL=claude-opus-5.5`, or start with `copilot --model=claude-opus-5.5`.

Success: the status line shows the model name.

## 5. Confirm the instructions loaded (1 min)

```
/instructions
```

Success: `~/.copilot/copilot-instructions.md` is listed and enabled. Second check, ask in plain words:

```
What are my commit rules?
```

Success: the answer says under 60 characters, imperative, no attribution trailers. If it does not, the file is not loaded: check the path with `ls ~/.copilot/` and start a new session with `/new`.

## 6. Confirm the skills loaded (1 min)

```
/skills list
```

Success: twelve skills, `commit` through `skill-writer`, source `~/.copilot/skills`. If one is missing, `/skills info <name>`, then check the three silent failures: folder under `~/.copilot/skills/`, file named `SKILL.md`, `name:` equals the folder. After fixing, `/skills reload`.

## 7. Trigger `commit` on the scratch repo (2 min)

```
Commit this
```

Success: it runs `git status` and `git diff`, stages `README.md`, proposes one subject under 60 characters, and waits for your approval. After approval it commits with no trailer (`!git log -1 --format=%B` shows one line) and reports that push failed because no remote exists. That honest report is the point.

## 8. Trigger `session-log` on the scratch brain (2 min)

```
/add-dir ~/scratch/brain
Log the session into the brain at ~/scratch/brain. Today I installed Copilot CLI, logged in, picked Opus, and tested the commit skill.
```

Success: `~/scratch/brain/DASHBOARD.md` with four zones (Now, Next, Recently done, Open questions) and `~/scratch/brain/sessions/<today>.md` with a timed section. Open both: dashboard terse, note verbose. If it wrote a third file, say so; the skill forbids it.

## 9. Learn three keys (1 min)

| Key | Does |
|---|---|
| Shift+Enter (or Alt+Enter) | new line without sending. If it sends, run `/terminal-setup` once |
| `@path` then Tab | attach a file |
| Ctrl+V | paste clipboard as an attachment (long logs, images) |
| Shift+Tab | cycle standard, plan, autopilot. Plan first on anything non-trivial |
| `!cmd` | run a shell command without the model |

## 10. Exit and resume (1 min)

```
/exit
copilot --continue
```

Success: the same conversation comes back. `/resume` picks from a list of saved sessions.

## Later: the team's MCP server

When the team shares a server, inside a session:

```
/mcp add
```

Fill name, type (STDIO for a local command, HTTP for a URL), command or URL, Tab between fields, Ctrl+S to save. Or from the terminal: `copilot mcp add <name> -- <command> [args]`. Check with `/mcp list`. The GitHub MCP server is built in and needs no setup. A repo can ship its own in `.github/mcp.json`; it loads only in trusted folders.

Secrets for MCP go in the env field or headers, never in a committed file.
