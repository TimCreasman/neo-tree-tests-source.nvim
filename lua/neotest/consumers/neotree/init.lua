---@type neotest.Neotree
---@private
local neotree_consumer

---@param client neotest.Client
---@private
local function init(client)
    neotree_consumer = require("neotest.consumers.neotree.neotree")(client)
    local listener = function()
        neotree_consumer.render()
    end

    client.listeners.discover_positions = listener
    client.listeners.run = listener

    client.listeners.results = function(_, _)
        local config = require("neotest.config")

        if not config.summary.expand_errors then
            neotree_consumer.render()
            return
        end
        -- TODO Implement expand on fail
        -- local expanded = {}
        -- for pos_id, result in pairs(results) do
        --   if
        --       result.status == "failed"
        --       and client:get_position(pos_id, { adapter = adapter_id })
        --       and #client:get_position(pos_id, { adapter = adapter_id }):children() > 0
        --   then
        --     expanded[pos_id] = true
        --   end
        -- end
        neotree_consumer.render()
    end

    client.listeners.starting = function()
        neotree_consumer.render()
    end

    client.listeners.started = function()
        neotree_consumer.render()
    end
end

local neotest = {}

---@class neotest.consumers.neotree
neotest.neotree = {}

function neotest.neotree.get_test_tree(adapter_id)
    return neotree_consumer:get_test_tree(adapter_id)
end

---Bootstraps the neo-tree view with the test adapter tree
---This is run within the neo-tree source's navigate method and acts as the bridge between
---the neotest consumer and the neo-tree file view
---
---@param context table
---@param root table
---@param create_item function
---@return table
function neotest.neotree.run(context, root, create_item)
    return neotree_consumer:run(context, root, create_item)
end

function neotest.neotree.get_results(position_id, adapter_id)
    return neotree_consumer:get_results(position_id, adapter_id)
end

---Run tests
---@param node? NuiTree.Node
---@param opts? neotree-neotest.RunArgs
function neotest.neotree.run_tests(node, opts)
    neotree_consumer:run_tests(node, opts)
end

---Stop tests
---@param node? NuiTree.Node
function neotest.neotree.stop_tests(node)
    neotree_consumer:stop_tests(node)
end

---Watch tests
---@param node? NuiTree.Node
function neotest.neotree.watch(node)
    neotree_consumer:watch(node)
end

---Open test output
---@param node? NuiTree.Node
function neotest.neotree.output(node)
    neotree_consumer.output(node)
end

neotest.neotree = setmetatable(neotest.neotree, {
    __call = function(_, client)
        init(client)
        return neotest.neotree
    end,
})

return neotest.neotree
