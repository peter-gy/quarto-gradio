function src_include_shortcode(args, kwargs)
    -- Get the file path from the first argument
    local file_path = args[1]
    if not file_path then
        io.stderr:write("Warning: No file path provided to src-include\n")
        return pandoc.Null()
    end

    -- Read the file contents
    local file, err = io.open(file_path, "r")
    if not file then
        io.stderr:write("Warning: Could not open file: " .. file_path .. (err and (" - " .. err) or "") .. "\n")
        return pandoc.Null()
    end

    -- Read the entire file content
    local content = file:read("*all")
    file:close()

    return pandoc.Code(content)
end

return {
    ['src-include'] = src_include_shortcode
}
