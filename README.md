# quarto-gradio <img src="web/public/quarto-gradio-logo.png" align="right" alt="quarto-gradio logo" width="150">

`quarto-gradio` embeds Python [Gradio](https://www.gradio.app/) apps in [Quarto](https://quarto.org/) HTML documents. Readers run the app in their browser through [Gradio Lite](https://gradio.app/4.44.1/guides/gradio-lite), so a published page does not need a Python application server.

> [!IMPORTANT]
> The Gradio team [archived Gradio Lite](https://github.com/gradio-app/gradio-lite) on September 11, 2025. `quarto-gradio` pins the browser runtime to its final release, `@gradio/lite@5.45.0`. The runtime receives no upstream fixes. Publish trusted code and pin the Python packages your app installs.

## Quickstart

Install [Quarto 1.6 or newer](https://quarto.org/docs/get-started/) and add the extension to a project:

```bash
quarto add peter-gy/quarto-gradio
```

Create `hello.qmd`:

````md
---
title: Hello
filters:
  - gradio
execute:
  enabled: false
---

```{python}
import gradio as gr

def greet(name):
    return f"Hello {name}!"

gr.Interface(greet, "textbox", "textbox").launch()
```
````

Preview the document:

```bash
quarto preview hello.qmd
```

Quarto writes the app source into the rendered HTML page. When the page opens, the browser downloads the pinned runtime, starts Python through [Pyodide](https://pyodide.org/), executes the source, and mounts the Gradio app. Enter a name to see the greeting.

The initial app startup requires network access for the runtime assets and Python packages. The complete Python source is visible in the rendered page, so keep secrets and credentials out of it.

## How apps are formed

The `gradio` filter collects Python code cells in document order. A cell containing `.launch()` closes the current source segment and creates one embedded app. The filter then starts a new segment, which lets one document contain several apps.

Add `#| gr-playground: true` to a launch cell when readers should be able to edit and run its Python source:

```python
#| gr-playground: true
#| gr-layout: vertical
gr.Interface(greet, "textbox", "textbox").launch()
```

Cell options apply to that app. Document metadata under `gradio.attributes` supplies defaults for every app in the document.

## Documentation

The [documentation site](https://quarto-gradio.peter.gy) includes:

- a [complete quickstart](https://quarto-gradio.peter.gy/guide/get-started/)
- the [render-time and browser-time model](https://quarto-gradio.peter.gy/concepts/how-it-works/)
- guides for [Python packages](https://quarto-gradio.peter.gy/guide/customize-python-modules/), [multiple apps](https://quarto-gradio.peter.gy/guide/define-multiple-apps/), [Jupyter notebooks](https://quarto-gradio.peter.gy/guide/use-with-jupyter/), and [Reveal.js presentations](https://quarto-gradio.peter.gy/guide/use-with-revealjs/)
- the [configuration reference](https://quarto-gradio.peter.gy/reference/)
- [runtime and troubleshooting guidance](https://quarto-gradio.peter.gy/reference/troubleshooting/)

See [example.qmd](example.qmd) for a small standalone source file.

## Development

Contributor setup, architecture, runtime compatibility, testing, documentation, and deployment contracts live in [development_docs/architecture.md](development_docs/architecture.md). Run the complete local verification with:

```bash
uv sync
uv run ruff format --check .
uv run ruff check .
uv run ty check
uv run pyrefly check
uv run pytest
uv run quarto render web
```
