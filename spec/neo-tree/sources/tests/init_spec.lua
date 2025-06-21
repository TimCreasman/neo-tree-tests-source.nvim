pcall(require, "luacov")

local tests_source = require("neo-tree.sources.tests")

describe("setup", function()
  it("should exist and execute with no defined arguments", function()
    assert.truthy(tests_source.setup)
  end)
end)

describe("navigate", function()
  before_each(function()
  end)

  it("should exist", function()
    assert.truthy(tests_source.navigate)
  end)
end)
