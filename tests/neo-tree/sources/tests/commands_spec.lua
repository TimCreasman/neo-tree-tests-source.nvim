local commands = require("neo-tree.sources.tests.commands")
local stub = require("luassert.stub")
local mock = require("luassert.mock")
local match = require("luassert.match")

-- TODO Figure out why assert.stub is undefined
---@diagnostic disable: undefined-field

describe("jump_to_test", function()
    local mocked_cc = {}

    before_each(function()
        mocked_cc = mock(require("neo-tree.sources.common.commands"), true)
        stub(require("neo-tree.utils"), "get_appropriate_window")
        stub(vim.api, "nvim_win_set_cursor")
    end)

    it("should handle a nil or malformed node", function()
        local mocked_state = {
            tree = {
                get_node = function()
                    return nil
                end,
            },
        }
        commands.jump_to_test(mocked_state, true)
        assert.stub(mocked_cc.open).was.called(0)
    end)

    it("should call the common open command with a valid node", function()
        local mocked_state = {
            tree = {
                get_node = function()
                    return {
                        extra = {
                            real_path = "/root",
                        },
                    }
                end,
            },
        }
        commands.jump_to_test(mocked_state, true)
        assert.stub(mocked_cc.open).was.called(1)
    end)

    it("should position cursor to range if type is test or namespace", function()
        local mocked_range = { 2, 2 }
        local mocked_node = {
            type = "namespace",
            extra = {
                real_path = "/root",
                range = mocked_range,
            },
        }

        local mocked_state = {
            tree = {
                get_node = function()
                    return mocked_node
                end,
            },
        }

        commands.jump_to_test(mocked_state, true)

        assert
            .spy(vim.api.nvim_win_set_cursor).was
            .called_with(match.is_nil(), match.is_same({ mocked_range[1] + 1, mocked_range[2] }))
    end)
end)
