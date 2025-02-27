-- Merge multiple tables into one, similar to JS's spread operator
local function merge(tables)
    local merged = {}
    for _, tbl in ipairs(tables) do
        for key, value in pairs(tbl) do
            merged[key] = value
        end
    end
    return merged
end

-- Deep copy a table
function copy(orig)
    local orig_type = type(orig)
    local result
    if orig_type == 'table' then
        result = {}
        for orig_key, orig_value in next, orig, nil do
            result[copy(orig_key)] = copy(orig_value)
        end
        setmetatable(result, copy(getmetatable(orig)))
    else
        -- number, string, boolean, etc
        result = orig
    end
    return result
end

return {
    merge = merge,
    copy = copy
}
