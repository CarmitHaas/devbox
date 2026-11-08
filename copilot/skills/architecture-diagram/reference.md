# Architecture diagram reference

Companion to `SKILL.md`. Exact values and snippets so a diagram can be rebuilt by hand or by script.

## Hard rules
1. Every edge: `edgeStyle=orthogonalEdgeStyle` plus explicit `exitX/exitY/entryX/entryY`. No diagonals.
2. `background="#ffffff"`. Title and subtitle have no fill and no stroke.
3. AWS services: `shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.<name>` (the 2024/2025 library).
4. Other branded services: `shape=image` with `image=https://cdn.simpleicons.org/<slug>/<hex-without-#>`.
5. Generic icons: `image=https://api.iconify.design/mdi/<name>.svg?color=%23<hex>`.
6. Role labels, never names. Nothing from a personal portfolio.
7. One legend per diagram, top-right or bottom-left, only the colors used.

## Page sizes
| Type | Width x Height | Audience |
|---|---|---|
| Vision pitch (about 5 boxes) | 1400 x 700 | non-technical |
| Technical stack overview | 1700 x 920 | engineers, full stack |
| Per-stage deployable view | 1500 to 1600 x 1300 to 1500 | what ships in this phase |
| Conceptual, several diagrams stacked | 1400 x 2400 or more | divider lines between diagrams |

Layout habit: inputs on the left (two stacked boxes, about 220 x 100), the main system zone in the centre padded 20 px from its content, outputs on the right aligned with the inputs. Zones first, nodes second, edges last.

## Edge palette (color = meaning)
| Hex | Color | Meaning | Style |
|---|---|---|---|
| `#2e7d32` | green | request or data flow (the default) | solid |
| `#1565c0` | blue | system output to people (notifications, reports) | solid |
| `#7c3aed` | purple | control, deploy, training flow | solid |
| `#ea580c` | orange | scheduled, batch, async | dashed |
| `#666666` | grey | config, volume mount, env injection | dashed |
| `#b85450` | red | human escalation, human in the loop | solid |
| `#e65100` | dark orange | alert or anomaly ingress | solid |
| `#3b5b78` | slate blue | inputs from external parties | solid |
| `#0e7c66` | teal | per-tenant data | solid |
| `#f9a825` | gold | writes to a knowledge store | solid |
| `#a37500` | dark gold | reads from a knowledge store | dashed |
| `#5e35b1` | deep purple | calls to a model or ML service | solid |

Stroke width: `2` baseline, `2.5` for the primary user-facing flow, `3.5` for the one edge the diagram is about. Dashed: `dashed=1;dashPattern=8 8`.

## Zone and box fills
| Element | Fill | Stroke | Width |
|---|---|---|---|
| Cloud account zone (dashed) | none | `#FF9900` | 2 |
| Customer zone (dashed) | none | `#0e7c66` | 2 |
| Internal / own-use zone (dashed) | none | `#3b82f6` | 2 |
| Chat tool zone (dashed) | none | `#4A154B` | 2 |
| Model provider zone (dashed) | none | `#5e35b1` | 2 |
| Highlighted service box | `#e3f2fd` | `#1565c0` | 3 |
| Knowledge / playbooks box | `#fff8e1` | `#f9a825` | 3 |
| Human experts box | `#fce4ec` | `#b85450` | 3 |
| Small component chips | `#fff4e5` | `#e67e22` | 2 |
| UI / dashboard box | `#e8f5e9` | `#2e7d32` | 2 |
| Footer strip (cross-cutting concerns) | `#fafafa` | `#bdbdbd` | 1 |
| External input box | `#eef2f7` | `#3b5b78` | 2 |

## Cell snippets

