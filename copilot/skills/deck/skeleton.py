"""skeleton.py: python-pptx fallback for the deck skill.

Use when Node is not available, or when the organization gave a .pptx template
(python-pptx opens one; PptxGenJS does not). A .potx must first be saved as .pptx
from PowerPoint (File > Save As > PowerPoint Presentation).

Setup:  pip install python-pptx
Run:    python3 build.py                 -> deck.pptx with the neutral palette
        python3 build.py template.pptx   -> deck.pptx built on the template's layouts
"""
import sys
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.util import Inches, Pt

# Neutral palette. Replace with the organization's tokens. Ignored for text the
# template's layouts already color.
T = {
    "BRAND": RGBColor(0x1F, 0x3A, 0x5F),
    "BRAND_SOFT": RGBColor(0xE8, 0xEE, 0xF5),
    "INK": RGBColor(0x1F, 0x1F, 0x1F),
    "MUTED": RGBColor(0x6B, 0x6B, 0x6B),
    "ACCENT": RGBColor(0xD9, 0x77, 0x06),
}
DECK_NAME = "Deck name"
FOOTER_RIGHT = ""  # e.g. "Internal", set by the user

template = sys.argv[1] if len(sys.argv) > 1 else None
prs = Presentation(template) if template else Presentation()
if not template:
    prs.slide_width, prs.slide_height = Inches(10), Inches(5.625)
W, H = prs.slide_width, prs.slide_height


def layout(*names):
    """First layout whose name matches, else the last layout (usually Blank)."""
    for n in names:
        for lay in prs.slide_layouts:
            if lay.name.lower() == n.lower():
                return lay
    return prs.slide_layouts[len(prs.slide_layouts) - 1]


def text(slide, left, top, width, height, body, size=18, bold=False, color=None, align=None):
    box = slide.shapes.add_textbox(left, top, width, height)
    tf = box.text_frame
    tf.word_wrap = True
    lines = body if isinstance(body, list) else [body]
    for i, line in enumerate(lines):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.text = line
        p.font.size = Pt(size)
        p.font.bold = bold
        if color is not None:
            p.font.color.rgb = color
        if align is not None:
            p.alignment = align
    return box


def footer(slide, number):
    if number == 1:
        return
    text(slide, Inches(0.4), H - Inches(0.5), Inches(4), Inches(0.3), DECK_NAME, 10, color=T["MUTED"])
    text(slide, Inches(5.0), H - Inches(0.5), Inches(3.6), Inches(0.3), FOOTER_RIGHT, 10, color=T["MUTED"])
    text(slide, Inches(8.8), H - Inches(0.5), Inches(0.8), Inches(0.3), str(number), 10, color=T["MUTED"])


def notes(slide, body):
    slide.notes_slide.notes_text_frame.text = body


count = 0


def new_slide(*layout_names):
    global count
    count += 1
    s = prs.slides.add_slide(layout(*layout_names))
    return s, count


def title_slide(title, subtitle, presenter, date, note):
    s, n = new_slide("Title Slide")
    if s.shapes.title is not None:
        s.shapes.title.text = title
        text(s, Inches(0.6), Inches(3.0), Inches(8.8), Inches(0.6), subtitle, 20, color=T["MUTED"])
    else:
        text(s, Inches(0.6), Inches(1.6), Inches(8.8), Inches(1.2), title, 40, True, T["BRAND"])
        text(s, Inches(0.6), Inches(2.9), Inches(8.8), Inches(0.6), subtitle, 20, color=T["MUTED"])
    text(s, Inches(0.6), Inches(4.6), Inches(8.8), Inches(0.4), f"{presenter}  |  {date}", 12, color=T["MUTED"])
    notes(s, note)
    footer(s, n)


def section_slide(title, note):
    s, n = new_slide("Section Header", "Title Only")
    if s.shapes.title is not None:
        s.shapes.title.text = title
    else:
        text(s, Inches(0.6), Inches(2.0), Inches(8.8), Inches(1.4), title, 32, True, T["BRAND"])
    notes(s, note)
    footer(s, n)


def bullets_slide(title, bullets, note):
    s, n = new_slide("Title Only", "Blank")
    if s.shapes.title is not None:
        s.shapes.title.text = title
    else:
        text(s, Inches(0.5), Inches(0.3), Inches(9.0), Inches(0.9), title, 28, True, T["BRAND"])
    text(s, Inches(0.5), Inches(1.3), Inches(9.0), Inches(3.4), [f"• {b}" for b in bullets[:6]], 18, color=T["INK"])
    notes(s, note)
    footer(s, n)


def two_column_slide(title, left_heading, left, right_heading, right, note):
    s, n = new_slide("Title Only", "Blank")
    if s.shapes.title is not None:
        s.shapes.title.text = title
    else:
        text(s, Inches(0.5), Inches(0.3), Inches(9.0), Inches(0.9), title, 28, True, T["BRAND"])
    for x, heading, items in ((0.5, left_heading, left), (5.2, right_heading, right)):
        text(s, Inches(x), Inches(1.3), Inches(4.3), Inches(0.5), heading, 18, True, T["BRAND"])
        text(s, Inches(x), Inches(1.9), Inches(4.3), Inches(2.8), [f"• {b}" for b in items[:5]], 16, color=T["INK"])
    notes(s, note)
    footer(s, n)


def closing_slide(title, asks, note):
    s, n = new_slide("Title Only", "Blank")
    if s.shapes.title is not None:
        s.shapes.title.text = title
    else:
        text(s, Inches(0.6), Inches(0.6), Inches(8.8), Inches(1.0), title, 32, True, T["BRAND"])
    text(s, Inches(0.6), Inches(1.9), Inches(8.8), Inches(2.7), [f"{i + 1}. {a}" for i, a in enumerate(asks[:3])], 20, color=T["INK"])
    notes(s, note)
    footer(s, n)


# Example content. Replace with the agreed outline.
title_slide("The pipeline is slower because the agent pool shrank", "Status readout, build platform",
            "DevOps team", "2026-01-01", "Thirty seconds. Say who the deck is for and what decision it leads to.")
section_slide("Where we are", "One sentence, then move on.")
bullets_slide("Median build time doubled over four weeks",
              ["Median 12 min to 24 min", "Queue wait is 80% of the increase", "Two agents removed on 2026-01-01"],
              "Point at the queue wait number.")
two_column_slide("Two ways back to 12 minutes", "Restore agents", ["Known cost", "Done in a day"],
                 "Split the long job", ["Two weeks of work", "Halves queue wait"], "Recommend the right column.")
closing_slide("What we need from you", ["Approve two weeks for the job split", "Name an owner for the test-suite change"],
              "Stop talking after the last ask.")

prs.save("deck.pptx")
print(f"wrote deck.pptx ({count} slides)")
