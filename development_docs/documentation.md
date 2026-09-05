# Documentation

The public documentation teaches authors how to create, configure, render, and publish browser-run Gradio apps. Contributor documentation records implementation ownership, compatibility constraints, testing, and release procedures.

## Reader routes

The public site has four reader states:

1. **Start here** gives orientation, first success, and the execution model.
2. **Guides** complete one authoring or integration task.
3. **Examples** provide runnable variations grouped by capability.
4. **Reference** supports exact configuration, compatibility, and troubleshooting lookup.

The README is a gateway. It should state the capability, show one complete example, identify the frozen runtime boundary, and route to the documentation site.

## Learning spine

Teach concepts in this order:

1. Install `quarto-gradio`.
2. Enable the `gradio` filter.
3. Define a Gradio app in Python code cells.
4. End the accumulated source with `.launch()`.
5. Run `quarto render` or `quarto preview`.
6. Open the rendered page and wait for browser startup.
7. Choose an embedded app or coding playground.
8. Add app requirements.
9. Configure document-wide attributes or per-app cell options.
10. Apply the pinned runtime, worker, network, and trust constraints.

Every later page should reuse this model instead of introducing a different explanation.

## Canonical terminology

| Term | Meaning |
|---|---|
| `quarto-gradio` | This Quarto extension |
| `gradio` filter | The Lua filter registered in a source document |
| Gradio | The Python library used to define UI components and events |
| Gradio app | The Python application built with Gradio |
| embedded app | The default reader-facing presentation without a source editor |
| coding playground | The presentation with a Python editor and app preview |
| Gradio Lite | The archived upstream browser runtime project |
| `@gradio/lite` | The JavaScript package loaded by rendered pages |
| browser runtime | Gradio Lite, its worker, Pyodide, package installation, and Python execution |
| Pyodide | Python compiled to WebAssembly for execution in a browser |
| Quarto source document | A source being rendered, such as `.qmd` or `.ipynb` |
| Python code cell | Python source processed by the filter in either supported source format |
| launch cell | A Python cell containing `.launch(` that closes one accumulated app source segment |
| document metadata | The document-wide `gradio:` mapping in YAML front matter |
| cell option | A `#| gr-*` setting applied to one launch cell |
| Gradio Lite attribute | An HTML attribute forwarded to `<gradio-lite>` |
| app requirement | A package declared under `gradio.requirements` |
| runtime compatibility pin | An extension-owned package version installed before frozen runtime startup |
| runtime asset base URL | The value configured through the public `gradio.cdn` key |
| Quarto render | Build-time transformation from source to output |
| app startup | Browser-time asset loading, package installation, Python execution, and UI mounting |
| static hosting | Hosting generated files without a Python application server |

## Qualified terms

Use a qualified noun whenever the short form has multiple meanings:

- extension version, HTML dependency version, Gradio Lite runtime version, or package version
- app color mode, Quarto theme, or Python Gradio theme
- playground layout, Gradio component layout, or Quarto page or slide layout
- app requirement, runtime compatibility pin, contributor dependency, or imported Python module
- source format or output format

Avoid “application mode” because Gradio Lite has a separate `app-mode` attribute. Avoid “interactive mode” because embedded apps are also interactive. Use “Examples” for the documentation gallery so “coding playground” has one meaning.

## Page contracts

### Overview

State what the project enables, show visible proof, identify the frozen runtime status, and route to first success.

### Quickstart

Include a complete source file, exact render command, expected file, visible interaction, and the first network and trust caveat.

### Concept page

Define one durable idea, show its shape, explain each component, trace one concrete case, and state where failures appear.

### Guide

Start with the task outcome and a complete example. Change one behavior at a time. Keep the caveat beside the step it constrains. Link to the exact reference entry.

### Example

State what the app demonstrates and what interaction to try. Keep the source visible and runnable. Identify extra packages or browser capabilities when relevant. Link back to the owning guide.

### Reference

For each key, record its spelling, type, default, scope, precedence, emitted consequence, compatibility boundary, and minimal example.

### Troubleshooting

Organize by observable symptom. Name the owning lifecycle stage, first evidence to inspect, and recovery action.

## Source and navigation ownership

