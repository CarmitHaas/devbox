---
name: explainer-page
description: Build a self-contained single HTML page (a guide, runbook, explainer, cheat sheet, or handover doc) from notes or a markdown file, design tokens with light and dark mode, system fonts, a sticky table of contents, collapsible sections, copyable code blocks, callouts, a sources section, RTL-ready Hebrew blocks, no external requests. Use when asked to make a page, turn this markdown into something readable, or write a guide people will open in a browser. Not for slide decks, diagrams, or a page that needs a server.
---

# Explainer page

## What this skill does
Turns content the user already has (a markdown file, a spec, a chat, an audit) into one `.html` file that opens from disk, from email, or from a wiki attachment with no network access. The look comes from `template.html` next to this file. The method is: outline for the reader, write the sections in markdown, run `build.py`, look once, ship. Output is the page plus a line on what was assumed.

## When to use it
- "Make a page out of this markdown"
- "Write a guide to <system> that the team can open in a browser"
- "Turn this handover note into something I can send"

Do not use it for slides; use `deck`. Do not use it for an architecture picture; use `architecture-diagram` and embed the exported SVG inline.

## How to do it
1. Read: the source in full. Note the reader (new teammate, on-call, manager), what they must do after reading, and which parts are reference (tables, commands) versus narrative. Note any Hebrew.
2. Decide the outline for the reader, not in the source's order: what changes their next action goes first, reference goes last, a `Sources` section closes the page. Six to ten sections. Each section title is a sentence or a noun phrase the reader would search for. Decide whether a diagram earns its place: only when the mechanism has parts that interact (a flow with branches, a boundary that matters). A list of three steps is a list, not a diagram. If yes, export SVG with `architecture-diagram` and paste the `<svg>` inline; no `<img src="http...">`.
3. Check the content rules: no invented facts; numbers and commands verbatim from the source; secrets as a path or a vault key; names only if the page stays inside the team, otherwise roles. Callouts carry one sentence each and are spent on things the reader must act on: `Note` (context), `Warning` (something breaks), `Decision` (what was chosen and why). A Hebrew paragraph or list is a block with `dir="rtl" lang="he"` on that block, never on the page; code inside it stays LTR (the template forces it).
4. Ask one question when the reader or the footer line is unknown. The footer line is set by the user (for example "Internal, do not forward"); leave it empty rather than inventing a classification.
5. Write the content as markdown: `#` once for the title, `##` per section (each becomes a collapsible section and a TOC entry), fenced code blocks (they get a copy button), tables, and callouts as a blockquote whose first words are `**Note:**`, `**Warning:**`, or `**Decision:**`. A Hebrew block: wrap it in `<div dir="rtl" lang="he" markdown="1">` ... `</div>` inside the markdown (the `markdown="1"` lets lists inside it convert). Then build, from a scratch folder, running the interpreter in isolated mode because the source file is untrusted input:
   ```
   python3 -m venv .venv && .venv/bin/pip install markdown
   .venv/bin/python -I build.py source.md out.html --title "Page name" --footer "Internal, do not forward"
   ```
   The venv matters: `-I` ignores user-site packages, so a `pip install --user markdown` is not found. `build.py` and `template.html` live next to this SKILL.md; the script reads the template, fills the title, TOC, sections and footer, and writes one file. Hand-writing the HTML from the template is fine too for a short page; keep every token on `:root` and both dark blocks.
6. Look once: open `out.html` in the browser (from WSL: `explorer.exe out.html`). Check light and dark (add `data-theme="dark"` on `<html>` or use the toggle), the TOC links, one copy button, the narrowest width (no horizontal scroll, 16 px side gutter), and that a Hebrew block reads right to left with its code left to right. One pass of fixes in the markdown, rebuild, stop.
7. Verify the page makes no external request: `grep -nE 'https?://' out.html` should return only links the reader clicks, never a `src=` or `href=` on a `<link>` or `<script>`.
8. Report in the format below.

### Template contract (if editing by hand)
- Tokens: every color on `:root`; the same names redefined under `@media (prefers-color-scheme: dark)` guarded by `:root:not([data-theme="light"])`, and again under `:root[data-theme="dark"]`. A color defined only in a dark block is a bug.
- `body` sets `background: var(--ground)` explicitly. System font stack, no `@font-face`, no `<link>`.
- Logical properties only (`padding-inline`, `border-inline-start`, `text-align: start`) so RTL blocks work. `pre, code { direction: ltr }`.
- Side gutter `clamp(16px, 4vw, 32px)`; at phone width it is 16 px and nothing scrolls sideways.
- Every `<section>` is `<details open>` with the `<h2>` in the `<summary>`; the TOC is `<nav id="toc">` and is `position: sticky` beside the content on wide screens, a plain list on narrow ones.
- The only script is inline and does three things: theme toggle, copy buttons, open the section a link points at. No analytics, no fetch.
- Non-ASCII text (Hebrew) is fine as UTF-8 because `<meta charset="utf-8">` is declared; keep that line first in `<head>`.

## What not to do
- Do not load fonts, scripts, icons, or images from a CDN; the page must open offline and behind a proxy.
- Do not put the page's direction to RTL for a Hebrew paragraph; the block gets `dir="rtl"`.
- Do not mirror a chart axis for RTL; measurement axes read left to right in every language. Process flows do mirror.
- Do not hardcode a color inside a dark block that was not declared on `:root`.
- Do not invent a footer classification, a logo, a company name, or a signature block; the user sets the footer line, the rest stays out.
- Do not make every block a callout; three callouts per page is already many.
- Do not add animation, hero images, or a search box; match the weight of the source.
- Do not ship Hebrew you wrote yourself without saying it is unreviewed and naming the terms you were unsure of.

## Output format
```
Page: <path>/out.html  (<N> sections, <K> code blocks, <C> callouts, <S> sources)
Built from: <source.md | written by hand from <input>>
Reader: <who>, first action after reading: <what>
Footer line: "<text>" | none (asked)
Checked: light <ok>, dark <ok>, TOC <ok>, copy button <ok>, phone width <ok>, RTL block <ok | none>
External requests: none  (grep: <N> clickable links only)
Assumed: <order changes, reader, any Hebrew term to double-check>
```
