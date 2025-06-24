local lib = require("neotest.lib")
require("neotest.types")
local manager = require("neo-tree.sources.manager")
local config = require("neotest.config")
local nio = require("nio")
local neotree_source = require("neo-tree.sources.tests")

local events = {
  open = "NeotestNeotreeOpen",
  close = "NeotestNeotreeClose",
}

---@class neotest.Neotree
---@field client neotest.Client
---@field win neotest.PersistentWindow
---@field components table<string, SummaryComponent>
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
  vim.schedule(function()
    manager.redraw(neotree_source.name)
  end)
  -- if not self.win:is_open() then
  --   return
  -- end
  -- if not self.running then
  --   nio.run(function()
  --     self:run()
  --   end)
  -- end
  -- for pos_id, _ in pairs(expanded or {}) do
  --   all_expanded[pos_id] = true
  -- end
  -- self.render_ready.set()
end

function Neotree:set_starting()
  -- self._starting = true
end

function Neotree:set_started()
  -- self._started = true
end

function Neotree:run()
  --[[ if self.running then
    return
  end
  self.running = true
  xpcall(function()
    while true do
      self.render_ready.wait()
      self.render_ready.clear()
      local canvas = Canvas.new(config.summary)
      if self._starting then
        for _, adapter_id in ipairs(self.client:get_adapters()) do
          local tree = assert(self.client:get_position(nil, { adapter = adapter_id }))
          self:_write_header(canvas, adapter_id, tree)
          self.components[adapter_id] = self.components[adapter_id]
              or SummaryComponent(self.client, adapter_id)
          if config.summary.animated then
            if self.components[adapter_id]:render(canvas, tree, all_expanded, self.focused) then
              self.render_ready.set()
            end
          else
            self.components[adapter_id]:render(canvas, tree, all_expanded, self.focused)
          end
          all_expanded = {}
          canvas:write("\n")
        end
      else
        nio.run(function()
          self.client:get_adapters()
        end)
      end
      if canvas:length() > 1 then
        canvas:remove_line()
        canvas:remove_line()
      elseif not self._started then
        canvas:write("Parsing tests")
      else
        canvas:write("No tests found")
      end
      local rendered, err = pcall(canvas.render_buffer, canvas, self.win:buffer())
      if not rendered then
        logger.error("Couldn't render buffer", err)
      end
      nio.api.nvim_exec2("redraw", {})
      nio.sleep(100)
    end
  end, function(msg)
    logger.error("Error in summary consumer", debug.traceback(msg, 2))
  end)
  self.running = false ]]
end

function Neotree:expand(pos_id, recursive, focus)
  --[[ local tree = self.client:get_position(pos_id)
  if not tree then
    return
  end
  local expanded = {}
  if recursive then
    for _, node in tree:iter_nodes() do
      if #node:children() > 0 then
        expanded[node:data().id] = true
      end
    end
  else
    expanded[pos_id] = true
  end
  for parent in tree:iter_parents() do
    expanded[parent:data().id] = true
  end
  if focus then
    self.focused = pos_id
  end
  self:render(expanded) ]]
end

return function(client)
  return Neotree:new(client)
end
