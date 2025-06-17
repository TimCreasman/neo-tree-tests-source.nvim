pcall(require, "luacov")

local spy = require('luassert.spy')
local mock = require('luassert.mock')
local stub = require('luassert.stub')
local tests_source = require("tests")

describe("Source setup", function()
  it("should exist and execute with no defined arguments", function()
    local ok = pcall(tests_source.setup)
    assert.truthy(ok)
  end)
end)

describe("Source navigate", function()
  before_each(function()
  end)

  it("should exist", function()
    assert.truthy(tests_source.navigate)
  end)

  it("should call renderer with list of items", function()
    local items = mock(require("tests.lib.items"), true)

    local mockedItems = {}
    items.neotest_as_items.returns(mockedItems)
    local mockedState = {}

    local renderer = require("neo-tree.ui.renderer")
    local neotest_as_items = items.neotest_as_items()

    stub(renderer, "show_nodes")
    stub(items, "show_nodes")

    tests_source.navigate(mockedState)
    assert.stub(renderer.show_nodes).was.called_with(mockedItems, mockedState)
  end)
end)
