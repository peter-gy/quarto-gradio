from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).parents[1]


def render(source: str, tmp_path: Path) -> tuple[str, Path]:
    project = tmp_path / "project"
    project.mkdir()
    shutil.copytree(ROOT / "_extensions", project / "_extensions")
    (project / "test.qmd").write_text(source, encoding="utf-8")

    subprocess.run(
        ["quarto", "render", "test.qmd"],
        cwd=project,
        check=True,
        capture_output=True,
        text=True,
    )

    return (project / "test.html").read_text(encoding="utf-8"), project


def test_default_render_uses_final_gradio_lite_release(tmp_path: Path) -> None:
    html, project = render(
        """---
format: html
execute:
  enabled: false
filters:
  - gradio
---

```{python}
import gradio as gr

gr.Interface(lambda name: f"Hello {name}!", "textbox", "textbox").launch()
```
""",
        tmp_path,
    )

    base_url = "https://cdn.jsdelivr.net/npm/@gradio/lite@5.45.0/dist"
    assert f"{base_url}/lite.js" in html
    assert f"{base_url}/lite.css" in html
    assert "gradio-compat.js" in html
    assert "<gradio-lite shared-worker" not in html
    assert (
        project
        / "test_files/libs/quarto-contrib/quarto-gradio-1.0.2/runtime-requirements.txt"
    ).is_file()


def test_document_without_an_app_does_not_load_browser_assets(tmp_path: Path) -> None:
    html, project = render(
        """---
format: html
execute:
  enabled: false
filters:
  - gradio
---

This document has no Gradio app.
""",
        tmp_path,
    )

    assert "gradio-compat.js" not in html
    assert "@gradio/lite" not in html
    assert not (project / "test_files/libs/quarto-contrib").exists()


def test_multiple_launch_cells_emit_independent_apps(tmp_path: Path) -> None:
    html, _ = render(
        """---
format: html
execute:
  enabled: false
filters:
  - gradio
---

```{python}
import gradio as gr
first_value = "first app"
gr.Interface(lambda: first_value, None, "textbox").launch()
```

```{python}
import gradio as gr
second_value = "second app"
gr.Interface(lambda: second_value, None, "textbox").launch()
```
""",
        tmp_path,
    )

    apps = [
        fragment.split("</gradio-lite>", maxsplit=1)[0]
        for fragment in html.split("<gradio-lite")[1:]
    ]
    assert len(apps) == 2
    assert "first_value" in apps[0]
    assert "second_value" not in apps[0]
    assert "first_value" not in apps[1]
    assert "second_value" in apps[1]


def test_custom_cdn_is_used_as_an_asset_root(tmp_path: Path) -> None:
    html, _ = render(
        """---
format: html
execute:
  enabled: false
filters:
  - gradio
gradio:
  cdn: "https://cdn.example.com/gradio-lite"
---

```{python}
import gradio as gr

gr.Interface(lambda name: f"Hello {name}!", "textbox", "textbox").launch()
```
""",
        tmp_path,
    )

    assert "https://cdn.example.com/gradio-lite/dist/lite.js" in html
    assert "https://cdn.example.com/gradio-lite/dist/lite.css" in html


def test_version_metadata_selects_a_published_release(tmp_path: Path) -> None:
    html, _ = render(
        """---
format: html
execute:
  enabled: false
filters:
  - gradio
gradio:
  version: "5.43.0"
---

```{python}
import gradio as gr

gr.Interface(lambda name: f"Hello {name}!", "textbox", "textbox").launch()
```
""",
        tmp_path,
    )

    base_url = "https://cdn.jsdelivr.net/npm/@gradio/lite@5.43.0/dist"
    assert f"{base_url}/lite.js" in html
    assert f"{base_url}/lite.css" in html
