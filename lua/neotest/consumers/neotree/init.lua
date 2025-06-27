local lib = require("neotest.lib")
local nio = require("nio")
local Neotree = require("neotest.consumers.neotree.neotree")
local config = require("neotest.config")

-- TODO change this type
---@type neotest.Neotree
---@private
local neotree_consumer

-- local group = vim.api.nvim_create_augroup("FollowSummaryOnOpen", { clear = true })

---@param client neotest.Client
---@private
local function init(client)
  neotree_consumer = Neotree(client)
  local listener = function()
    neotree_consumer:render()
  end

  client.listeners.discover_positions = listener
  client.listeners.run = listener

  client.listeners.results = function(adapter_id, results)
    if not config.summary.expand_errors then
      neotree_consumer:render()
      return
    end
    -- TODO Implement expand on fail
    local expanded = {}
    for pos_id, result in pairs(results) do
      if
          result.status == "failed"
          and client:get_position(pos_id, { adapter = adapter_id })
          and #client:get_position(pos_id, { adapter = adapter_id }):children() > 0
      then
        expanded[pos_id] = true
      end
    end
    neotree_consumer:render(expanded)
  end

  client.listeners.starting = function()
    neotree_consumer:render()
  end

  client.listeners.started = function()
    neotree_consumer:render()
  end

  --[[
  if config.summary.follow then
    local function now_or_on_summary_open(func)
      if summary.win:is_open() then
        func()
      else
        vim.api.nvim_create_autocmd("User", {
          pattern = "NeotestSummaryOpen",
          group = group,
          callback = func,
          once = true,
        })
      end
    end

    client.listeners.test_file_focused = function(_, file_path)
      now_or_on_summary_open(function()
        summary:expand(file_path, true)
      end)
    end
    client.listeners.test_focused = function(_, pos_id)
      now_or_on_summary_open(function()
        summary:expand(pos_id, false, true)
      end)
    end
  end ]]
end


local neotest = {}
-- TODO implement these types
---@toc_entry Neotree Consumer
---@text
--- A consumer that displays the structure of the test suite, along with results and
--- allows running tests all within neo-tree.
---@seealso |neotest.Config.summary.mappings| for all mappings in the summary window
---@class neotest.consumers.neotree
neotest.neotree = {}

-- TODO do I need an exposed api like this?

function neotest.neotree.get_test_tree(adapter_id)
  return neotree_consumer:get_test_tree(adapter_id)
end

---Bootstraps the neo-tree view with the test adapter tree
---@param context table
---@param root table
---@param create_item function
---@return table
function neotest.neotree.run(context, root, create_item)
  return neotree_consumer:run(context, root, create_item)
end

function neotest.neotree.get_results(test_id, adapter_id)
  return neotree_consumer:get_results(test_id, adapter_id)
end

---Run tests
---@param node? neotree-neotest.Item
function neotest.neotree.run_tests(node)
  neotree_consumer:run_tests(node)
end

---Watch tests
---@param node? neotree-neotest.Item
function neotest.neotree.watch(node)
  neotree_consumer:watch(node)
end

---Open test output
---@param node? neotree-neotest.Item
function neotest.neotree.output(node)
  neotree_consumer:output(node)
end

--[[
--- Open the summary window
--- ```vim
---   lua require("neotest").summary.open()
--- ```
function neotest.neotree.open()
   if summary.win:is_open() then
    return
  end
  summary:open()
  summary:render()
end

--- Close the summary window
--- ```vim
---   lua require("neotest").summary.close()
--- ```
function neotest.neotree.close()
  -- summary:close()
end

---Toggle the summary window
---
--- ```vim
---  lua require("neotest").summary.toggle()
--- ```
function neotest.neotree.toggle()
   nio.run(function()
    if summary.win:is_open() then
      summary:close()
    else
      summary:open()
      summary:render()
    end
  end)
end

---@class neotest.summmary.RunMarkedArgs : neotest.run.RunArgs

--- Run all marked positions
---@param args? neotest.summmary.RunMarkedArgs
function neotest.neotree.run_marked(args)
   args = args or {}
  for adapter_id, component in pairs(summary.components) do
    if not args.adapter or args.adapter == adapter_id then
      for pos_id, marked in pairs(component.marked) do
        if marked then
          require("neotest").run.run(
            vim.tbl_extend("keep", { pos_id, adapter = component.adapter_id }, args)
          )
        end
      end
    end
  end
end

--- Return a table<adapter id, position_id[]> of all marked positions
--- @return table<string, string[]>
function neotest.neotree.marked()
   local all_marked = {}
  for adapter_id, component in pairs(summary.components) do
    local adapter_marked = {}
    local has_marked = false
    for pos_id, marked in pairs(component.marked) do
      if marked then
        table.insert(adapter_marked, pos_id)
        has_marked = true
      end
    end
    if has_marked then
      all_marked[adapter_id] = adapter_marked
    end
  end
  return all_marked
end

---@class neotest.summary.ClearMarkedArgs
---@field adapter? string Adapter ID, if not given all adapters are cleared

--- Clear all marked positions
---@param args? neotest.summary.ClearMarkedArgs
function neotest.neotree.clear_marked(args)
   args = args or {}
  for adapter_id, component in pairs(summary.components) do
    if not args.adapter or args.adapter == adapter_id then
      component.marked = {}
    end
  end
  summary:render()
end

--- Set the target for an adapter tree
---@param adapter_id string
---@param position_id string|nil Position ID to target, nil to reset target
function neotest.neotree.target(adapter_id, position_id)
  local component = summary.components[adapter_id]
  if not component then
    lib.notify(("No tree found for adapter %s"):format(adapter_id))
  end
  component.target = position_id
  summary:render()
end

function neotest.neotree:expand(pos_id, recursive)
  nio.run(function()
    summary:expand(pos_id, recursive)
  end)
end
]] --

-- "Cheat" and expose the attached client:
-- Eventually we will want to only expose necessary client functions via the consumer api
function neotest.neotree.get_client()
  return neotree_consumer.client
end

neotest.neotree = setmetatable(neotest.neotree, {
  __call = function(_, client)
    init(client)
    return neotest.neotree
  end,
})

return neotest.neotree