Title and subtitle (subtitle is italic grey, dot-separated facets):
```xml
<mxCell id="title" parent="1" vertex="1" value="TITLE"
  style="text;html=1;align=center;verticalAlign=middle;fontSize=22;fontStyle=1;fillColor=none;strokeColor=none;">
  <mxGeometry x="425" y="24" width="900" height="36" as="geometry"/>
</mxCell>
<mxCell id="subtitle" parent="1" vertex="1" value="facet one &#183; facet two &#183; facet three"
  style="text;html=1;align=center;verticalAlign=middle;fontSize=13;fontStyle=2;fontColor=#666666;fillColor=none;strokeColor=none;">
  <mxGeometry x="225" y="70" width="1300" height="22" as="geometry"/>
</mxCell>
```

Dashed zone (label top-right inside the border):
```xml
<mxCell id="zone-cloud" parent="1" vertex="1" value="Cloud account"
  style="rounded=1;whiteSpace=wrap;html=1;dashed=1;dashPattern=8 8;fillColor=none;strokeColor=#FF9900;strokeWidth=2;align=right;verticalAlign=top;spacingRight=14;spacingTop=8;fontStyle=1;">
  <mxGeometry x="300" y="120" width="1100" height="700" as="geometry"/>
</mxCell>
```

AWS service (label below the icon):
```xml
<mxCell id="svc-s3" parent="1" vertex="1" value="Object storage"
  style="sketch=0;points=[[0,0,0],[0.25,0,0],[0.5,0,0],[0.75,0,0],[1,0,0],[0,1,0],[0.25,1,0],[0.5,1,0],[0.75,1,0],[1,1,0],[0,0.25,0],[0,0.5,0],[0,0.75,0],[1,0.25,0],[1,0.5,0],[1,0.75,0]];outlineConnect=0;fontColor=#232F3E;fillColor=#7AA116;strokeColor=#ffffff;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;labelPosition=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.s3;">
  <mxGeometry x="400" y="200" width="60" height="60" as="geometry"/>
</mxCell>
```
Sizes: 56 to 64 px for primary nodes, 36 px inside strips.

Branded non-AWS service (simpleicons) or generic icon (iconify):
```xml
<mxCell id="svc-git" parent="1" vertex="1" value="Source control"
  style="shape=image;verticalLabelPosition=bottom;labelBackgroundColor=default;verticalAlign=top;aspect=fixed;imageAspect=0;image=https://cdn.simpleicons.org/github/181717;fontSize=12;">
  <mxGeometry x="100" y="200" width="48" height="48" as="geometry"/>
</mxCell>
<mxCell id="role-oncall" parent="1" vertex="1" value="on-call"
  style="shape=image;verticalLabelPosition=bottom;labelBackgroundColor=default;verticalAlign=top;aspect=fixed;imageAspect=0;image=https://api.iconify.design/mdi/account-hard-hat.svg?color=%23b85450;fontSize=12;">
  <mxGeometry x="1500" y="200" width="48" height="48" as="geometry"/>
</mxCell>
```

Orthogonal edge (every edge gets all of this):
```xml
<mxCell id="e1" parent="1" edge="1" source="svc-git" target="svc-s3" value="artifacts"
  style="edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;endArrow=classic;strokeColor=#2e7d32;strokeWidth=2;fontSize=11;fontColor=#2e7d32;exitX=1;exitY=0.5;exitDx=0;exitDy=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;">
  <mxGeometry relative="1" as="geometry">
    <Array as="points"><mxPoint x="250" y="230"/></Array>
  </mxGeometry>
</mxCell>
```
Straight line: put both boxes on the same y and use `exitY=0.5;entryY=0.5`. If the target is taller, `entryY=(source_center_y - target_top)/target_height`. Drop the `<Array>` when no bend is needed; add one waypoint per clear corridor otherwise.

