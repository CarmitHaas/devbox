# Microsoft Teams and Outlook cheat sheet

Generic notes for a corporate Microsoft 365 tenant on Windows. Admin policy changes many details; items marked "if enabled" depend on it.

## Teams: mental model

| Thing | What it is |
|---|---|
| Team | A group of people plus a SharePoint site behind it. Owners and members. |
| Channel | A topic inside a team. Standard = everyone in the team sees it. Private = subset, own SharePoint folder. Shared = people outside the team (if enabled). |
| Chat | 1:1 or group messages outside any team. Files land in your OneDrive. |
| Post vs reply | A post starts a thread in a channel. Reply inside the thread. A new post for an answer breaks the conversation for everyone. |
| Meeting chat | Lives with the meeting, not the channel, unless it is a channel meeting. Search finds it under the meeting title. |
| Presence | Green, yellow, red dot. Follows your Outlook calendar (In a meeting) and keyboard activity. |

## Teams: etiquette and daily moves

1. @mention a person to get an answer. @channel pings everyone in the channel; @team pings the whole team. Use those twice a month, not twice a day.
2. React with a thumbs up or check mark instead of writing "ok". A reaction is an acknowledgment.
3. Save a message: hover > ... > Save. Find it later under your profile > Saved. Pin a message in a chat so it stays at the top for all.
4. Status: profile picture > status. Do not disturb hides all notifications except priority contacts (Settings > Privacy). Quiet hours and quiet days are in the mobile app settings.
5. Scheduling: Teams calendar and Outlook calendar are the same calendar. New meeting in either. In Outlook, the Teams meeting toggle adds the join link.
6. Share screen: in a meeting, Share (Ctrl+Shift+E) > pick a window or screen. Window share is safer than full screen. Give control: toolbar at the top of the shared screen > Give control > name. Take it back with the same menu.
7. Record: More > Record and transcribe. Recordings go to the organizer's OneDrive (Recordings folder) for normal meetings, and to the channel's SharePoint folder for channel meetings. Classic Stream is gone. Recording may be disabled by policy (if enabled).
8. Search: Ctrl+E, then type. Filters for messages, people, files. Prefix `/` in the search box for commands (`/dnd`, `/available`, `/goto`).
9. Files tab in a channel is the SharePoint folder. Edit in place; do not download, edit and re-upload.
10. Create a Jira work item from a message: hover > ... > More options > Create work item in Jira (if the Jira Cloud app is installed). It links the thread to the issue.
11. Loop components: in the compose box, Loop icon > checklist, table, task list or paragraph. Everyone edits live and the same component can be pasted into another chat or Outlook. Stored in your OneDrive (if enabled).

## Teams: keyboard shortcuts (Windows desktop app)

Press Ctrl+. (period) or Alt+/ for the live list. Web app differs where noted.

| Key | Action |
|---|---|
| Ctrl+E | Go to search (web: Ctrl+Alt+E) |
| Ctrl+. | Show shortcuts |
| Ctrl+G | Go to a chat or channel by name |
| Ctrl+N | New chat (web: Alt+N) |
| Ctrl+, | Settings |
| Ctrl+1 to Ctrl+9 | Open the 1st to 9th app on the left bar. Default order is Activity, Chat, Teams, Calendar, Calls, so Ctrl+2 is Chat and Ctrl+4 is Calendar. Your order may differ |
| Ctrl+R | Jump to the compose box |
| Ctrl+Shift+X | Expand compose box (formatting toolbar) |
| Ctrl+Enter | Send from the expanded compose box |
| Shift+Enter | New line without sending |
| Alt+Shift+R | Reply to the last message in the thread (web: Alt+R) |
| Ctrl+Shift+I | Mark message as important |
| Alt+Shift+O | Attach file |
| Ctrl+Shift+M | Mute / unmute in a meeting |
| Ctrl+Shift+O | Camera on / off (not "open") |
| Ctrl+Shift+E | Share content tray |
| Ctrl+Shift+Space | Go to the sharing toolbar (to stop sharing) |
| Ctrl+Shift+K | Raise / lower hand |
| Ctrl+Shift+H | Leave the call |
| Ctrl+Shift+A / S / D | Accept video / accept audio / decline an incoming call |
| Ctrl+Space (hold) | Temporary unmute (if enabled under Settings > Privacy) |

Ctrl+/ is not the shortcuts list in Teams; it is Ctrl+. (period).

## Teams: formatting a message

