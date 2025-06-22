local highlights = require("neo-tree.ui.highlights")
local common = require("neo-tree.sources.common.components")

---@type table<neotree.Component.Tests._Key, neotree.Renderer>
local M = {}

---@alias neotree.Component.Tests._Key
---|"name"

---@class neotree.Component.Tests
---@field [1] neotree.Component.Tests._Key|neotree.Component.Common._Key

---@param config neotree.Component.Tests.Name
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
    -- elseif node.e then
  end
  return {
    text = name,
    highlight = highlight,
  }
end

return vim.tbl_deep_extend("force", common, M)
