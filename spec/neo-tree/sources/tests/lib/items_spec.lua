local neotest_adapters = require("neotest.adapters")
local items = require("neo-tree.sources.tests.lib.items")

local mock = require('luassert.mock')
local stub = require('luassert.stub')

describe("neotest_as_items", function()
  it("should return a table", function()
    -- assert.is.True(type(items.neotest_as_items()) == "table")
  end)

  it("should list all adapters as root directories", function()
    local neotest_client = require("neotest.client")

    local config = require("neo-tree")
    mock(config, true)

    local mocked_client = neotest_client()
    local mocked_adapter_names = { "adapter 1", "adapter 2" }
    -- vim.print(mocked_client)
    mocked_client.get_adapters = function()
      return mocked_adapter_names
    end

    -- Is this the only way to mock classes?
    package.loaded["neotest.client"] = function(_)
      return mocked_client
    end

    local items_to_render = items.neotest_as_items({ path = vim.fn.getcwd() })

    for _, adapter in ipairs(mocked_adapter_names) do
      assert.truthy(items_to_render[adapter])
    end
  end)
end)

describe("neotest_render_items", function()
  it("should call renderer with state and list of items", function()
    local mocked_items = {}
    local mocked_state = {}

    local renderer = require("neo-tree.ui.renderer")
    stub(renderer, "show_nodes")

    local neotest_as_items_mock = stub(items, "neotest_as_items")
    neotest_as_items_mock.returns(mocked_items)

    items.render_items(mocked_state)
    assert.stub(renderer.show_nodes).was.called_with(mocked_items, mocked_state)
  end)
end)
