-- Check if debug mode is enabled via environment variable
local function is_enabled()
    local debug_env = os.getenv("QUARTO_GRADIO_DEBUG")
    return debug_env ~= nil
end

-- Save debug HTML to a file if debug mode is enabled, useful for debugging Gradio Lite apps in raw HTML
local function save_html(html_content)
    if not is_enabled() then
        return
    end

    -- Extract base filename without extension
    local input_file = quarto.doc.input_file
    local base_filename = input_file:match("([^/\\]+)%.%w+$") or input_file

    -- Create debug filename
    local debug_filename = base_filename .. ".debug.html"

    -- Save to file
    local file = io.open(debug_filename, "w")
    if file then
        file:write(html_content)
        file:close()
        quarto.log.debug("Debug HTML saved to: " .. debug_filename)
    else
        quarto.log.error("Failed to save debug HTML to: " .. debug_filename)
    end
end

return {
    save_html = save_html,
}
