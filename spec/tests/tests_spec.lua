pcall(require, "luacov")

local spy = require('luassert.spy')
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

  it("should exist and execute with no defined arguments", function()
    -- local ok = pcall(tests_source.navigate)
    local spy = spy.on(require("neo-tree.ui.renderer"), "show_nodes")
    renderer.show_nodes.is()
    tests_source.navigate()
    -- assert.truthy(ok)
  end)
end)
