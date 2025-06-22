local items = require("neo-tree.sources.tests.lib.items")

local stub = require('luassert.stub')

describe("neotest_as_items", function()
  it("should return a table", function()
    local mocked_state = { path = "./" }
    assert.is.True(type(items.neotest_as_items(mocked_state)) == "table")
  end)

  it("should correctly format a basic testing tree", function()
    local mocked_state = { path = "/root" }
    local neotest_client = require("neotest.client")
    local neotest_tree = require("neotest.types.tree")

    local mocked_client = neotest_client()
    local mocked_adapter_names = { "adapter_1", "adapter_2" }

    mocked_client.get_adapters = function()
      return mocked_adapter_names
    end

    -- Mocking this will create three children under each adapter, one for the test.lua, one for the namespace, and another for the test case itself
    mocked_client.get_position = function()
      return neotest_tree.from_list({ id = "/root/test.lua::\"namespace\"::\"test case description\"", type = "test" },
        function()
          return "root"
        end)
    end

    -- TODO Is this the only way to mock classes?
    package.loaded["neotest.client"] = function(_)
      return mocked_client
    end

    local items_to_render = items.neotest_as_items(mocked_state)

    -- TODO validate the entire tree
    assert.are_equal(#mocked_adapter_names, #items_to_render.children)

    for i, child in ipairs(items_to_render.children) do
      assert.truthy(child.name == mocked_adapter_names[i])
      -- the mocked child tree should have generated three generations
      -- TODO find a better programatic way to check this
      assert.truthy(child.children[1].children[1].children)
    end
  end)
end)

describe("render_items", function()
  it("should immediately return if state is already loading", function()
    local mocked_state = { loading = true }

    local neotest_as_items_mock = stub(items, "neotest_as_items")
    neotest_as_items_mock.returns({})

    items.render_items(mocked_state)

    assert.stub(neotest_as_items_mock).was_not.called()
    assert.truthy(mocked_state.loading)
  end)

  it("should call renderer with state and list of items", function()
    local mocked_items = {}
    local mocked_state = {}

    local renderer = require("neo-tree.ui.renderer")
    stub(renderer, "show_nodes")

    local neotest_as_items_mock = stub(items, "neotest_as_items")
    neotest_as_items_mock.returns(mocked_items)

    items.render_items(mocked_state)

    -- assert.stub(renderer.show_nodes).was.called_with({ mocked_items }, mocked_state)
    assert.False(mocked_state.loading)
    assert.stub(neotest_as_items_mock).was.called()
  end)
end)
