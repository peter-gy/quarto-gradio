-- Import modules
local debug = require("gradio-debug")
local html = require("gradio-html")
local meta = require("gradio-meta")
local table = require("table-utils")

-- Determines whether an element is a Python code block
local function is_python_code_block(el)
  return el.classes and el.classes:includes("cell-code") and el.classes:includes("python")
end

-- Determines whether an element is a Gradio launch code block with a .launch() call
local function is_gradio_launch_code(el)
  return is_python_code_block(el) and el.text:find("%.launch%(")
end

-- Determines whether an element is a Gradio app cell. A Gradio app cell is the direct parent of a Gradio launch code block
local function is_gradio_app_cell(el)
  return #el.content > 0 and is_gradio_launch_code(el.content[1])
end

-- Main filter function to traverse the document AST
function Pandoc(doc)
  -- Ensure HTML dependencies are installed
  html.ensure_html_deps()

  -- Python source code accumulated from code blocks which will eventually be injected between <gradio-lite> tags
  local python_code = ""

  -- Stores gradio metadata from document frontmatter
  local gradio_metadata = meta.parse_frontmatter(doc.meta)

  -- Each time we encounter a Python code block, we add its content to the python_code string
  function CodeBlock(el)
    if is_python_code_block(el) then
      python_code = python_code .. el.text .. "\n"
    end
  end

  -- Each time we encounter a Gradio App cell, we construct and insert <gradio-lite>...</gradio-lite> element with the accumulated Python code
  function Div(el)
    if is_gradio_app_cell(el) then
      quarto.log.debug("Found Gradio app cell")

      -- Create files array with a single app.py file for now
      -- TODO: Revisit use cases for multiple files via <gradio-file> tags
      local files = {
        {
          name = "app.py",
          content = python_code
        }
      }

      -- Extract Gradio-specific attributes from the cell, to-be-merged with global attributes,
      -- will be passed to <gradio-lite> tags as HTML element attributes
      local gradio_attributes = meta.parse_attributes(el.attributes)
      local merged_attributes = table.merge({ gradio_metadata.attributes, gradio_attributes })
      quarto.log.debug(merged_attributes)

      -- Create Gradio HTML
      local gradio_html = html.create_gradio_html(
        files,
        gradio_metadata.cdn,
        gradio_metadata.version,
        gradio_metadata.requirements,
        merged_attributes
      )
      debug.save_html(gradio_html)

      -- Reset accumulated Python code so that a single Quarto document can contain multiple Gradio Lite apps
      python_code = ""

      -- Return the modified HTML
      return pandoc.Div({ el.content[1], pandoc.RawBlock('html', gradio_html) }, el.attr)
    end
  end

  doc.blocks = doc.blocks:walk({
    CodeBlock = CodeBlock,
    Div = Div
  })
  
  return doc
end
