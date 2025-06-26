local highlights = require("neo-tree.ui.highlights")
local common = require("neo-tree.sources.common.components")

---@type table<neotree.Component.Tests._Key, neotree.Renderer>
local M = {}

---@alias neotree.Component.Tests._Key
---|"name"
---|"icon"

---@class neotree.Component.Tests
---@field [1] neotree.Component.Tests._Key|neotree.Component.Common._Key

---@param config neotree.Component.Common.Name
M.name = function(config, node, state)
  local highlight = config.highlight or highlights.FILE_NAME_OPENED
  local name = node.name

  if node.type == "directory" then
    if node:get_depth() == 1 then
      highlight = highlights.ROOT_NAME
      if node:has_children() then
        name = "TESTS for " .. name
      else
        name = "NO TESTS for " .. name
      end
    else
      highlight = highlights.DIRECTORY_NAME
    end
  elseif node.type == "test" then
    highlight = highlights.DIM_TEXT
    -- TODO do I want this?
  elseif config.use_git_status_colors then
    local git_status = state.components.git_status({}, node, state)
    if git_status and git_status.highlight then
      highlight = git_status.highlight
    end
  end
  return {
    text = name,
    highlight = highlight,
  }
end

---@param config neotree.Component.Common.Icon
---@param state neotree-neotest.State
M.icon = function(config, node, state)
  local icon = {
    text = "",
    highlight = "",
  }

  if node.type == "directory" or node.type == "file" then
    icon = common.icon(config, node, state)
  end
  -- TODO should highlights/icons come from neotree or neotest??
  local neotest_config = require("neotest.config")

  local test_id = node.extra and node.extra.test_id or node.id
  local adapter_id = node.extra and node.extra.adapter_id or nil
  local node_test_result = require("neotest.consumers.neotree").get_results(test_id, adapter_id)

  if node_test_result then
    icon.text = icon.text .. neotest_config.icons[node_test_result.status]
    icon.highlight = neotest_config.highlights[node_test_result.status]
  end

  return icon
end

return vim.tbl_deep_extend("force", common, M)
