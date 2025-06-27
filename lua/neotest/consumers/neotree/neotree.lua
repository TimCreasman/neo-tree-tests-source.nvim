local lib = require("neotest.lib")
require("neotest.types")
local manager = require("neo-tree.sources.manager")
local config = require("neotest.config")
local nio = require("nio")
local neotree_source = require("neo-tree.sources.tests")
local utils = require("utils")

local events = {
  open = "NeotestNeotreeOpen",
  close = "NeotestNeotreeClose",
}

---@class neotest.Neotree
---@field client neotest.Client
---@field win neotest.PersistentWindow
---@field render_ready nio.control.Event
---@field focused? string
---@field running boolean
-- TODO This name may get confusing even though this is a neotree consumer for neotest,
-- but maybe I should be explict and call it NeotreeConsumer?
local Neotree = {}

function Neotree:new(client)
  self.__index = self
  return setmetatable({
    client = client,
    render_ready = nio.control.event(),
    focused = nil,
    running = false,
  }, self)
end

function Neotree:open()
  -- self.win:open()
  -- vim.api.nvim_exec_autocmds("User", { pattern = events.open })
end

function Neotree:close()
  -- if not self.win:is_open() then
  --   return
  -- end
  -- self.win:close()
  -- vim.api.nvim_exec_autocmds("User", { pattern = events.close })
end

local all_expanded = {}

-- TODO implement animation
function Neotree:render(expanded)
  -- defer rendering to neotree
  vim.schedule(function()
    manager.redraw(neotree_source.name)
  end)
end

function Neotree:set_starting()
  -- self._starting = true
end

function Neotree:set_started()
  -- self._started = true
end

---@param adapter_id string
---@return neotest.Tree|nil,string|nil
function Neotree:get_tree(adapter_id)
  return
end

-- TODO do we need to pass in all of this?
-- Analagous to neo-tree.source.navigate
---@param context table
---@param root table
---@param create_item fun(context: table, path: string, _type: string, bufnr?: number)
---@return table
function Neotree:run(context, root, create_item)
  local adapter_ids = self.client:get_adapters()
  for _, adapter_id in ipairs(adapter_ids) do
    local adapter_name = vim.split(adapter_id, ":", { trimempty = true })[1]
    local success, _ = pcall(create_item, context, root.path .. "/" .. adapter_name, "directory")
    if not success then
      error("Neotree:run: Could not create adapter root for " .. adapter_name)
    end

    local tree = assert(self.client:get_position(nil, { adapter = adapter_id }))

    for _, node in tree:iter_nodes() do
      local data = node:data()

      -- Create a psuedo path so that the tree falls under the adapter_name sub directory
      local path = utils.insert_after(data.id, root.path .. "/", adapter_name .. "/")

      if data.type == "namespace" or data.type == "test" then
        path = path:gsub("::", "/")
      end

      local success, item = pcall(create_item, context, path, "directory")
      if not success then
        error("Neotree:run: Could not create item for " .. path)
      end
      -- TODO this doesn't work right?
      -- item.adapter_name = adapter_name
      if data.type ~= "dir" then
        item.type = data.type
      end

      ---@type neotree-neotest.Item.Extra
      item.extra = {
        range = data.range,
        adapter_id = adapter_id,
        -- TODO, confirm this claim
        -- For non namespace/test node types, real_path and test_id will be identical
        real_path = data.path,
        test_id = data.id
      }
    end
  end

  root.extra = {
    adapter_ids = adapter_ids
  }
  return root
end

---Since both neotest.run and neotest.watch take the same arguments, we can simplify with this method
---@private
---@param adapter_ids string[]
---@param neotest_func any
---@param node? neotree-neotest.Item
local process = function(adapter_ids, neotest_func, node)
  if not node then
    nio.run(function()
      for _, adapter_id in pairs(adapter_ids) do
        local path = utils.get_path_from_adapter_id(adapter_id)
        neotest_func({ path, adapter = adapter_id })
      end
    end)
  elseif node.extra and node.extra.test_id and node.extra.adapter_id then
    nio.run(function()
      neotest_func({ node.extra.test_id, adapter = node.extra.adapter_id })
    end)
  end
end

---Runs all tests under a specific node, or all tests if no node is supplied
---@param node? neotree-neotest.Item
function Neotree:run_tests(node)
  process(self.client:get_adapters(), require("neotest").run.run, node)
end

function Neotree:get_results(test_id, adapter_id)
  return self.client:get_results(adapter_id)[test_id]
end

---@param node? neotree-neotest.Item
function Neotree:watch(node)
  process(self.client:get_adapters(), require("neotest").watch.toggle, node)
  self:render()
end

return function(client)
  return Neotree:new(client)
end
