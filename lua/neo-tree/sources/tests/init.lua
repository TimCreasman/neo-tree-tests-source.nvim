local manager = require("neo-tree.sources.manager")
local defaults = require("neo-tree.sources.tests.defaults")

local M = {
    name = "tests",
    display_name = "  Tests",
}

local get_state = function()
    return manager.get_state(M.name)
end

---Navigate to the given path. Navigates to a source, can be used to setup data on first navigation.
---@param state neotree.State
---@param path string Path to navigate to. If empty, will navigate to the cwd.
M.navigate = function(state, path, path_to_reveal, callback, _)
    state.path = path or state.path
    state.dirty = false
    if path_to_reveal then
        local renderer = require("neo-tree.ui.renderer")
        renderer.position.set(state, path_to_reveal)
    end

    require("neo-tree.sources.tests.lib.items").render_items(state)

    if type(callback) == "function" then
        vim.schedule(callback)
    end
end

M.refresh = function()
    manager.refresh(M.name)
end

---Configures the plugin, should be called before the plugin is used.
---@param config table Configuration table containing any keys that the user
--wants to change from the defaults. May be empty to accept default values.
M.setup = function(config, _)
    local events = require("neo-tree.events")
    if config.before_render then
        --convert to new event system
        manager.subscribe(M.name, {
            event = events.BEFORE_RENDER,
            handler = function(state)
                local this_state = get_state()
                if state == this_state then
                    config.before_render(this_state)
                end
            end,
        })
    end

    if config.bind_to_cwd then
        manager.subscribe(M.name, {
            event = events.VIM_DIR_CHANGED,
            handler = M.refresh,
        })
    end
end

M.default_config = defaults

return M
