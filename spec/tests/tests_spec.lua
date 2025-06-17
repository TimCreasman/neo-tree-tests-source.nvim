pcall(require, "luacov")

local spy = require('luassert.spy')
local mock = require('luassert.mock')
local stub = require('luassert.stub')
local tests_source = require("tests")

describe("setup", function()
  it("should exist and execute with no defined arguments", function()
    local ok = pcall(tests_source.setup)
    assert.truthy(ok)
  end)
end)

describe("navigate", function()
  before_each(function()
  end)

  it("should exist", function()
    assert.truthy(tests_source.navigate)
  end)
end)
