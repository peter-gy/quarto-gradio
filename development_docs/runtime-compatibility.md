# Runtime compatibility

The browser runtime is frozen at `@gradio/lite@5.45.0`. Gradio archived the upstream Gradio Lite repository on September 11, 2025, so runtime changes require compatibility testing against a fixed and unmaintained upstream package.

## Runtime stack

“Browser runtime” names the complete startup stack:

1. The rendered page loads `lite.js` and `lite.css` from the runtime asset base URL.
2. Gradio Lite creates a dedicated worker by default or a shared worker when requested.
3. The worker loads Pyodide, a Python runtime compiled to WebAssembly.
4. The compatibility bootstrap installs the extension-owned runtime compatibility pins.
5. Gradio Lite installs its bundled Gradio packages and the document's app requirements.
6. Pyodide executes the accumulated Python source.
7. Gradio mounts the app into `<gradio-lite>`.

Static hosting removes the need for a Python application server after publishing. App startup still depends on browser features and network access to remote runtime assets and any remotely installed packages.

## Why the compatibility bootstrap exists

The final Gradio Lite release bundles the Gradio and Gradio Client wheels. Their transitive dependencies are resolved during browser startup, and current package releases can be incompatible with its frozen Pyodide version. `_extensions/gradio/assets/python/runtime-requirements.txt` constrains those dependencies to versions known to install in that environment.

`gradio-compat.js` intercepts the first matching worker wrapper and changes the installation order. It installs each compatibility pin before Gradio Lite performs its normal requirement installation, then restores the browser's native `Blob` constructor. Gradio Lite caches the patched worker Blob URL for later apps using the same runtime URL. A coding playground rerun uses its existing worker.

App requirements are separate. Authors declare those under `gradio.requirements`, and Gradio Lite installs them for the app after the compatibility pins.

## Exact matching boundary

The bootstrap recognizes a worker loader whose source imports this family of URLs:

```text
https://cdn.jsdelivr.net/npm/@gradio/lite@5.45.0/dist/assets/webworker-*.js
```

It then finds an exact minified installation marker in the fetched worker source. A changed runtime version, asset host, bundle structure, or minification output can bypass the bootstrap or trigger “The Gradio Lite worker bootstrap has changed.”

`gradio.cdn` and `gradio.version` remain public escape hatches for users who operate a compatible runtime distribution. They do not carry the default compatibility guarantee.

## Worker modes

The default `shared-worker: false` gives each embedded app a dedicated web worker and isolated Pyodide state. Setting `shared-worker: true` asks Gradio Lite to reuse one Pyodide interpreter and installed package environment. Each app receives a separate app ID, working directory, and fresh `__main__` module. Interpreter-global module state can still create interaction across apps.

Use the default unless an application deliberately accepts this coupling and has been tested in all target browsers. When the browser has no `SharedWorker` API, the frozen runtime warns and falls back to a dedicated worker, so sharing is not guaranteed.

## Trust and network boundary

Opening a rendered page executes its embedded Python source and installed packages in the browser runtime. Authors should pin app requirements and publish code they trust. Readers should treat a quarto-gradio page like any page that loads third-party JavaScript and executes application code.

The default page requests assets from jsDelivr. Package installation can also contact Pyodide or package-hosting origins. A site's Content Security Policy, offline requirements, or restricted network can prevent startup.

## Version map

| Version | Source of truth | Purpose |
|---|---|---|
| Extension version | `_extensions/gradio/_extension.yml` | User-installed Quarto extension release |
| Quarto HTML dependency version | `_extensions/gradio/gradio-html.lua` | Cache path for copied browser assets |
| Gradio Lite runtime version | `_extensions/gradio/gradio-meta.lua` | Upstream browser package loaded by default |
| Contributor environment version | `pyproject.toml` | Local development project metadata |
| Contributor Python packages | `pyproject.toml` and `uv.lock` | Test and example development tools |
| Runtime compatibility pins | `runtime-requirements.txt` | Packages installed before frozen Gradio Lite startup |
| App requirements | Document `gradio.requirements` | Packages used by an author's app |

The local Python `gradio` package can be newer than the browser runtime. An example that runs locally is portable only when its API and dependencies also work with the frozen browser runtime.

## Runtime change procedure

Treat any runtime change as a compatibility migration:

1. Resolve the exact upstream asset and worker URLs.
2. Inspect the worker installation sequence and Pyodide version.
3. Revalidate every runtime compatibility pin.
4. Update the bootstrap pattern and marker when the worker source requires it.
5. Add or update render-contract tests for emitted URLs and copied assets.
6. Render the full documentation site.
7. Browser-test an embedded app, coding playground, app requirements, media, data frames, multiple apps, Reveal.js, and Jupyter output.
8. Check the console and required network requests.
9. Update public runtime documentation and the release versions.

The archive status makes continued use of 5.45.0 an explicit product decision. A replacement runtime should be evaluated as a new supported boundary, not as a routine dependency bump.
