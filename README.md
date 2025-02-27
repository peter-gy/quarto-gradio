# Gradio Lite for Quarto

An extension to embed [Gradio Lite](https://www.gradio.app/guides/gradio-lite) apps into HTML documents enabling your Python applications to run directly within your web browser without the need for a server.

## Installing

```bash
quarto add peter-gy/quarto-gradio
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

This extension is implemented as a Quarto filter. Once registered, it works out of the box with Python code blocks and it can be customized further via top-level metadata in the document's frontmatter as well as via cell options specified within comments at the top of code blocks.

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).
