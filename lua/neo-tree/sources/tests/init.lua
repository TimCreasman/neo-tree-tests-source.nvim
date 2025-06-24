local renderer = require("neo-tree.ui.renderer")
local manager = require("neo-tree.sources.manager")
local items = require("neo-tree.sources.tests.lib.items")
local events = require("neo-tree.events")
local defaults = require("neo-tree.sources.tests.defaults")

local M = {
  name = "tests",
  display_name = " 󰊢 Tests"
}

---Navigate to the given path. Navigates to a source, can be used to setup data on first navigation.
---@param state neotree-neotest.State
---@param path string Path to navigate to. If empty, will navigate to the cwd.
M.navigate = function(state, path, path_to_reveal, callback, async)
  state.path = path or state.path
  state.dirty = false
  if path_to_reveal then
    renderer.position.set(state, path_to_reveal)
  end


  vim.print("TEST NAV")
  state.neotest_client = require("neotest.consumers.neotree").get_client()
  -- local adapter_group = require("neotest.adapters")()
  -- state.neotest_client = require("neotest.client")(adapter_group)

  items.render_items(state)

  if type(callback) == "function" then
    vim.schedule(callback)
  end
end

---Configures the plugin, should be called before the plugin is used.
---@param config table Configuration table containing any keys that the user
--wants to change from the defaults. May be empty to accept default values.
M.setup = function(config, global_config)
  if config.use_libuv_file_watcher then
    -- TODO figure out how we wna tot react to events?
    manager.subscribe(M.name, {
      event = events.FS_EVENT,
      handler = function(args)
        manager.refresh(M.name)
      end,
    })
  end
end

M.default_config = defaults

return M
