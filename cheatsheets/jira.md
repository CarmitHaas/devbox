# Jira Cloud cheat sheet

Generic notes for any Jira Cloud site. Keys, names and URLs are placeholders (`PROJ-123`).
Atlassian renamed "issues" to "work items" in the UI during 2025. Same thing; both words appear here.

## Mental model in 10 lines

1. Site: `https://<org>.atlassian.net`. One Atlassian account, many products (Jira, Confluence) on the same site.
2. Project: a container with a key (`PROJ`). Every issue is `PROJ-<number>`. Company-managed projects share site-wide schemes; team-managed projects own their own config.
3. Issue types: Epic (large goal, weeks to months) > Story (user-visible slice) / Task (work with no user story) / Bug (defect) > Sub-task (child of a story, task or bug).
4. Board: a view over a filter. Scrum board = sprints + backlog + burndown. Kanban board = continuous flow + WIP limits, backlog optional.
5. Sprint: a time box (1 to 4 weeks) on a scrum board. Backlog: everything not in a sprint, ranked by drag order.
6. Filter: a saved JQL query. Boards, dashboards, subscriptions and the Teams app all sit on filters.
7. Dashboard: a page of gadgets (filter results, pie charts, sprint health). Personal or shared.
8. Workflow: statuses (To Do, In Progress, In Review, Done) plus transitions. Resolution is a separate field set when the item closes (Done, Won't Do, Duplicate). Some teams add custom statuses such as Accepted or Obsolete; ask what each means before you use it.
9. Classification: Components (area of the system, can have a default assignee), Labels (free tags, anyone can invent one), Fix Version (the release it ships in), Priority.
10. People and size: Assignee (who does it) vs Reporter (who filed it). Story points estimate effort. Watchers get notified on every change.

## Daily moves

| I want to | Do this |
|---|---|
| Find my work | Top bar: Your work (assigned, recent, starred). Or the filter "My open work" below. |
| Move a card | Drag on the board, or open the item and use the status dropdown (that is the transition). |
| Log a comment | Open the item, press `m`, type, Ctrl+Enter to submit. Use `@name` to notify someone. |
| Link issues | Item > Link work item (or the link icon). Pick the type: blocks, is blocked by, relates to, duplicates. |
| Create from a Teams thread | In Teams: message > More options > Create work item in Jira (if the Jira Cloud app is installed). |
| @mention | Type `@` then the name in any description or comment. The person gets a notification. |
| Watch | Open the item, eye icon in the top right. You get every change by mail or Teams. |
| Flag | Item > ... > Add flag. The card turns yellow. Use it for "blocked, needs help". |
| Star | Star a board, filter or dashboard so it shows under Your work > Starred. |
| Log work or set estimate | Time tracking field on the item (if enabled). Story points live in their own field. |

## Keyboard shortcuts

Press `?` (Shift+/) anywhere in Jira to see the live list for your site. The first block is on the current Atlassian Cloud docs. The second block is widely used but no longer on the official Cloud page; confirm it in the `?` dialog.

| Key | Action | Status |
|---|---|---|
| `?` | Shortcuts dialog | Verified |
| `c` | Create work item | Verified |
| `j` / `k` | Move down / up in a list or board | Verified |
| `n` / `p` | Next / previous column on a board | Verified |
| `o` or Enter | Open the selected item | Verified |
| `a` | Assign to someone | Verified |
| `i` | Assign to me | Verified |
| `m` | Add a comment | Verified |
| `/` | Focus search | Confirm in `?` |
| `.` | Actions dialog on an item (transition, edit, assign) | Confirm in `?` |
| `e` | Edit | Confirm in `?` |
| `l` | Edit labels | Confirm in `?` |
| `s` | Share | Confirm in `?` |
| `g` then `d` | Go to dashboards | Confirm in `?` |
| `g` then `p` | Go to projects | Confirm in `?` |
| `g` then `i` | Go to issue search | Confirm in `?` |
| `g` then `a` | Go to boards | Confirm in `?` |

Sequences like `g` then `d` are pressed one key after the other, not together. Shortcuts do nothing while a text field has focus.

## JQL crash course

Shape: `field operator value AND field operator value ORDER BY field DESC`. Keywords are case-insensitive. Quote values with spaces: `status = "In Review"`. Dates are `yyyy-MM-dd` or relative (`-3d`, `-2w`). Switch the search page to JQL mode to type it.

| Operator | Meaning | Example |
|---|---|---|
| `=` `!=` | Equals, not equals | `assignee = currentUser()` |
| `IN` `NOT IN` | List membership | `status IN ("To Do", "In Progress")` |
| `~` `!~` | Text contains | `summary ~ "timeout"` |
| `>` `>=` `<` `<=` | Compare dates or numbers | `created >= -7d` |
| `IS EMPTY` / `IS NOT EMPTY` | Field unset | `assignee IS EMPTY` |
| `WAS` `WAS IN` `WAS NOT` | Historical value | `status WAS "In Review"` |
| `CHANGED` | Field changed, with `FROM`, `TO`, `BY`, `AFTER`, `BEFORE`, `DURING` | `status CHANGED TO Done AFTER startOfWeek()` |
| `currentUser()` | Me | `reporter = currentUser()` |
| `startOfDay("-1d")` | Yesterday 00:00. Also `startOfWeek()`, `endOfDay()`, `now()` | `updated >= startOfDay("-1d")` |
| `openSprints()` | Active sprints. Also `closedSprints()`, `futureSprints()` | `sprint IN openSprints()` |
| `membersOf("group")` | Users in a group | `assignee IN membersOf("team-devops")` |
| `watchedIssues()` | Items I watch | `issue IN watchedIssues()` |

Official docs quote the offset argument (`startOfDay("-1d")`). Unquoted usually works too.

Fifteen ready-made queries:

1. My open work: `assignee = currentUser() AND resolution = Unresolved ORDER BY updated DESC`
2. My work updated today: `assignee = currentUser() AND updated >= startOfDay()`
3. Unassigned in the current sprint: `project = PROJ AND sprint IN openSprints() AND assignee IS EMPTY`
4. Blockers: `project = PROJ AND resolution = Unresolved AND (Flagged IS NOT EMPTY OR priority = Highest OR labels = blocked)`
5. Bugs created this week by a bot user: `project = PROJ AND issuetype = Bug AND reporter = "bot-user@example.com" AND created >= startOfWeek()`
6. In progress, no update for 3 days: `project = PROJ AND status IN ("In Progress", "In Review") AND updated <= startOfDay("-3d")`
7. Items I reported: `reporter = currentUser() AND resolution = Unresolved ORDER BY created DESC`
8. Items in review: `project = PROJ AND status = "In Review" ORDER BY updated ASC`
9. Sprint scope changes (added after start): `project = PROJ AND sprint IN openSprints() AND Sprint CHANGED AFTER startOfWeek()`. If your site rejects it, use `created >= <sprint start date>`. The Sprint Report also marks added items with `*`.
10. Children of an epic: `parent = PROJ-100` (older sites: `"Epic Link" = PROJ-100`)
11. By component: `project = PROJ AND component = "Pipelines" AND resolution = Unresolved`
12. By label: `labels IN (devops, infra) AND resolution = Unresolved`
13. Done this week by me: `assignee = currentUser() AND status CHANGED TO Done AFTER startOfWeek()`
14. Bounced back from review: `status WAS "In Review" AND status = "In Progress"`
15. My team's sprint: `assignee IN membersOf("team-devops") AND sprint IN openSprints() ORDER BY status, priority DESC`

Save and share:

1. Run the query > Save as > name it. Filters you save are private until you share them (Details > Edit permissions).
2. Star the filter so it appears under Your work > Starred.
3. Email subscription: Filters > your filter > Details > New subscription > pick the schedule and group. Jira mails the result set.
4. Share a board: copy the URL (`.../jira/software/c/projects/PROJ/boards/<id>`). Quick filters are not in the URL. Share a search with `.../issues/?jql=<encoded>` or `?filter=<filterId>`.

## Writing a good story and a good bug

Story, in this order: Summary (verb first, under 10 words) > Epic/parent > Description: context (2 lines), what changes, what does not change > Acceptance criteria > Links (design, runbook, PR) > Labels, Component, Story points.

Acceptance criteria format, one per line, testable:

```
Given <state>, when <action>, then <observable result>.
Given a merged PR on main, when the pipeline runs, then the image is pushed with the git SHA tag.
```

Bug, in this order: Summary (what breaks, where) > Environment (version, cluster, branch) > Steps to reproduce (numbered) > Expected > Actual (paste the exact error, in a code block) > Impact and frequency > Workaround if any > Logs or screenshots as attachments. Set Priority honestly; let the team set Severity if they have that field.

## Taming notifications

1. Profile picture > Personal settings > Email notifications: turn off "my own changes" and pick a digest if offered.
2. Unwatch items you only touched once (eye icon). Watching is the main source of noise.
3. Replace mail with one daily filter subscription (query 1 or 6 above) sent at 08:00.
4. Teams Jira Cloud app (if installed): personal notifications land in the Jira bot chat; mute the mail equivalents.
5. Mail rule in Outlook: anything from `jira@<org>.atlassian.net` that is not an @mention goes to a Jira folder.

## Common traps

| Trap | What happens | Avoid |
|---|---|---|
| Editing the wrong sprint | You add items to a future sprint, or drag into a closed one | Check the sprint name in the backlog header before dragging |
| Resolution stays Unresolved | Item is in Done but still shows in "open" filters | Workflow must set Resolution on the Done transition; if yours does not, tell the project admin, do not edit by hand |
| Board filter hides your item | You create the item but it is not on the board | Board > ... > Configure > Filter query. Usually a missing component, label or wrong project |
| Done vs Accepted | Dev says Done, product says not Accepted | Learn which status is the team's real end state and which column maps to it |
| Sub-task in a sprint | Sub-tasks follow the parent; you cannot plan them separately | Plan at story level, break down with sub-tasks |
| Comment visibility | Comments can be restricted to a group | Check the lock icon before writing to customers or vendors |
| Bulk edit | Bulk change sends a notification per item | Untick "send notification" in the bulk change wizard |
