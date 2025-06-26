local cc = require("neo-tree.sources.common.commands")
local utils = require("neo-tree.utils")
local nio = require("nio")
local manager = require("neo-tree.sources.manager")

local M = {}

M.jump_to_test = function(state, toggle_directory)
  local node = state.tree:get_node()
  if not node or not node.extra then
    return
  end

  ---@type neotree-neotest.Item.Extra
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

---@param state neotree-neotest.State
M.run_tests = function(state)
  local tree = state.tree
  local node = tree:get_node()
  require("neotest.consumers.neotree").run_tests_at_node(node)
end

---@param state neotree-neotest.State
M.run_all_tests = function(state)
  require("neotest.consumers.neotree").run_all_tests()
end

M.open = M.jump_to_test

cc._add_common_commands(M)
return M