`web/_quarto.yml` owns the public navigation. Every public page belongs in that navigation. Source fragments used through Quarto's native `include` shortcode must be excluded from standalone rendering. Reveal.js source documents used as iframe targets are delivery assets and should not appear as guide pages in search or navigation.

Preserve established URLs when reorganizing navigation. Prefer changing labels and grouping over moving pages when the existing path still describes the task.

### Site source and output

- `web/` contains authored site source.
- `web/_site` is generated output and is not committed.
- `web/_extensions` is a tracked symlink to `../_extensions`, so site renders exercise the current extension source.
- `web/public` contains public images and other static inputs.
- `web/analytics.html` is documentation-site behavior. It is not installed with the extension.

The project render list in `web/_quarto.yml` is the delivery inventory. It must include every public page and intentional Reveal.js iframe target. Reusable includes use an underscore prefix so Quarto will not render them as standalone pages.

### Metadata and includes

Quarto merges project metadata from `web/_quarto.yml`, directory metadata from `_metadata.yml`, and page front matter. Page values have the highest precedence. Included QMD text is equivalent to copying that text into the host page, so an included metadata block changes the host page.

Reusable includes therefore contain body content only. The host page owns document metadata such as app requirements and document-wide Gradio Lite attributes. Relative links inside an include resolve from the host page, so use project-root paths when a partial appears at several depths.

Native includes inside an outer code fence display the source. The same body-only partial can be included directly to render its live example. A missing native include is a build failure, which protects the copyable example contract.

### Page classes

| Class | Navigation | Search and sitemap | Purpose |
|---|---|---|---|
| Public page | Included once | Included | Orientation, concept, guide, example, or reference |
| Include file | Excluded | Excluded | Body content reused inside a public page |
| Reveal.js delivery asset | Linked from its guide | Search disabled | Direct presentation loaded by an iframe or link |
| Generated output | Excluded from source control | Generated from the class above | GitHub Pages artifact |

Use a linked landing page for each major reader section. Sidebar labels should route to overview, guide, examples, and reference pages instead of acting as empty containers.

### Public URL behavior

The production origin is `https://quarto-gradio.peter.gy`. Root-relative links and public assets resolve against that origin. Local validation must also serve `web/_site` from its root so it exercises the same path shape. GitHub Pages and custom-domain configuration live outside the generated content, while `website.site-url` owns canonical and sitemap URLs.

Every icon-only navigation or footer link needs an accessible name. Every image needs meaningful alternative text when it carries information. Every iframe needs a distinct title.

### Site scripts

`web/analytics.html` loads documentation analytics. This script belongs to the documentation site and must not be described as extension behavior. Validate its loading, accessibility, and privacy implications separately from Gradio app startup.

## External concepts

At first meaningful use, define and link:

- Quarto as the publishing system that renders the source document
- a Lua filter as code that transforms Quarto's Pandoc document
- Gradio as the Python UI library
- Gradio Lite as the archived browser runtime
- Pyodide as browser-run Python compiled to WebAssembly
- a web worker as the background browser context that runs Python
- static hosting as file hosting without a Python application server

State the operational consequence when a concept affects network access, compatibility, security, or deployment.

## Documentation review

Before publishing:

1. Check terminology against this page.
2. Scrub unsupported “all,” “offline,” “self-contained,” and unqualified “serverless” claims.
3. Render all copyable examples.
4. Check navigation, local links, anchors, images, and iframe targets.
5. Inspect representative pages at desktop and narrow widths.
6. Render with `--profile a11y` and review axe output in the browser console.
7. Start representative apps and check browser errors.
8. Render without the profile, then confirm the deployed base path works on GitHub Pages.

## Current maintenance gaps

- Browser startup, app interaction, links, and accessibility are not automated in CI.
- Reveal.js has rendered documentation examples but no dedicated automated test fixture.
- The Jupyter example renders with the site, while notebook app interaction remains a manual browser check.
- The example gallery has no automated compatibility matrix against the frozen browser runtime.
- Axe reports moderate landmark warnings from the archived Gradio app's nested `main` element and Quarto's generated sidebar toggle roles.
- GitHub Pages custom-domain and DNS ownership is external to this repository.

Keep this list current when a source-owned behavior lacks user-facing explanation, test evidence, or a maintenance procedure.
