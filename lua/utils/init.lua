local M = {}

---@param str string
---@param substring string
---@param insert_str string
---@return string
M.insert_after = function(str, substring, insert_str)
  -- insert adapter name immediately after root_path
  local start_pos = string.find(str, substring, _, true)

  if start_pos then
    local end_pos = start_pos + string.len(substring) - 1
    return string.sub(str, 1, end_pos) .. insert_str .. string.sub(str, end_pos + 1)
  else
    return str
  end
end

return M
