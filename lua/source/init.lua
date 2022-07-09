--This file should have all functions that are in the public api and either set
--or read the state of this source.

local vim = vim
local renderer = require("neo-tree.ui.renderer")
local manager = require("neo-tree.sources.manager")
local events = require("neo-tree.events")
local utils = require("neo-tree.utils")

local M = {
    -- This is the name our source will be referred to as
    -- within Neo-tree
    name = "test",
    -- This is how our source will be displayed in the Source Selector
    display_name = "Tests"
}


---Returns the stats for the given node in the same format as `vim.loop.fs_stat`
---@param node table NuiNode to get the stats for.
--- Example return value:
---
--- {
---   birthtime {
---     sec = 1692617750 -- seconds since epoch
---   },
---   mtime = {
---     sec = 1692617750 -- seconds since epoch
---   },
---   size = 11453, -- size in bytes
--- }
--
---@class StatTime
--- @field sec number
---
---@class StatTable
--- @field birthtime StatTime
--- @field mtime StatTime
--- @field size number
---
--- @return StatTable Stats for the given node.
M.get_node_stat = function(node)
    -- This is just fake data, you'll want to replace this with something real
    return {
        birthtime = { sec = 1692617750 },
        mtime = { sec = 1692617750 },
        size = 11453,
    }
end

---Navigate to the given path.
---@param path string Path to navigate to. If empty, will navigate to the cwd.
M.navigate = function(state, path)
    if path == nil then
        path = vim.fn.getcwd()
    end
    state.path = path

    -- Do something useful here to get items
    local items = {
        {
            id = "1",
            name = "root",
            type = "directory",
            stat_provider = "example-custom",
            children = {
                {
                    id = "1.1",
                    name = "child1",
                    type = "directory",
                    stat_provider = "example-custom",
                    children = {
                        {
                            id = "1.1.1",
                            name = "child1.1 (you'll need a custom renderer to display this properly)",
                            type = "custom",
                            stat_provider = "example-custom",
                            extra = { custom_text = "HI!" },
                        },
                        {
                            id = "1.1.2",
                            name = "child1.2",
                            type = "file",
                            stat_provider = "example-custom",
                        },
                    },
                },
            },
        },
    }
    renderer.show_nodes(items, state)
end

---Configures the plugin, should be called before the plugin is used.
---@param config table Configuration table containing any keys that the user
--wants to change from the defaults. May be empty to accept default values.
M.setup = function(config, global_config)
    local adapter_group = require("neotest.adapters")()
    local client = require("neotest.client")(adapter_group)
    -- -- redister or custom stat provider to override the default libuv one
    -- require("neo-tree.utils").register_stat_provider("example-custom", M.get_node_stat)
    -- -- You most likely want to use this function to subscribe to events
    -- if config.use_libuv_file_watcher then
    --     manager.subscribe(M.name, {
    --         event = events.FS_EVENT,
    --         handler = function(args)
    --             manager.refresh(M.name)
    --         end,
    --     })
    -- end
end

return M