1. Ctrl+Shift+X opens the full editor: headings, bold, bullets, numbered lists, quote, insert table, code.
2. Markdown in the compose box (if markdown is on in Settings): `**bold**`, `*italic*`, `` `code` ``, three backticks then Enter for a code block, `-` for bullets, `1.` for numbers, `>` quote.
3. Paste a log or YAML inside a code block. Without it, Teams reflows whitespace and eats indentation.
4. Tables: expanded editor > Insert table, or paste a Loop table component.
5. Mark as important (Ctrl+Shift+I) or Urgent (notifies every 2 minutes for 20 minutes; use only for incidents).

## Outlook: inbox zero in 15 minutes

Two clients exist: classic Outlook and new Outlook. Shortcuts differ; both are listed below.

1. Focused inbox: View > Focused / Other. Train it by right-click > Move to Focused / Other. Or turn it off and rely on rules.
2. Rules: Settings > Mail > Rules (new) or Home > Rules > Manage Rules (classic). Standard set: Jira notifications to a Jira folder, CI/CD mail to a Builds folder, calendar responses to Deleted Items, anything where you are only in CC to a CC folder.
3. Categories: color tags across mail and calendar. Right-click > Categorize. Two or three categories are enough (Action, Waiting, Reference).
4. Quick steps (classic, and new Outlook if enabled): one click to "move to Archive and mark read" or "reply with template".
5. Folders vs search: keep 5 folders at most. Search is fast; folder sorting is where time goes.
6. Triage loop: open mail, Ctrl+Q marks read, Ctrl+Shift+V moves to a folder (classic), Backspace archives (new), Delete deletes. Reply only if it takes under 2 minutes; otherwise flag (Insert) and come back.
7. Schedule sends and snooze (new Outlook) keep the inbox empty without losing the thread.

## Outlook: calendar

1. Settings > Calendar > Work hours and location. Set your time zone. Add a second time zone if the team is split.
2. New meeting: Ctrl+Shift+Q (classic) or Ctrl+N inside Calendar (new). Toggle Teams meeting so the link is included.
3. Scheduling assistant: shows free/busy of invitees and rooms. Use it before proposing a slot.
4. Recurring: Recurrence button. Set an end date; infinite series are hard to clean up later.
5. Propose new time: on an invite, Tentative > Propose new time. Does not decline.
6. Out of office: Settings > Accounts > Automatic replies (new) or File > Automatic Replies (classic). Add the block to the calendar too so the scheduling assistant shows you as away.
7. Share your calendar without a delegate: Calendar > Share > person > permission "Can view when I'm busy" or "Can view titles and locations". Delegates can act for you; sharing only shows.
8. Signature: Settings > Accounts > Signatures (new) or File > Options > Mail > Signatures (classic). Name, role, company, mobile. No quotes or images.

## Outlook: keyboard shortcuts (Windows)

| Action | Classic Outlook | New Outlook |
|---|---|---|
| New message | Ctrl+Shift+M (Ctrl+N inside Mail) | Ctrl+N |
| Reply | Ctrl+R | Ctrl+R |
| Reply all | Ctrl+Shift+R | Ctrl+Shift+R |
| Forward | Ctrl+F | Ctrl+F |
| Send | Alt+S or Ctrl+Enter | Ctrl+Enter |
| Search | Ctrl+E or F3 | Not in the official table; click the search box (Alt+Q works in the web version) |
| Mark read / unread | Ctrl+Q / Ctrl+U | Ctrl+Q / Ctrl+U |
| Move to folder | Ctrl+Shift+V | Not listed; use the Move button or drag |
| Flag | Insert (quick flag) or Ctrl+Shift+G | Insert |
| New task | Ctrl+Shift+K | Not listed; use To Do |
| New appointment | Ctrl+Shift+A (any view) | Ctrl+N in Calendar |
| Mail / Calendar / People | Ctrl+1 / Ctrl+2 / Ctrl+4 | Ctrl+1 / Ctrl+2 / Ctrl+4 |
| Tasks | Ctrl+8 (Ctrl+3 opens Copilot) | No shortcut |
| Go to Inbox | Ctrl+Shift+I | Not listed |
| Delete | Delete | Delete |

New Outlook lets you pick a shortcut set (Outlook, Gmail, Yahoo) under Settings > General > Accessibility.

## The corporate mail reality

1. Assume outbound mail to personal addresses is logged, and often blocked for attachments or flagged content (DLP). Do not forward work mail or files home.
2. Attachments to external domains may be stripped or quarantined. Share a OneDrive or SharePoint link with an expiry instead.
3. Sensitivity labels (Confidential, Internal) on mail and documents are enforced by policy. Pick the right one; a wrong label can block the recipient.
4. External recipients get a warning banner. Read it before sending to a vendor.
5. Mailbox retention and litigation hold mean "deleted" is not deleted. Write accordingly.
