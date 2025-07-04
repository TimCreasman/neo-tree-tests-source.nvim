local mock = require("luassert.mock")
local components = require("neo-tree.sources.tests.components")

-- TODO Figure out why assert.stub is undefined
---@diagnostic disable: undefined-field
---@diagnostic disable: missing-fields

describe("icon", function()
    require("neotest").setup({})

    local mocked_cc = mock(require("neo-tree.sources.common.components"), true)
    local mocked_results = mock(require("neotest.consumers.neotree"), true)
    local mocked_test_watcher = mock(require("neotest").watch, true)

    local icon_text = "Folder"
    local passed_icon = require("neotest.config").icons["passed"]
    local failed_icon = require("neotest.config").icons["failed"]
    local watched_icon = require("neotest.config").icons["watching"]

    before_each(function()
        mocked_cc.icon = function()
            return {
                text = icon_text,
                highlights = "Highlights",
            }
        end

        mocked_results.get_results = function()
            return {
                status = "passed",
            }
        end

        mocked_test_watcher.is_watching = function(_)
            return false
        end
    end)

    it("should append status icons to existing neo-tree icons", function()
        local icon = components.icon({}, { type = "directory" }, {})

        assert.truthy(string.find(icon.text, "Folder", nil, true))
        assert.is_same(icon_text .. passed_icon, icon.text)
    end)

    it("should append watcher icon to existing neo-tree icons", function()
        mocked_test_watcher.is_watching = function(_)
            return true
        end
        local icon = components.icon({}, { type = "directory" }, {})

        assert.truthy(string.find(icon.text, "Folder", nil, true))
        assert.is_same(icon_text .. watched_icon, icon.text)
    end)

    it("should display only status icons if node is a namespace or test", function()
        mocked_results.get_results = function()
            return {
                status = "failed",
            }
        end

        local icon = components.icon({}, { type = "test" }, {})

        assert.is_same(failed_icon, icon.text)

        mocked_test_watcher.is_watching = function(_)
            return true
        end

        icon = components.icon({}, { type = "namespace" }, {})

        assert.is_same(watched_icon, icon.text)
    end)
end)
