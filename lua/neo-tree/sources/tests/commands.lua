local cc = require("neo-tree.sources.common.commands")
local utils = require("neo-tree.utils")

local M = {}

M.jump_to_test = function(state, toggle_directory)
  local node = state.tree:get_node()
  if node == nil then
    return
  end

  ---@type neo-tree.Item.Extra
  local extra = node.extra
  local _type = node.type

  -- The node's current path includes the adapter_id as the root.
  -- This was done to organize tests via adapter incase the developer
  -- uses multiple test runners in the same project.
  -- Due to this, we retrieve the real path here
  node.path = extra.real_path or node.path

  if _type == "namespace" then
    -- This tricks the open function into opening namespaces.
    node.type = "file"
  end

  cc.open(state, toggle_directory)

  -- Position cursor
  if _type == "namespace" or _type == "test" then
    local winid = utils.get_appropriate_window(state)
    vim.api.nvim_win_set_cursor(winid, { extra.range[1] + 1, extra.range[2] })
  end
end

M.run_tests = function()
  local results = self.client:get_results(adapter_id)
end

M.open = M.jump_to_test

cc._add_common_commands(M)
return M
