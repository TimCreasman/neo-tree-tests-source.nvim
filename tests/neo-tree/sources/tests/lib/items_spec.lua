local items = require("neo-tree.sources.tests.lib.items")
local default_config = require("neo-tree.sources.tests.defaults")
local stub = require("luassert.stub")
local consumer_init = require("neotest.consumers.neotree")
local a = require("nio").tests

describe("neotest_as_items", function()
    local mocked_state = {}
    local mocked_adapter_names = {}

    before_each(function()
        local neotest_tree = require("neotest.types.tree")
        local neotest_client = require("neotest.client")
        stub(require("neo-tree.sources.common.file-items"), "advanced_sort")

        local mocked_client = neotest_client()
        mocked_adapter_names = { "adapter_1", "adapter_2" }
        consumer_init(mocked_client)

        mocked_client.get_adapters = function()
            return mocked_adapter_names
        end

        -- Is this the only way to mock classes?
        package.loaded["neotest.client"] = function(_)
            return mocked_client
        end

        -- Mocking this will create three children under each adapter, one for the test.lua, one for the namespace, and another for the test case itself
        mocked_client.get_position = function()
            return neotest_tree.from_list(
                { id = '/root/test.lua::"namespace"::"test case description"', type = "test" },
                function()
                    return "root"
                end
            )
        end

        mocked_state = {
            path = "/root",
            config = default_config,
        }
    end)

    a.it("should return a table", function()
        assert.is.True(type(items.neotest_as_items(mocked_state)) == "table")
    end)

    a.it("should correctly format a basic testing tree", function()
        local items_to_render = items.neotest_as_items(mocked_state)

        assert.are_equal(#mocked_adapter_names, #items_to_render.children)

        for i, child in ipairs(items_to_render.children) do
            assert.truthy(child.name == mocked_adapter_names[i])
            -- the mocked child tree should have generated three generations
            assert.truthy(child.children[1].children[1].children)
        end
    end)

    a.it("should contain all adapter names in the root item", function()
        local items_to_render = items.neotest_as_items(mocked_state)
        assert.same(items_to_render.extra.adapter_ids, mocked_adapter_names)
    end)
end)

describe("render_items", function()
    a.it("should immediately return if state is already loading", function()
        local mocked_state = { loading = true }

        local neotest_as_items_mock = stub(items, "neotest_as_items")
        neotest_as_items_mock.returns({})

        items.render_items(mocked_state)

        assert.stub(neotest_as_items_mock).was_not.called()
        assert.truthy(mocked_state.loading)
    end)

    a.it("should call renderer with state and list of items", function()
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
