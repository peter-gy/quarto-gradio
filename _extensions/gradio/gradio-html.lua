-- We specify custom CSS for some aesthetic alignment between Gradio and Quarto themes
local function ensure_html_deps()
    quarto.doc.add_html_dependency({
        name = "quarto-gradio",
        version = "1.0.0",
        stylesheets = { "assets/css/quarto-gradio.css" }
    })
end

-- As we're injecting raw HTML into the document, we need to escape special characters which may be present in the Python code
local function escape_html(text)
    return text
        :gsub('&', '&amp;')
        :gsub('<', '&lt;')
        :gsub('>', '&gt;')
        :gsub('"', '&quot;')
        :gsub("'", '&#39;')
end

-- Build an HTML attributes string from a table of attributes
local function build_attributes_string(attributes)
    if not attributes then
        return ""
    end

    local attr_str = ""
    for key, value in pairs(attributes) do
        -- For boolean attributes like 'playground', just include the name if true
        if value == true or value == "true" then
            attr_str = attr_str .. string.format(' %s', key)
            -- Skip attributes that are false or "false"
        elseif value ~= false and value ~= "false" then
            attr_str = attr_str .. string.format(' %s="%s"', key, value)
        end
    end

    return attr_str
end

-- Generate Gradio Lite HTML with the given configuration
local function create_gradio_html(files, cdn, version, requirements, attributes)
    -- Ensure there's only one file for now
    if #files ~= 1 then
        error("Expected exactly one file for Gradio app, but got " .. #files)
    end

    -- Get the entrypoint content (the only file)
    local entrypoint_content = files[1].content

    -- Build attributes string for gradio-lite tag
    local attr_str = build_attributes_string(attributes)

    -- Build base URL of JS and CSS files. If version is nil, do not specify @<version>
    local base_url = cdn
    if version ~= nil then
        base_url = base_url .. '@' .. version
    end

    -- Create the HTML template
    return string.format([[
<div class="quarto-gradio">
  <script type="module" crossorigin src="%s/dist/lite.js"></script>
  <link rel="stylesheet" href="%s/dist/lite.css" />
  <gradio-lite%s>
    <gradio-requirements>
%s
    </gradio-requirements>
%s
  </gradio-lite>
</div>
]],
        base_url,
        base_url,
        attr_str,
        table.concat(requirements, "\n"),
        escape_html(entrypoint_content)
    )
end

return {
    ensure_html_deps = ensure_html_deps,
    create_gradio_html = create_gradio_html,
}
