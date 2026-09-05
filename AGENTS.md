# Contributor guide

`quarto-gradio` is a Quarto extension that turns Python code cells into browser-run Gradio apps. Read [development_docs/architecture.md](development_docs/architecture.md) before changing the filter, browser runtime, examples, or public documentation.

## Commands

Run commands from the repository root.

```bash
uv sync
uv run ruff format --check .
uv run ruff check .
uv run ty check
uv run pyrefly check
uv run pytest
uv run quarto render web
uv run quarto render web --profile a11y
```

- `ruff format --check` and `ruff check` verify Python formatting and lint rules.
- `ty check` and `pyrefly check` verify the Python test code with both configured type checkers.
- `pytest` renders isolated fixtures and checks the emitted HTML contract.
- `quarto render web` builds the documentation site into `web/_site`.
- `quarto render web --profile a11y` builds the site with axe accessibility results in the browser console. Run a normal render afterward before deployment checks.

After documentation or runtime changes, open representative pages in a browser. Confirm that an embedded app starts, a coding playground starts, required packages install, and the browser console contains no application errors. See [development_docs/testing.md](development_docs/testing.md).

## Architecture

The end-to-end path has five stages:

1. A Quarto source document enables the `gradio` filter.
2. The Lua filter collects Python code cells in document order through each launch cell.
3. The filter emits one `<gradio-lite>` element for every accumulated source segment ending in `.launch()`.
4. The rendered HTML page loads the pinned Gradio Lite assets and the extension compatibility bootstrap.
5. The browser runtime starts Pyodide in a worker, installs requirements, executes the Python source, and mounts the Gradio app.

Keep these stages distinct in code, tests, and prose. Quarto renders a page. The browser starts an app.

## Source ownership

- `_extensions/gradio/gradio.lua` owns Pandoc traversal, source accumulation, launch-cell detection, and multi-app boundaries.
- `_extensions/gradio/gradio-meta.lua` owns defaults, document metadata, cell options, and precedence.
- `_extensions/gradio/gradio-html.lua` owns HTML serialization and the Quarto HTML dependency.
- `_extensions/gradio/assets/js/gradio-compat.js` owns the frozen runtime compatibility bootstrap.
- `_extensions/gradio/assets/python/runtime-requirements.txt` owns package versions installed before Gradio starts.
- `_extensions/gradio/assets/css/quarto-gradio.css` owns the narrow CSS bridge between Gradio Lite and Quarto.
- `tests/` owns render-contract checks.
- `web/` owns the public documentation site and runnable examples.
- `development_docs/` owns contributor contracts, rationale, and maintenance procedures.

The runnable feature matrix lives in [development_docs/examples.md](development_docs/examples.md).

## Transformation invariants

- A processed Python code cell has both `cell-code` and `python` classes in the Pandoc document.
- A launch cell contains the literal source pattern `.launch(`.
- Python source accumulates until a launch cell, then resets for the next embedded app.
- Cell options use the `gr-` prefix and override document-wide `gradio.attributes` for that app.
- `gradio.requirements` applies document-wide and is emitted inside `<gradio-requirements>`.
- Boolean HTML attributes are present when true and omitted when false.
- Python source is escaped before it is inserted into raw HTML.

Protect these invariants through rendered output or browser behavior. Do not test private helper formatting when a consumer boundary is available.

## Runtime compatibility

Gradio Lite was archived on September 11, 2025. The default browser runtime is frozen at `@gradio/lite@5.45.0`.

The compatibility bootstrap recognizes the exact default jsDelivr worker URL and patches an exact worker-source marker. A different runtime asset base URL or Gradio Lite runtime version does not inherit that compatibility guarantee. Read [development_docs/runtime-compatibility.md](development_docs/runtime-compatibility.md) before changing `gradio.version`, `gradio.cdn`, the worker bootstrap, or runtime requirements.

## Versions

Always qualify a version by its owner.

- Extension version: `_extensions/gradio/_extension.yml`
- Quarto HTML dependency version: `_extensions/gradio/gradio-html.lua`
- Gradio Lite runtime version: `_extensions/gradio/gradio-meta.lua`
- Contributor Python environment version: `pyproject.toml`
- Package versions: `pyproject.toml`, `uv.lock`, app requirements, or runtime compatibility pins

Update the extension version and Quarto HTML dependency version together so Quarto publishes changed assets under a new cache path.

## Documentation language

Use the glossary in [development_docs/documentation.md](development_docs/documentation.md).

- Use `quarto-gradio` for this project and “Gradio Lite” for the archived upstream runtime.
- Use “Quarto source document,” then name `.qmd` or `.ipynb` when the format matters.
- Use “Python code cell” across source formats and “launch cell” for the cell that closes an app source segment.
- Use “embedded app” and “coding playground” for the two presentations.
- Use “Examples” for the documentation gallery.
- Distinguish app requirements from runtime compatibility pins.
- Distinguish app color mode, playground layout, Gradio component layout, and Quarto page or slide layout.
- State that static hosting removes the Python application server. It still requires network access to load remote runtime assets and packages.

Do not publish implementation rationale in the user reference. Put contributor details in `development_docs/` and keep the public reference contract-shaped.

## Documentation workflow

Every public page must appear in navigation or be deliberately excluded from the render set. Reusable include fragments must not become standalone pages. Each copyable example must include all required front matter and must render through the same boundary a reader uses.

For a new guide:

1. Start with the reader task and a complete source example.
2. State the visible result.
3. Explain the new concepts using the established lifecycle.
4. Keep network, trust, version, and format caveats beside the affected step.
5. Link to the exact reference entry and next task.
6. Render the site and verify the page in a browser at desktop and narrow widths.

## Publishing

GitHub Actions renders `web/` and deploys `web/_site` to GitHub Pages after a push to `main`. Generated `_site` files are local build output and are not committed. Follow [development_docs/releasing.md](development_docs/releasing.md) for release and deployment checks.
