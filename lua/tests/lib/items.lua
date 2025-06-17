local renderer = require("neo-tree.ui.renderer")
local file_items = require("neo-tree.sources.common.file-items")

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

  renderer.show_nodes({ M.neotest_as_items(state) }, state)

  state.loading = false
end


---Visible for testing
---@param state neotree.State
---@return neotree.FileItem.Directory
M.neotest_as_items = function(state)
  local context = file_items.create_context()
  context.state = state

  -- local root = file_items.create_item(context, state.path, "directory")
  -- root.name = "Test"
  -- root.loaded = true
  -- root.search_pattern = state.search_pattern
  -- context.folders[root.path] = root

  -- Fetch neotest info
  local neotest_adapters = require("neotest.adapters")
  local neotest_client = require("neotest.client")
  local client = neotest_client(neotest_adapters())
  vim.print(client)

  for _, adapter in ipairs(client:get_adapters()) do
    local adapterRoot = file_items.create_item(context, adapter, "directory")
    adapterRoot.name = adapter
    adapterRoot.loaded = true
    adapterRoot.search_pattern = state.search_pattern
    context.folders[adapterRoot.path] = adapterRoot
  end

  vim.print(client:get_adapters())

  -- state.default_expanded_nodes = {}
  -- for id, _ in pairs(context.folders) do
  --   table.insert(state.default_expanded_nodes, id)
  -- end
  -- file_items.advanced_sort(root.children, state)
  return context.folders["/"]
end


return M
