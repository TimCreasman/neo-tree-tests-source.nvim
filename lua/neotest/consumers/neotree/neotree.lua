local nio = require("nio")
local utils = require("utils")

-- TODO hook these up
-- local events = {
--     open = "NeotestNeotreeOpen",
--     close = "NeotestNeotreeClose",
-- }

---The neotest consumer interface for neotree
---@class neotest.Neotree
---@field client neotest.Client
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

function Neotree.render(_)
    -- defer rendering to neotree
    vim.schedule(function()
        require("neo-tree.sources.manager").redraw(require("neo-tree.sources.tests").name)
    end)
end

-- Analagous to neo-tree.source.navigate
---@param context table
---@param root table
---@param create_item fun(context: table, path: string, _type: string, bufnr?: number)
---@return table
function Neotree:run(context, root, create_item)
    local adapter_ids = self.client:get_adapters()
    for _, adapter_id in ipairs(adapter_ids) do
        local adapter_name = vim.split(adapter_id, ":", { trimempty = true })[1]
        local root_success =
            pcall(create_item, context, root.path .. "/" .. adapter_name, "directory")
        if not root_success then
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

            local item_success, item = pcall(create_item, context, path, "directory")
            if not item_success then
                error("Neotree:run: Could not create item for " .. path)
            end

            if data.type ~= "dir" then
                item.type = data.type
            end

            ---@type neotree-neotest.Node.Extra
            item.extra = {
                range = data.range,
                adapter_id = adapter_id,
                -- TODO, confirm this claim
                -- For non namespace/test node types, real_path and position_id will be identical
                real_path = data.path,
                position_id = data.id,
            }
        end
    end

    root.extra = {
        adapter_ids = adapter_ids,
    }
    return root
end

---Since both neotest.run and neotest.watch take the same arguments, we can simplify with this method
---@private
---@param adapter_ids string[]
---@param neotest_func any
---@param node? neotree-neotest.Node
---@param opts? neotest.run.RunArgs
local process = function(adapter_ids, neotest_func, node, opts)
    if not node then
        nio.run(function()
            for _, adapter_id in pairs(adapter_ids) do
                local path = utils.get_path_from_adapter_id(adapter_id)
                local neotest_opts = { path, adapter = adapter_id }
                neotest_opts = vim.tbl_deep_extend("keep", neotest_opts, opts or {})
                neotest_func(neotest_opts)
            end
        end)
    elseif node.extra and node.extra.position_id and node.extra.adapter_id then
        nio.run(function()
            local neotest_opts = { node.extra.position_id, adapter = node.extra.adapter_id }
            neotest_opts = vim.tbl_deep_extend("keep", neotest_opts, opts or {})
            neotest_func(neotest_opts)
        end)
    end
end

---Runs all tests under a specific node, or all tests if no node is supplied
---@param node? neotree-neotest.Node
---@param opts? neotree-neotest.RunArgs
function Neotree:run_tests(node, opts)
    ---@diagnostic disable-next-line: param-type-mismatch
    process(self.client:get_adapters(), require("neotest").run.run, node, opts)
end

---Stops all tests under a specific node, or all tests if no node is supplied
---@param node? neotree-neotest.Node
function Neotree:stop_tests(node)
    process(self.client:get_adapters(), require("neotest").run.stop, node)
end

function Neotree:get_results(position_id, adapter_id)
    return self.client:get_results(adapter_id)[position_id]
end

---@param node? neotree-neotest.Node
function Neotree:watch(node)
    -- TODO how do watched tests allow updated run args?
    -- Should debug be a toggle?
    process(self.client:get_adapters(), require("neotest").watch.toggle, node)
    self.render()
end

---@param node? neotree-neotest.Node
function Neotree.output(node)
    if not node or not node.extra or not node.extra.adapter_id or not node.extra.position_id then
        return
    end

    require("neotest").output.open({
        position_id = node.extra.position_id,
        adapter = node.extra.adapter_id,
        enter = true,
    })
end

return function(client)
    return Neotree:new(client)
end
