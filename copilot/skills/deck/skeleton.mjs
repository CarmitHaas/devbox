// skeleton.mjs: minimal PptxGenJS deck with the five slide types the deck skill uses.
// Setup:  mkdir scratch && cd scratch && npm i pptxgenjs && cp <skills>/deck/skeleton.mjs build.mjs
// Run:    node build.mjs        -> writes deck.pptx next to the script
// Rules baked in: 16:9 canvas (10 x 5.625 in), no "#" in hex values, a fresh options
// object per call, footer with slide number on every slide after the title, notes everywhere.

import pptxgen from "pptxgenjs";

// Neutral palette. Replace these five values with the organization's tokens. No "#".
const T = {
  BRAND: "1F3A5F",      // titles, section backgrounds, accents
  BRAND_SOFT: "E8EEF5", // light fills, second column background
  INK: "1F1F1F",        // body text
  MUTED: "6B6B6B",      // footer, captions
  ACCENT: "D97706",     // one emphasis per slide at most
};
const FONT = "Calibri";
const DECK_NAME = "Deck name";          // short, goes in the footer
const FOOTER_RIGHT = "";                // e.g. "Internal" or "", set by the user
const W = 10, H = 5.625;

const pres = new pptxgen();
pres.defineLayout({ name: "W16x9", width: W, height: H });
pres.layout = "W16x9";

let slideNo = 0;

function footer(slide) {
  slideNo += 1;
  if (slideNo === 1) return; // no footer on the title slide
  slide.addText(DECK_NAME, { x: 0.4, y: H - 0.5, w: 4, h: 0.3, fontSize: 10, fontFace: FONT, color: T.MUTED, margin: 0 });
  slide.addText(FOOTER_RIGHT, { x: 5.0, y: H - 0.5, w: 3.6, h: 0.3, fontSize: 10, fontFace: FONT, color: T.MUTED, align: "right", margin: 0 });
  slide.addText(String(slideNo), { x: 8.8, y: H - 0.5, w: 0.8, h: 0.3, fontSize: 10, fontFace: FONT, color: T.MUTED, align: "right", margin: 0 });
}

function titleSlide({ title, subtitle, presenter, date, notes }) {
  const s = pres.addSlide();
  s.background = { color: T.BRAND };
  s.addText(title, { x: 0.6, y: 1.6, w: 8.8, h: 1.2, fontSize: 40, fontFace: FONT, bold: true, color: "FFFFFF", valign: "bottom", margin: 0 });
  s.addText(subtitle, { x: 0.6, y: 2.9, w: 8.8, h: 0.6, fontSize: 20, fontFace: FONT, color: "FFFFFF", margin: 0 });
  s.addText(`${presenter}  |  ${date}`, { x: 0.6, y: 4.6, w: 8.8, h: 0.4, fontSize: 12, fontFace: FONT, color: "FFFFFF", margin: 0 });
  s.addNotes(notes);
  footer(s);
  return s;
}

function sectionSlide({ title, notes }) {
  const s = pres.addSlide();
  s.background = { color: T.BRAND };
  s.addText(title, { x: 0.6, y: 2.0, w: 8.8, h: 1.4, fontSize: 32, fontFace: FONT, bold: true, color: "FFFFFF", valign: "middle", margin: 0 });
  s.addNotes(notes);
  footer(s);
  return s;
}

function bulletsSlide({ title, bullets, notes }) {
  const s = pres.addSlide();
  s.background = { color: "FFFFFF" };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 0.12, h: H, fill: { color: T.BRAND }, line: { color: T.BRAND } });
  s.addText(title, { x: 0.5, y: 0.3, w: 9.0, h: 0.9, fontSize: 28, fontFace: FONT, bold: true, color: T.BRAND, valign: "top", margin: 0 });
  const items = bullets.slice(0, 6).map((text) => ({ text, options: { bullet: true, breakLine: true } }));
  s.addText(items, { x: 0.5, y: 1.3, w: 9.0, h: 3.4, fontSize: 18, fontFace: FONT, color: T.INK, valign: "top", paraSpaceAfter: 8, margin: 0 });
  s.addNotes(notes);
  footer(s);
  return s;
}

