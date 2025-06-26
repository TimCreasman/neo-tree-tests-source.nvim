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
    local expected = "/home/neo-tree-tests-source.nvim/neotest-busted/spec/utils/init_spec.lua"
    local actual = utils.insert_after(
      "/home/neo-tree-tests-source.nvim/spec/utils/init_spec.lua",
      "/home/neo-tree-tests-source.nvim/", "neotest-busted/")
    assert.equal(expected, actual)
  end)
end)

describe("get_path_from_adapter_id", function()
  it("should get path from adapter id", function()
    local argument = "neotest-plenary:/home/neo-tree-tests-source.nvim"
    local expected = "/home/neo-tree-tests-source.nvim"
    local actual = utils.get_path_from_adapter_id(argument)
    assert.equal(expected, actual)
  end)

  it("should return nil if there is no path", function()
    local argument = "neotest-plenary:"
    local expected = nil
    local actual = utils.get_path_from_adapter_id(argument)
    assert.equal(expected, actual)
  end)
end)
