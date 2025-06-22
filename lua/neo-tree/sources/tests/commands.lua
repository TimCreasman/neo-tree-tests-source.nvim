local cc = require("neo-tree.sources.common.commands")
local manager = require("neo-tree.sources.manager")

local vim = vim

local M = {}

M.jump_to_test = function(state, node)
  node = node or state.tree:get_node()
  if node:get_depth() == 1 then
    return
  end
  vim.print(node.adapter_name)
end

M.open = M.jump_to_test
-- M.tests_command = function(state)
--     local tree = state.tree
--     local node = tree:get_node()
--     local id = node:get_id()
--     local name = node.name
--     print(string.format("tests: id=%s, name=%s", id, name))
-- end
--
-- M.refresh = function(state)
--     manager.refresh("tests", state)
-- end
--
-- M.show_debug_info = function(state)
--     print(vim.inspect(state))
-- end

cc._add_common_commands(M)
return M
