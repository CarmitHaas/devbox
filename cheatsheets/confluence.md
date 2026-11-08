# Confluence Cloud cheat sheet

Generic notes for Confluence Cloud (Atlassian Cloud). Names and URLs are placeholders.

## Mental model

| Thing | What it is |
|---|---|
| Site | `https://<org>.atlassian.net/wiki`. Shares login and users with Jira on the same site. |
| Space | Top-level container (a team, a product, a project). Has its own permissions, home page and page tree. |
| Page tree | Pages nest: parent > child. The tree is the sidebar. Moving a page moves its children. |
| Personal space | Your own space (`~your.name`). Drafts, notes, scratch pages. Visible to others unless restricted. |
| Live doc vs page | Live docs save continuously with no publish step. Pages have a draft and a Publish button. Both show in the same tree. |
| Templates | Create > pick a template (meeting notes, decision, retrospective, runbook). Spaces can have their own. |
| Page history | ... > Page history. Every publish is a version. You can compare and restore. |
| Restrictions | Lock icon. View or edit limits per page. Children inherit view restrictions. |
| Watch | Bell/eye on the page. Mail or Teams on every edit or comment. Also possible per space. |
| Labels | Tags on a page. Used by macros (Content by label, Page Properties Report) and for search. |
| Macros | Dynamic blocks you insert with `/`. The ones below cover 90 percent of real use. |
| Jira macro | `/jira` pastes an issue key, URL or JQL. Renders a live table of issues. |
| Status lozenge | `/status`. Colored chip: GREEN, IN PROGRESS, BLOCKED. |
| Expand | `/expand`. Collapsible section for long logs or optional detail. |
| Code block | `/code` or type ``` then Enter. Choose the language for highlighting. |
| Table of contents | `/table of contents`. Built from headings. Put it right under the title. |
| Page properties + report | `/page properties` holds a 2-column key/value table on each page. `/page properties report` on a parent collects them into one board, filtered by label. |
| Excerpt / Excerpt include | `/excerpt` marks a block; `/excerpt include` shows it on another page. One source, many views. |
| Include page | `/include page` embeds a whole page. |

## Editor

Slash commands that matter: `/heading`, `/table`, `/code`, `/expand`, `/status`, `/info` `/note` `/warning` `/success` (panels), `/jira`, `/table of contents`, `/page properties`, `/page properties report`, `/excerpt`, `/date`, `/action item`, `/decision`, `/mention`, `/image`, `/link`, `/layout` (columns), `/divider`, `/drawio` (only if the draw.io app is installed).

Markdown while typing, at the start of a line followed by a space: `#` to `######` headings, `*` or `-` bullet, `1.` numbered, `>` quote, ``` code block, `---` divider, `[]` action item, `<>` decision. Inline: `**bold**`, `*italic*`, `~~strike~~`, `` `code` ``, `[title](url)`. Pasting a whole markdown document usually converts headings, lists, bold and links. If it lands as one code block, paste as plain text and fix headings by hand.

Tables: Tab moves to the next cell (and adds a row at the end), Shift+Tab goes back. Hover a column edge to drag-resize. Click the cell menu for row/column options or press Shift+F10 in a cell.

