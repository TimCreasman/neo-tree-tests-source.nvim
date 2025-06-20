local utils = require("utils")
local renderer = require("neo-tree.ui.renderer")
local file_items = require("neo-tree.sources.common.file-items")
local nio = require("nio")

local M = {}

--[[
local function create_state(tabid, sd, winid)
  nt.ensure_config()
  local default_config = default_configs[sd.name]
  local state = vim.deepcopy(default_config, compat.noref())
  state.tabid = tabid
  state.id = winid or tabid
  state.dirty = true
  state.position = {}
  state.git_base = "HEAD"
  state.sort = { label = "Name", direction = 1 }
  events.fire_event(events.STATE_CREATED, state)
  table.insert(all_states, state)
  return state
end
]]

---Convert the neotesst state to a neotree state.
---@param state neotree.State
M.render_items = function(state)
  if state.loading then
    return
  end

  state.loading = true

  -- TODO what is the correct path?
  state.path = --[[ project_root or state.path or ]] vim.fn.getcwd()

  nio.run(function()
    renderer.show_nodes({ M.neotest_as_items(state) }, state)
  end)

  state.loading = false
end

---Visible for testing
---@param state neotree.State
---@return neotree.FileItem.Directory
M.neotest_as_items = function(state)
  local context = file_items.create_context()
  context.state = state

  local adapter_group = require("neotest.adapters")()
  local client = require("neotest.client")(adapter_group)

  local root = file_items.create_item(context, state.path, "directory")
  root.name = vim.fn.fnamemodify(root.path, ":~")
  root.loaded = true
  root.search_pattern = state.search_pattern
  context.folders[root.path] = root
  -- Create item tree from neotest tree
  for _, adapter_id in ipairs(client:get_adapters()) do
    local adapter_name = vim.split(adapter_id, ":", { trimempty = true })[1]
    local success, adapter_root = pcall(file_items.create_item, context, root.path .. "/" .. adapter_name, "directory")
    -- adapter_root.name = adapter_name
    -- adapter_root.loaded = true
    -- adapter_root.search_pattern = state.search_pattern
    -- context.folders[adapter_root.path] = adapter_root

    local tree = assert(client:get_position(nil, { adapter = adapter_id }))

    for _, node in tree:iter_nodes() do
      local data = node:data()

      local path = utils.insert_after(data.id, root.path .. "/", adapter_name .. "/")

      if data.type == "namespace" or data.type == "test" then
        path = path:gsub("::", "/")
      end
      local success, item = pcall(file_items.create_item, context, path, "directory")
      if data.type ~= "dir" and data.type ~= "file" then
        item.type = data.type
      end
    end
  end


  -- state.default_expanded_nodes = {}
  -- for id, _ in pairs(context.folders) do
  --   table.insert(state.default_expanded_nodes, id)
  -- end
  -- file_items.advanced_sort(root.children, state)
  return root
end


return M
