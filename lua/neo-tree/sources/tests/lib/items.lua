local M = {}

M.render_items = function(state)
    local nio = require("nio")

    if state.loading then
        return
    end

    state.loading = true

    state.path = vim.fn.getcwd()

    nio.run(function()
        require("neo-tree.ui.renderer").show_nodes({ M.neotest_as_items(state) }, state)
        state.loading = false
    end)
end

---@return neotree.FileItem.Directory
M.neotest_as_items = function(state)
    local file_items = require("neo-tree.sources.common.file-items")
    local context = file_items.create_context()
    context.state = state

    local neotree_consumer = require("neotest.consumers.neotree")

    local root = file_items.create_item(context, state.path, "directory")
    root.name = vim.fn.fnamemodify(root.path, ":~")
    root.loaded = true
    root.search_pattern = state.search_pattern
    context.folders[root.path] = root

    -- Convert neotest to neotree NuiNodes
    root = neotree_consumer.run(context, root, file_items.create_item)

    -- Expand all nodes
    state.default_expanded_nodes = {}
    for id, _ in pairs(context.folders) do
        table.insert(state.default_expanded_nodes, id)
    end
    file_items.advanced_sort(root.children, state)

    return root
end

return M
