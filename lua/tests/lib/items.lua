local renderer = require("neo-tree")
local file_items = require("neo-tree.sources.common.file-items")
local neotest_adapters = require("neotest.adapters")
local neotest_client = require("neotest.client")

local M = {}

---Convert the neotesst state to a neotree state.
---@param state neotree.State
M.neotest_consumer = function(state)
  if state.loading then
    return
  end
  state.loading = true
  -- get adapter names here
end

---@return items table
M.neotest_as_items = function()
  local adapter_group = neotest_adapters()
  local client = neotest_client(adapter_group)
  vim.print(client.get_adapters(client))
  return {}
end

return M