Legend (one row per color used):
```xml
<mxCell id="legend" parent="1" vertex="1" value="Legend"
  style="rounded=1;whiteSpace=wrap;html=1;fillColor=#fafafa;strokeColor=#bdbdbd;strokeWidth=1;align=left;verticalAlign=top;spacingLeft=10;spacingTop=6;fontStyle=1;fontSize=12;">
  <mxGeometry x="1440" y="110" width="230" height="90" as="geometry"/>
</mxCell>
<mxCell id="legend-e1" parent="1" edge="1" style="edgeStyle=orthogonalEdgeStyle;endArrow=classic;strokeColor=#2e7d32;strokeWidth=2;html=1;">
  <mxGeometry relative="1" as="geometry"><mxPoint x="1452" y="146" as="sourcePoint"/><mxPoint x="1492" y="146" as="targetPoint"/></mxGeometry>
</mxCell>
<mxCell id="legend-t1" parent="1" vertex="1" value="request / data flow"
  style="text;html=1;align=left;verticalAlign=middle;fontSize=11;fillColor=none;strokeColor=none;">
  <mxGeometry x="1500" y="136" width="160" height="20" as="geometry"/>
</mxCell>
```

## AWS resIcon names (common)
| Service | resIcon | Fill |
|---|---|---|
| EC2 | `ec2` | `#ED7100` |
| Application Load Balancer | `application_load_balancer` | `#8C4FFF` |
| ECS Fargate | `fargate` | `#E7157B` |
| ECR | `elastic_container_registry` | `#E7157B` |
| EKS | `eks_cloud` | `#ED7100` |
| Lambda | `lambda` | `#ED7100` |
| RDS | `rds` | `#3334B9` |
| S3 | `s3` | `#7AA116` |
| SQS | `sqs` | `#E7157B` |
| Bedrock | `bedrock` | `#01A88D` |
| SageMaker | `sagemaker` | `#01A88D` |
| CloudWatch | `cloudwatch` | `#E7157B` |
| Secrets Manager | `secrets_manager` | `#DD344C` |
| IAM | `identity_and_access_management` | `#DD344C` |

Unsure of a name: open draw.io, search the shape in the left panel, drag it in, Edit Style, copy the `resIcon`.

## Simpleicons slugs (common)
`slack/4A154B` `github/181717` `githubactions/2088FF` `gitlab/FC6D26` `jenkins/D24939` `terraform/7B42BC` `docker/2496ED` `kubernetes/326CE5` `helm/0F1689` `argo/EF7B4D` `python/3776AB` `fastapi/009688` `react/61DAFB` `typescript/3178C6` `postgresql/4169E1` `mongodb/47A248` `redis/FF4438` `prometheus/E6522C` `grafana/F46800` `opentelemetry/425CC7` `nginx/009639` `vault/FFEC6E`

Slug unknown: check `https://simpleicons.org`. Generic people and objects: `mdi/account-hard-hat`, `mdi/account-tie`, `mdi/laptop`, `mdi/file-document-outline`, `mdi/database-outline`.

## Minimal valid file
```xml
<mxfile host="app.diagrams.net" agent="architecture-diagram skill" version="29.4.0">
  <diagram id="arch" name="Architecture">
    <mxGraphModel dx="1700" dy="920" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1700" pageHeight="920" background="#ffffff" math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <!-- title, subtitle -->
        <!-- zones -->
        <!-- nodes -->
        <!-- edges last, every one orthogonal with exit/entry points -->
        <!-- legend -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

## Where to run it
| Tool | Open | Export |
|---|---|---|
| draw.io desktop (Windows or Linux) | double-click the `.drawio` | `drawio -x -f png -o out.png in.drawio`; `-f svg`; `-t` transparent; `-b 20` border; `-s 2` scale |
| Windows build from WSL | `explorer.exe in.drawio` | `"/mnt/c/Program Files/draw.io/draw.io.exe" -x -f png -o out.png in.drawio` |
| VS Code extension `hediet.vscode-drawio` | open the `.drawio` file | command palette, `Draw.io: Export` (PNG, SVG, PDF) |

The web editor at app.diagrams.net also opens the file (File > Open from > Device). Check the organization's policy before uploading a diagram with internal names to a web tool.
