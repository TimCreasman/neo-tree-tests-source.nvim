local a = require("nio.tests")
local Neotree = require("neotest.consumers.neotree.neotree")
local mock = require("luassert.mock")
local match = require("luassert.match")

describe("Neotree Consumer", function()
  require("neotest").setup({})
  local mocked_client = require("neotest.client")()
  local mocked_adapter_names = { "adapter_1:/path/to/tests", "adapter_2:/path/to/other/tests" }

  local neotree_consumer = Neotree(mocked_client)
  local mocked_test_runner = mock(require("neotest").run, true)
  local mocked_test_watcher = mock(require("neotest").watch, true)

  describe("run_tests", function()
    a.before_each(function()
      mocked_client.get_adapters = function()
        return mocked_adapter_names
      end

      mocked_test_runner.run:clear()
    end)

    a.it("should call the neotest runner for all adapters if no node is supplied", function()
      neotree_consumer:run_tests()
      assert.stub(mocked_test_runner.run).was_called_with(match.is_same(
        { "/path/to/tests", adapter = mocked_adapter_names[1] }
      ))
      assert.stub(mocked_test_runner.run).was_called_with(match.is_same(
        { "/path/to/other/tests", adapter = mocked_adapter_names[2] }
      ))
    end)

    a.it("should never call run if no valid adapters exist", function()
      mocked_client.get_adapters = function()
        return {}
      end
      neotree_consumer:run_tests()
      assert.stub(mocked_test_runner.run).was.not_called()
    end)

    a.it("should run node's tests if a node is supplied", function()
      ---@type neotree-neotest.Item
      local mocked_node = {
        extra = {
          position_id = 'home/path::"namespace"::"test_name"',
          real_path = "home/path",
          adapter_id = "adapter_1"
        }
      }
      neotree_consumer:run_tests(mocked_node)
      assert.stub(mocked_test_runner.run).was.called(1)
      assert.stub(mocked_test_runner.run).was_called_with(match.is_same(
        { mocked_node.extra.position_id, adapter = mocked_node.extra.adapter_id }
      ))
    end)

    a.it("should do nothing if the node has no adapter_id or position_id", function()
      ---@type neotree-neotest.Item
      local mocked_node = {
        extra = {
          position_id = 'home/path::"namespace"::"test_name"',
          real_path = "home/path",
        }
      }
      neotree_consumer:run_tests(mocked_node)
      assert.stub(mocked_test_runner.run).was.not_called()
    end)
  end)

  describe("watch_tests", function()
    a.before_each(function()
      mocked_client.get_adapters = function()
        return mocked_adapter_names
      end
      mocked_test_watcher.toggle:clear()
    end)

    a.it("should call the neotest runner for all adapters if no node is supplied", function()
      neotree_consumer:watch()
      assert.stub(mocked_test_watcher.toggle).was_called_with(match.is_same(
        { "/path/to/tests", adapter = mocked_adapter_names[1] }
      ))
      assert.stub(mocked_test_watcher.toggle).was_called_with(match.is_same(
        { "/path/to/other/tests", adapter = mocked_adapter_names[2] }
      ))
    end)

    a.it("should never call run if no valid adapters exist", function()
      mocked_client.get_adapters = function()
        return {}
      end
      neotree_consumer:watch()
      assert.stub(mocked_test_watcher.watch).was.not_called()
    end)

    a.it("should run node's tests if a node is supplied", function()
      ---@type neotree-neotest.Item
      local mocked_node = {
        extra = {
          position_id = 'home/path::"namespace"::"test_name"',
          real_path = "home/path",
          adapter_id = "adapter_1"
        }
      }
      neotree_consumer:watch(mocked_node)
      assert.stub(mocked_test_watcher.toggle).was.called(1)
      assert.stub(mocked_test_watcher.toggle).was_called_with(match.is_same(
        { mocked_node.extra.position_id, adapter = mocked_node.extra.adapter_id }
      ))
    end)

    a.it("should do nothing if the node has no adapter_id or position_id", function()
      ---@type neotree-neotest.Item
      local mocked_node = {
        extra = {
          position_id = 'home/path::"namespace"::"test_name"',
          real_path = "home/path",
        }
      }
      neotree_consumer:watch(mocked_node)
      assert.stub(mocked_test_watcher.toggle).was.not_called()
    end)
  end)
end)
