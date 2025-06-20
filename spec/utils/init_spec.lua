pcall(require, "luacov")

local utils = require("utils")

describe("convert_path", function()
  it("should combine name at position", function()
    local expected = "This is a fancy string"
    local actual = utils.insert_after("This is a string", "a ", "fancy ")
    assert.equal(expected, actual)
  end)

  it("should handle paths", function()
    local expected = "/root.path/name/child/path.file"
    local actual = utils.insert_after("/root.path/child/path.file", "/root.path/", "name/")
    assert.equal(expected, actual)
  end)

  it("should handle strings with hyphens literally", function()
    local expected = "/home/tree/projects/neo-tree-tests-source.nvim/neotest-busted/spec/utils/init_spec.lua"
    local actual = utils.insert_after(
      "/home/tree/projects/neo-tree-tests-source.nvim/spec/utils/init_spec.lua",
      "/home/tree/projects/neo-tree-tests-source.nvim/", "neotest-busted/")
    assert.equal(expected, actual)
  end)
end)
