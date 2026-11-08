"""build.py: markdown file -> self-contained explainer page, using template.html next to this file.

Usage (a venv, because -I ignores user-site packages):
    python3 -m venv .venv && .venv/bin/pip install markdown
    .venv/bin/python -I build.py source.md out.html [--title "Page name"] [--footer "Internal, do not forward"]
                                                   [--lede "One sentence"] [--date 2026-01-01]

Markdown conventions the script understands:
    # Title                       page title (unless --title is given)
    text before the first ##      the lede (unless --lede is given)
    ## Section                    one collapsible section + one TOC entry
    > **Note:** ...               callout; also **Warning:** and **Decision:**
    ```lang ... ```               code block; the page adds the copy button
    <div dir="rtl" lang="he" markdown="1"> ... </div>   a Hebrew block, page stays LTR
"""
import argparse
import datetime
import html
import pathlib
import re
import sys

try:
    import markdown
except ImportError:
    sys.exit("missing dependency: pip install markdown")

HERE = pathlib.Path(__file__).resolve().parent
TEMPLATE = HERE / "template.html"

ap = argparse.ArgumentParser()
ap.add_argument("source")
ap.add_argument("out")
ap.add_argument("--title")
ap.add_argument("--lede")
ap.add_argument("--footer", default="")
ap.add_argument("--date", default=datetime.date.today().isoformat())
args = ap.parse_args()

src = pathlib.Path(args.source).read_text(encoding="utf-8")
tpl = TEMPLATE.read_text(encoding="utf-8")

md = markdown.Markdown(extensions=["fenced_code", "tables", "toc", "attr_list", "md_in_html", "sane_lists"],
                       extension_configs={"toc": {"toc_depth": "2-2"}})
body = md.convert(src)

# Title: --title, else the first <h1>.
title = args.title
h1 = re.search(r"<h1[^>]*>(.*?)</h1>", body, re.S)
if h1:
    title = title or re.sub(r"<[^>]+>", "", h1.group(1)).strip()
    body = body.replace(h1.group(0), "", 1)
title = title or pathlib.Path(args.source).stem

# Callouts: a blockquote whose first words are **Note:**, **Warning:** or **Decision:**.
# Two such blockquotes separated by one blank line are merged by markdown into one; split them back.
BLOCKQUOTE = re.compile(r"<blockquote>(.*?)</blockquote>", re.S)
LABEL = re.compile(r"<p><strong>(Note|Warning|Decision):</strong>\s*")

def callouts(m):
    inner = m.group(1).strip()
    if not LABEL.match(inner):
        return m.group(0)  # an ordinary quote, leave it
    out = []
    pieces = LABEL.split(inner)  # ['', 'Note', 'text</p>...', 'Warning', 'text</p>...']
    for kind, text in zip(pieces[1::2], pieces[2::2]):
        out.append(f'<div class="callout callout-{kind.lower()}"><span class="callout-label">{kind}</span>'
                   f"<p>{text.strip()}</div>")
    return "\n".join(out)

body = BLOCKQUOTE.sub(callouts, body)

# Tables scroll sideways on narrow screens instead of widening the page.
body = body.replace("<table>", '<div class="scrollx"><table>').replace("</table>", "</table></div>")

# Split into sections at each <h2>. Text before the first <h2> is the lede.
parts = re.split(r"(?=<h2[^>]*>)", body)
lede = args.lede
if parts and not parts[0].lstrip().startswith("<h2"):
    pre = parts.pop(0).strip()
    if pre and not lede:
        lede = re.sub(r"<[^>]+>", "", pre).strip()
lede = lede or ""

sections, toc = [], []
for i, part in enumerate(parts, 1):
    m = re.match(r"<h2(?:\s+id=\"([^\"]*)\")?[^>]*>(.*?)</h2>(.*)", part, re.S)
    if not m:
        continue
    sid = m.group(1) or f"s{i}"
    heading = m.group(2).strip()
    plain = re.sub(r"<[^>]+>", "", heading).strip()
    extra = " sources" if plain.lower() == "sources" else ""
    sections.append(
        f'<section class="sec{extra}" id="{sid}"><details open><summary><span class="n">{i:02d}</span>'
        f"<h2>{heading}</h2></summary>\n<div class=\"body\">\n{m.group(3).strip()}\n</div></details></section>\n"
    )
    toc.append(f'    <li><a href="#{sid}">{plain}</a></li>')

if not sections:
    sys.exit("no '## ' sections found in the source")

def replace_inner(doc, open_re, close, new):
    """Replace what sits between the first match of open_re and the next `close`."""
    m = re.search(open_re, doc)
    if not m:
        sys.exit(f"template marker not found: {open_re}")
    end = doc.index(close, m.end())
    return doc[: m.end()] + new + doc[end:]

out = tpl
out = replace_inner(out, r"<title>", "</title>", html.escape(title))
out = replace_inner(out, r'<h1 id="page-title">', "</h1>", html.escape(title))
out = replace_inner(out, r'<p class="lede" id="page-lede">', "</p>", html.escape(lede))
out = replace_inner(out, r'<span id="page-date">', "</span>", html.escape(args.date))
out = replace_inner(out, r'<nav id="toc" aria-label="Contents">\s*<div class="toc-title">Contents</div>\s*<ol>', "</ol>",
                    "\n" + "\n".join(toc) + "\n  ")
out = replace_inner(out, r'<main id="content">', "</main>", "\n\n" + "\n".join(sections) + "\n")
out = replace_inner(out, r'<span id="footer-line">', "</span>", html.escape(args.footer))

pathlib.Path(args.out).write_text(out, encoding="utf-8")
print(f"wrote {args.out}: {len(sections)} sections, title '{title}'")
