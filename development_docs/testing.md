# Testing

Tests should prove the boundary a reader or publisher depends on. The project has three distinct verification layers: static checks, Quarto render checks, and browser checks.

## Standard verification

Run from the repository root:

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

`uv sync` reproduces the contributor environment from `uv.lock`. The format, lint, and type checks cover Python source. `pytest` creates isolated Quarto projects and inspects rendered output. The first Quarto command proves that the complete documentation site builds. The `a11y` profile writes axe results to the browser console for accessibility review. Run the normal render again after that profile.

Pull-request CI runs the frozen environment sync, both Ruff checks, both type checkers, pytest, and the production documentation render with Quarto 1.9.30. The main Pages workflow repeats those checks before deployment.

## Render-contract tests

`tests/test_render.py` owns isolated `.qmd` fixtures. Each test copies the extension into a temporary project, renders one source file, and inspects the result.

Use this layer for contracts visible in generated files:

- default and custom runtime asset URLs
- extension asset copying
- absence of browser assets when a document contains no app
- `<gradio-lite>` attributes
- `<gradio-requirements>` content
- escaped Python source
- source grouping across cells
- reset behavior across multiple apps
- supported source and output formats when output inspection is sufficient

Do not use string assertions for visual layout, worker startup, package installation, or component interaction.

## Browser checks

Use a custom `agent-browser` session and close it after validation. Serve `web/_site` over HTTP rather than opening pages through `file:` URLs.

At minimum, verify:

| Scenario | Observable result |
|---|---|
| Quickstart embedded app | App mounts and returns a greeting |
| Coding playground | Editor and preview mount, edited source can run |
| App requirements | Declared third-party package installs and the interaction completes |
| Multiple apps | Both apps mount and keep their intended source boundary |
| Jupyter output | Notebook-derived page mounts its app |
| Reveal.js | App mounts on its slide and remains usable after slide navigation |
| Representative gallery pages | Text, media, tabular, layout, chat, and model examples start |
| Narrow viewport | Navigation, code, and app surfaces remain reachable |

For each scenario, inspect the browser console and required network requests. A visible component shell is not enough when Python startup failed behind it.

## Documentation integrity

After changing `web/`:

- Confirm every sidebar target exists.
- Confirm local links, heading fragments, images, and iframe targets resolve.
- Confirm include fragments and Reveal.js source documents do not appear as accidental standalone guide pages.
- Confirm public pages have a title, description, task or concept scope, and next route.
- Confirm copied examples contain complete front matter and render successfully.
- Inspect desktop and narrow layouts.

## Current coverage gaps

The automated suite does not yet prove:

- browser startup in continuous integration
- worker bootstrap behavior against the live upstream asset
- package installation and interaction for the full example gallery
- metadata precedence and boolean serialization across a focused matrix
- source grouping and false-positive launch markers
- Reveal.js output through dedicated automated fixtures
- the multi-app debug fragment overwrite behavior
- internal links and heading fragments across the built site

These gaps require manual browser validation for releases. Add focused automation when changing the affected boundary.

## Failure triage

1. Reproduce the smallest failing source document.
2. Decide whether failure occurs during Quarto rendering or browser startup.
3. Inspect generated HTML when the filter or metadata is suspect.
4. Inspect console, network, and visible Gradio errors when startup is suspect.
5. Add the narrowest durable test at the consumer boundary.
6. Run the full standard verification and representative browser matrix.
