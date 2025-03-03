local table = require("table-utils")

-- Default metadata values
local default_metadata = {
    cdn = "https://cdn.jsdelivr.net/npm/@gradio/lite",
    version = nil,
    requirements = {},
    attributes = {
        ['shared-worker'] = true,
        theme = "dark",
    },
}

-- JS-like map function
local function map(tbl, f)
    local t = {}
    for k, v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

-- Parse a literal value from metadata
local function parse_literal(meta, key)
    local value = meta[key]
    if type(value) == "table" then
        if value.t == "MetaBool" then
            return value
        else
            return value[1].text
        end
    else
        return value
    end
end

-- Parse a list of literal values from metadata
local function parse_list(meta, key)
    local value = meta[key]
    if type(value) == "table" then
        return map(value, function(v) return v[1].text end)
    end
    return {}
end

-- Parse metadata from document frontmatter
local function parse_frontmatter(meta)
    local gradio_metadata = table.copy(default_metadata)

    if meta.gradio then
        if meta.gradio.version then
            gradio_metadata.version = parse_literal(meta.gradio, "version")
        end

        if meta.gradio.cdn then
            gradio_metadata.cdn = parse_literal(meta.gradio, "cdn")
        end

        if meta.gradio.requirements then
            gradio_metadata.requirements = parse_list(meta.gradio, "requirements")
        end

        if meta.gradio.attributes then
            for key, _ in pairs(meta.gradio.attributes) do
                gradio_metadata.attributes[key] = parse_literal(meta.gradio.attributes, key)
            end
        end
    end

    return gradio_metadata
end

-- Extract Gradio-specific attributes from a table of attributes
-- Used to specify attributes for Gradio Lite Apps at the Quarto document's cell level
local function parse_attributes(attributes)
    local gradio_attributes = {}
    for key, value in pairs(attributes) do
        if key:match("^gr%-") then
            -- Store without the gr- prefix
            local clean_key = key:gsub("^gr%-", "")
            gradio_attributes[clean_key] = value
        end
    end
    return gradio_attributes
end

-- Return the module
return {
    parse_frontmatter = parse_frontmatter,
    parse_attributes = parse_attributes
}
