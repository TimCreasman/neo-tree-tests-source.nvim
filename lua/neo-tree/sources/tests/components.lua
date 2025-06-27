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
  local highlights = require("neo-tree.ui.highlights")
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
    -- DOC_TODO document how this is disabled for test items?
    -- elseif config.use_git_status_colors then
    --   local git_status = state.components.git_status({}, node, state)
    --   if git_status and git_status.highlight then
    --     highlight = git_status.highlight
    --   end
  end
  return {
    text = name,
    highlight = highlight,
  }
end

---@param config neotree.Component.Common.Icon
---@param node neotree-neotest.Item
---@param state neotree-neotest.State
M.icon = function(config, node, state)
  local highlights = require("neo-tree.ui.highlights")
  local icon = {
    text = "",
    highlight = "",
  }

  if node.type == "directory" or node.type == "file" then
    icon = common.icon(config, node, state)
  end
  -- DOC_TODO Explain how highlights/icons come from the neotest config
  local neotest_config = require("neotest.config")

  local position_id = node.extra and node.extra.position_id or node.id
  local adapter_id = node.extra and node.extra.adapter_id or nil
  local node_test_result = require("neotest.consumers.neotree").get_results(position_id, adapter_id)

  if node_test_result then
    local neotest = require("neotest")
    if neotest.watch and neotest.watch.is_watching(position_id) then
      icon.text = icon.text .. neotest_config.icons.watching
    else
      icon.text = icon.text .. neotest_config.icons[node_test_result.status]
    end
    icon.highlight = neotest_config.highlights[node_test_result.status]
  end

  return icon
end

return vim.tbl_deep_extend("force", common, M)
