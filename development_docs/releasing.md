# Releasing and deployment

An extension release and a documentation deployment cross separate boundaries. A release changes the files users install. A deployment publishes the current `web/` site to GitHub Pages.

## Version ownership

Update these versions deliberately:

- `_extensions/gradio/_extension.yml` contains the user-facing extension version.
- `_extensions/gradio/gradio-html.lua` contains the Quarto HTML dependency version used in copied asset paths.
- `_extensions/gradio/gradio-meta.lua` contains the default Gradio Lite runtime version.
- `pyproject.toml` describes the contributor Python environment and is not the installed extension version.

For an extension release, keep the extension version and HTML dependency version equal. This gives changed JavaScript, CSS, and requirement assets a fresh path in rendered documents.

Changing the Gradio Lite runtime version is a separate compatibility migration. Follow [runtime-compatibility.md](runtime-compatibility.md).

## Pre-release checks

1. Confirm the worktree contains the intended extension, docs, tests, and lockfile changes.
2. Run the standard static, type, test, and full-site render commands from [testing.md](testing.md).
3. Inspect the generated HTML dependency path and default runtime URLs.
4. Serve `web/_site` and run the browser matrix.
5. Verify local links, images, heading anchors, and iframe targets.
6. Confirm the archive notice, runtime pin, and support matrix match source.
7. Review the lockfile diff and run the configured dependency audit after dependency changes.

Generated `web/_site` output is not committed.

## GitHub Pages deployment

`.github/workflows/publish.yml` runs on pushes to `main`, except changes limited to `README.md`, and on manual dispatch. The job:

1. Checks out the repository.
2. Installs Quarto.
3. Installs `uv` and synchronizes the locked Python environment.
4. Runs formatting, lint, type, and render-contract tests.
5. Runs `uv run quarto render web`.
6. Uploads `web/_site` as the Pages artifact.
7. Deploys that artifact to GitHub Pages.

The configured public site URL is `https://quarto-gradio.peter.gy`.

`.github/workflows/ci.yml` runs the frozen environment sync, Python checks, render-contract tests, and the full documentation render for pull requests. Browser interaction, links, and accessibility remain local release checks. The Pages workflow repeats the code and render checks before main deployment.

## Post-deployment checks

After the Pages job succeeds:

1. Open the deployed overview and quickstart routes.
2. Confirm navigation, search, styles, images, and canonical base paths load.
3. Start the quickstart embedded app and submit an interaction.
4. Start a coding playground and run its code.
5. Start an example with an app requirement.
6. Open the multiple-app, Jupyter, and Reveal.js integrations.
7. Inspect the browser console and required network requests.

A green deployment job proves that Quarto rendered and Pages accepted the artifact. Browser checks prove that the remote runtime and interactive examples still work.

## Recovery

When rendering fails, reproduce the exact `quarto render web` command locally and fix the source or build environment.

When Pages deploys but apps fail, identify whether the failing request targets the site asset path, jsDelivr runtime, worker bundle, Pyodide package source, or an app requirement. Reproduce with the smallest example before changing the compatibility bootstrap.

When a published extension asset is stale, confirm that the HTML dependency version changed with the release and that the rendered page references the new versioned path.