function twoColumnSlide({ title, leftHeading, leftBullets, rightHeading, rightBullets, notes }) {
  const s = pres.addSlide();
  s.background = { color: "FFFFFF" };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 0.12, h: H, fill: { color: T.BRAND }, line: { color: T.BRAND } });
  s.addText(title, { x: 0.5, y: 0.3, w: 9.0, h: 0.9, fontSize: 28, fontFace: FONT, bold: true, color: T.BRAND, valign: "top", margin: 0 });
  const col = (x, heading, bullets, fill) => {
    s.addShape(pres.shapes.RECTANGLE, { x, y: 1.3, w: 4.3, h: 3.4, fill: { color: fill }, line: { color: fill } });
    s.addText(heading, { x: x + 0.2, y: 1.4, w: 3.9, h: 0.5, fontSize: 18, fontFace: FONT, bold: true, color: T.BRAND, margin: 0 });
    const items = bullets.slice(0, 5).map((text) => ({ text, options: { bullet: true, breakLine: true } }));
    s.addText(items, { x: x + 0.2, y: 2.0, w: 3.9, h: 2.6, fontSize: 16, fontFace: FONT, color: T.INK, valign: "top", paraSpaceAfter: 6, margin: 0 });
  };
  col(0.5, leftHeading, leftBullets, "F5F5F5");
  col(5.2, rightHeading, rightBullets, T.BRAND_SOFT);
  s.addNotes(notes);
  footer(s);
  return s;
}

function closingSlide({ title, asks, notes }) {
  const s = pres.addSlide();
  s.background = { color: T.BRAND };
  s.addText(title, { x: 0.6, y: 0.6, w: 8.8, h: 1.0, fontSize: 32, fontFace: FONT, bold: true, color: "FFFFFF", margin: 0 });
  asks.slice(0, 3).forEach((ask, i) => {
    const y = 1.9 + i * 0.9;
    s.addShape(pres.shapes.OVAL, { x: 0.6, y, w: 0.5, h: 0.5, fill: { color: T.ACCENT }, line: { color: T.ACCENT } });
    s.addText(String(i + 1), { x: 0.6, y, w: 0.5, h: 0.5, fontSize: 16, fontFace: FONT, bold: true, color: "FFFFFF", align: "center", valign: "middle", margin: 0 });
    s.addText(ask, { x: 1.3, y, w: 8.0, h: 0.5, fontSize: 18, fontFace: FONT, color: "FFFFFF", valign: "middle", margin: 0 });
  });
  s.addNotes(notes);
  footer(s);
  return s;
}

// Example content. Replace with the agreed outline.
titleSlide({
  title: "The pipeline is slower because the agent pool shrank",
  subtitle: "Status readout, build platform",
  presenter: "DevOps team",
  date: "2026-01-01",
  notes: "Thirty seconds. Say who the deck is for and what decision it leads to.",
});
sectionSlide({ title: "Where we are", notes: "One sentence, then move on." });
bulletsSlide({
  title: "Median build time doubled over four weeks",
  bullets: ["Median 12 min to 24 min", "Queue wait is 80% of the increase", "Two agents removed on 2026-01-01", "No change in the job definitions"],
  notes: "Point at the queue wait number. Skip the last bullet if short on time.",
});
twoColumnSlide({
  title: "Two ways back to 12 minutes",
  leftHeading: "Restore agents",
  leftBullets: ["Known cost", "Done in a day", "Does not fix the root cause"],
  rightHeading: "Split the long job",
  rightBullets: ["Two weeks of work", "Halves queue wait", "Needs a test-suite change"],
  notes: "Recommend the right column. Say why the left column is the fallback.",
});
closingSlide({
  title: "What we need from you",
  asks: ["Approve two weeks for the job split", "Name an owner for the test-suite change", "Keep the two agents until the split ships"],
  notes: "Stop talking after the third ask. Let the room answer.",
});

await pres.writeFile({ fileName: "deck.pptx" });
console.log(`wrote deck.pptx (${slideNo} slides)`);
