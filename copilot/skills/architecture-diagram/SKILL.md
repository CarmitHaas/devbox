---
name: architecture-diagram
description: Create or edit a draw.io (.drawio) architecture diagram in a fixed house style, white background, orthogonal edges with explicit exit and entry points, the modern AWS 2024/2025 shape library for AWS services, simpleicons for other branded services, dashed boundary zones, edge color as meaning with a legend, role labels instead of names. Use when asked for an architecture diagram, a stack overview, a per-stage deployment view, a flow picture, or to edit any .drawio file. Not for sequence diagrams, Gantt charts, or slide graphics.
---

# Architecture diagram

## What this skill does
Writes or edits the XML of a `.drawio` file so that the diagram follows one consistent style, reproducibly, without opening a mouse-driven editor for every change. The style rules and the exact cell snippets live in `reference.md` next to this file. Output is the `.drawio` file, optionally a PNG or SVG export, and a short list of what was assumed.

## When to use it
- "Draw the architecture of <system>"
- "Make a stage 2 diagram, same as stage 1 plus the queue"
- "Fix the arrows in this .drawio" (orthogonal, legend, icons)

Do not use it for a sequence or a timeline; those are a different notation. Do not use it to decorate a slide; export a PNG from here and place it with `deck`.

## How to do it
1. Read: the system description, any existing `.drawio` in the repo (match its positions when extending it), and `reference.md` for the palette, the shape names, and the snippets. Identify the diagram type: vision pitch (5 boxes, non-technical), technical stack overview, per-stage deployable view, or conceptual flow. Identify the audience; it decides how much detail survives.
2. Decide the page size from the table in `reference.md`, then the zones (dashed boundaries: cloud account, customer side, internal side, a vendor product), then the nodes inside each zone, then the edges and what each edge color means. Each color means one thing in the whole diagram. Default is green for request and data flow; add a color only when a second meaning is present.
3. Check before writing XML: every AWS service uses `shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.<name>`; every other branded service is a simpleicons image; generic things (people, laptops, documents) are iconify `mdi` images; no person's name anywhere, roles only (engineer, lead, on-call, reviewer); nothing from a personal portfolio (posts, talks, CV items).
4. Ask one question when the system boundary is unclear (what is inside the account, what is a third party) or when a stage diagram's delta is not stated. Do not invent components.
5. Write the file in this order: title and subtitle; zones; nodes; edges last, each with `edgeStyle=orthogonalEdgeStyle` and explicit `exitX/exitY/entryX/entryY`; legend top-right or bottom-left listing only the colors used in this diagram. Straight lines: align the two boxes on the same y (or x) and use `0.5` on both ends. A line that must pass a box gets one explicit waypoint in a clear corridor. If routing still tangles, move boxes; never accept a diagonal.
6. Check by opening the file: draw.io desktop, or VS Code with the `hediet.vscode-drawio` extension (open the `.drawio` file, it renders in the editor; keep the XML view for edits). Look for: a diagonal, a box crossing a zone border (pad 20 px), a missing legend entry, a label with a name, an icon that failed to load (an empty square means a wrong `resIcon` or URL).
7. Export when asked. With draw.io desktop installed, from the command line: `drawio -x -f png -o out.png in.drawio` (also `-f svg`; add `-t` for a transparent background, `-b 20` for a 20 px border, `-s 2` for a 2x PNG). From WSL with the Windows build: `"/mnt/c/Program Files/draw.io/draw.io.exe" -x -f png -o out.png in.drawio` (verify the path once on the machine). The VS Code extension exports through its command palette (`Draw.io: Export`), not from the shell.
8. Report in the format below.

### Diagram types
| Type | Shows | Leave out |
|---|---|---|
| Vision pitch | 5 to 7 boxes, the flow between them, one sentence per box | service names, ports, vendors |
| Technical stack overview | every service, its zone, every flow with a meaning | internal class or module names |
| Per-stage deployable view | what runs at the end of this stage, deltas marked | anything planned for a later stage |
| Conceptual flow | the mechanism (loop, hand-off, boundary), several diagrams stacked | exact service icons |

### Stage diagrams
A stage N diagram is a visual superset of stage N-1: same nodes in the same positions, new nodes added, and one "new in this stage" callout box naming the deltas. The reader of stage 3 should recognize stage 2 without effort.

## What not to do
- Do not draw a diagonal edge, ever. Fix the layout instead.
- Do not mix icon sources for AWS services; the AWS 2024/2025 library only.
- Do not use color for variety. Each color is a meaning; the legend proves it.
- Do not put a legend entry for a color the diagram does not use.
- Do not write personal names or portfolio items; roles and systems only.
- Do not let a box touch or cross a zone border; move it inward.
- Do not pre-commit a diagram to a scale-out service the project has not adopted; draw the compute the project actually runs and put the future in a stage diagram.
- Do not hand-edit coordinates by guessing; compute them from the grid (10 px) and the box sizes.
- Do not upload a diagram with internal names to the web editor without checking the organization's policy; the desktop app and the VS Code extension work offline.

## Output format
```
Diagram: <path>.drawio  (<type>, <width> x <height>)
Zones: <zone>, <zone>, ...
Nodes: <N> (<AWS> aws4, <branded> simpleicons, <generic> iconify)
Edges: <N>, all orthogonal; colors used: <green: request flow>, <grey dashed: config>, ...
Legend: <top-right | bottom-left>, <N> entries
Export: <out.png | not requested>
Assumed: <boundary decisions, components placed without a source, anything guessed>
Check in the editor: <what to eyeball, one line>
```