Keyboard shortcuts (Windows, from the official list; press Ctrl+? in Confluence to see your site's list):

| Key | Action |
|---|---|
| `e` | Edit the current page |
| Ctrl+Enter | Publish (Ctrl+Shift+Enter publishes with a version note). There is no Ctrl+S; drafts save on their own |
| `/` | Quick insert menu in the editor |
| Ctrl+K | Insert or edit a link |
| Ctrl+[ | Toggle the sidebar |
| Ctrl+Alt+W | Watch the page |
| Ctrl+Alt+C | Comment |
| Ctrl+Alt+S | Share |
| Ctrl+Alt+A | Edit labels |
| Ctrl+Alt+F | Star (favorite) |
| Win+Alt+C | Create page (was plain `c` in older versions) |
| Ctrl+Shift+D | Create live doc (in view mode); insert markup (in the editor) |
| Alt+Shift+Z | Quick search (older sites: `/` in view mode) |
| Ctrl+Alt+1 to Ctrl+Alt+6 | Heading 1 to 6 |
| Ctrl+Shift+7 / 8 / 9 | Numbered list / bullet list / quote |
| Ctrl+Shift+M | Code block (or inline code with text selected) |
| Ctrl+Shift+I | Insert table (in the editor) |
| Ctrl+Alt+Up / Down / Left / Right | Add table row above / below, column before / after |
| Ctrl+F | Find and replace in the editor |

## How to

| Task | Steps |
|---|---|
| Move a page | ... > Move > pick space and new parent. Or drag in the sidebar tree. Links keep working because they use the page id. |
| Copy a page tree | On the parent: ... > Copy > tick "Include child pages". Titles get a prefix you can set. Attachments are copied; restrictions are not. |
| Export a page | ... > Export > PDF or Word. Space settings > Export for a whole space (PDF, HTML, XML). |
| Import from Word | Space settings > Content tools > Import (if available), or ... > Import Word document on a page. Headings can split into child pages. |
| Convert markdown | Paste into the editor (converts most syntax). Legacy "Markdown" macro only exists in spaces still on the old editor. Marketplace "Markdown" apps if installed. For automation use the REST API with `representation: storage` (XHTML) or `wiki` markup; the new editor stores ADF (`atlas_doc_format`), which you rarely need to write by hand. |
| Restrict a page | Lock icon > "Only specific people can view or edit". Remember children inherit view restrictions. |
| Set the team landing page | Space settings > Space details > Home page (or ... > Set as space home page on the page). Pin key pages with the sidebar shortcuts. |
| Status board from pages | Give each child page a `/page properties` table (Owner, Status, Due) and a label. Parent page: `/page properties report` with that label. |
| Embed a draw.io diagram | `/drawio` > draw > save. Needs the "draw.io Diagrams" app installed (if enabled). Otherwise attach a PNG exported from draw.io desktop and keep the `.drawio` as an attachment. |
| Jira issues with JQL | `/jira` > Search > paste JQL such as `project = PROJ AND sprint IN openSprints()` > pick columns > Insert. Refreshes on view. |
| Find the page id | It is in the URL: `/wiki/spaces/SPACE/pages/123456789/Title`. Also under ... > Page information. |

## Runbook page that people actually use

1. Title: `Runbook: <system> <action>` so search finds it.
2. First block: `/page properties` with Owner, Last verified (date), Severity, On-call link.
3. Second block: `/status` chip and a one-line "When to use this".
4. Preconditions: access needed, tools, where to run from.
5. Steps: numbered. One command per `/code` block. Expected output in an `/expand`.
6. Rollback: its own heading, same format as Steps.
7. Verification: how you know it worked.
8. Known failures: table of symptom > cause > fix.
9. Links: Jira epic, dashboards, repo, previous incidents.
10. Keep it under one screen per section. Long logs go in `/expand`. Update "Last verified" every time you run it.

## REST API in 10 lines

1. Base URL: `https://<org>.atlassian.net/wiki/api/v2`. The v1 API still works at `/wiki/rest/api`.
2. Auth: Basic auth with your email and an API token from `https://id.atlassian.com/manage-profile/security/api-tokens`. No passwords.
3. Export once per shell, never commit: `export CONF_SITE=https://<org>.atlassian.net CONF_USER=you@example.com CONF_TOKEN=<token>`.
4. Get a page with its storage body: `curl -s -u "$CONF_USER:$CONF_TOKEN" "$CONF_SITE/wiki/api/v2/pages/$PAGE_ID?body-format=storage"`.
5. Body formats you can ask for: `storage`, `atlas_doc_format`, `view`, `export_view`. Write with `storage`, `atlas_doc_format` or `wiki`.
6. Read `version.number` from the GET; the PUT must send that number plus one or it fails with 409.
7. Update: `curl -s -u "$CONF_USER:$CONF_TOKEN" -X PUT -H 'Content-Type: application/json' "$CONF_SITE/wiki/api/v2/pages/$PAGE_ID" -d "{\"id\":\"$PAGE_ID\",\"status\":\"current\",\"title\":\"$TITLE\",\"body\":{\"representation\":\"storage\",\"value\":\"<p>hello</p>\"},\"version\":{\"number\":$NEXT,\"message\":\"automated update\"}}"`.
8. Storage format is XHTML. Headings, lists, tables and links from `pandoc -t html` work. Code blocks need `<ac:structured-macro ac:name="code">`, so keep macros out of generated pages or use `wiki` markup (`{code}`).
9. Rate limits: HTTP 429 with a `Retry-After` header. Back off and retry; keep scripts under a few requests per second.
10. Use `jq` on the output: `... | jq -r '.version.number, .body.storage.value'`. Required PUT fields are `id`, `status`, `title`, `body`, `version`.
