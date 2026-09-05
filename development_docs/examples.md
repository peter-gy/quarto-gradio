# Examples

The documentation examples are executable product surfaces. They exercise Gradio component families, package paths, worker behavior, and Quarto output formats against the frozen browser runtime.

## Shared site configuration

`web/_quarto.yml` enables the `gradio` filter and disables Quarto-side Python execution for the whole site. `web/playground/_metadata.yml` turns every gallery example into a coding playground with a vertical editor and preview layout.

A gallery source file is therefore not a standalone copyable document. Its page must link readers to the Quickstart front matter needed outside the documentation project.

## Core workflow examples

| Surface | Contract exercised |
|---|---|
| `web/guide/get-started/_hello-world.qmd` | One embedded app, live textbox update, default runtime |
| `web/guide/enable-coding-playground/` | Cell and document attributes, vertical playground, code rerun |
| `web/guide/customize-python-modules/` | Document app requirements and direct Micropip installation |
| `web/guide/define-multiple-apps/` | Source reset, dedicated workers, two independent interactions |
| `web/guide/use-with-jupyter/notebook-gradio.ipynb` | Notebook metadata, Python-cell authoring, and browser startup |
| `web/guide/use-with-revealjs/` | Reveal.js output, slide placement, iframe and direct presentation routes |

Reusable QMD partials begin with `_`, contain body content only, and are excluded from rendering. The host guide owns document metadata. Reveal.js sources are intentional render targets with `search: false`.

## Gallery inventory

| Page | Gradio surface | Python or browser dependency | Interaction |
|---|---|---|---|
| Sentence Builder | `Interface`, slider, dropdown, checkbox group, radio, checkbox | Gradio | Change several inputs and generate text |
| Diff Texts | `HighlightedText` | Python standard library | Compare two strings |
| Generate Tone | Audio output | NumPy | Generate and play a waveform |
| Sepia Filter | Image input and output | NumPy, scikit-learn sample image | Apply an image transform |
| Video Identity | Video input and output | Browser media APIs | Upload and return a video |
| Filter Records | Editable `Dataframe` | Pandas | Filter rows with a dropdown |
| Transpose Matrix | NumPy data frame | NumPy | Exchange rows and columns |
| Kinematics | `Blocks`, sliders, `LinePlot` | NumPy, Pandas | Update a plot from linked controls |
| Layouts | Rows, columns, tabs, accordion | NumPy, scikit-learn sample image | Exercise component layout and events |
| Tabbed Interface | `TabbedInterface`, `Interface`, `ChatInterface` | Gradio | Switch among app types |
| Chatbot | `ChatInterface` | Python standard library | Return a synchronous response |
| Streaming Chatbot | Generator response | Python standard library | Stream a response incrementally |
| Tool Status Messages | `ChatMessage` metadata | Python standard library | Display simulated progress, error, and success states |
| Chatbot with Artifacts | `ChatInterface` with `Code` output | Gradio | Render a code artifact beside chat |
| Sentiment Analysis | `Interface.from_pipeline`, top-level await | `transformers-js-py==0.19.10`, remote model | Run sentiment inference |

The tool-status example simulates a tool trace and does not contact a service. The sentiment example downloads model assets at startup and needs explicit network and latency guidance.

## Example page contract

Every public example page includes:

1. A title and description.
2. The capability it demonstrates.
3. The action a reader should take.
4. The expected result.
5. Package, model, media, or network caveats when they affect the action.
6. A visible and editable source cell.

Use exact package pins for remote app requirements. Keep examples within Python Gradio 5.45 APIs even when the contributor environment contains a newer Gradio release.

## Browser matrix

For a release, start and interact with:

- the Quickstart embedded app
- a simple coding playground and a rerun after editing source
- the Plotly requirement example
- both apps in the multiple-app guide
- the notebook-rendered app fixture or manual artifact
- both Reveal.js presentations
- one example from each gallery group
- Sentiment Analysis through model completion

Check desktop and narrow widths. Confirm that editor and preview remain reachable, media controls fit the content column, slide navigation works, and no required request fails.

## Adding an example

1. Choose the existing guide or gallery group that owns the capability.
2. Use the smallest app that proves it.
3. Pin every added app requirement.
4. Add the page to the sidebar and the gallery landing page.
5. Render the full site.
6. Start the app, complete its interaction, and inspect console and network errors.
7. Add render or browser automation when the example establishes a new supported boundary.
