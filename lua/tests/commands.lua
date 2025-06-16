--This file should contain all commands meant to be used by mappings.
local cc = require("neo-tree.sources.common.commands")

local vim = vim

local M = {}

M.tests_command = function(state)
  local tree = state.tree
  local node = tree:get_node()
  local id = node:get_id()
  local name = node.name
  print(string.format("tests: id=%s, name=%s", id, name))
end

M.refresh = function(state)
  manager.refresh("tests", state)
end

M.show_debug_info = function(state)
  print(vim.inspect(state))
end

cc._add_common_commands(M)
return M
