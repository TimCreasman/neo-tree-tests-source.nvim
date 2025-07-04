-- Set up only when calling headless Neovim (like with `make test` or `make documentation`)
if #vim.api.nvim_list_uis() == 0 then
    -- Add 'mini.nvim' to 'runtimepath' to be able to use 'mini.test'
    -- Assumed that 'mini.nvim' is stored in 'deps/mini.nvim'
    vim.cmd("set rtp+=deps/mini.nvim")
    vim.cmd("set rtp+=deps/neo-tree.nvim")
    vim.cmd("set rtp+=deps/neotest")
    vim.cmd("set rtp+=deps/nui.nvim")
    vim.cmd("set rtp+=deps/nvim-nio")
    -- Add 'plenary.nvim' to 'runtimepath' to be able to run tests
    vim.cmd("set rtp+=deps/plenary.nvim")

    -- Set up 'mini.doc'
    require("mini.doc").setup()


    vim.cmd([[let &rtp.=','.getcwd()]])

    vim.cmd([[
        runtime plugin/neo-tree-tests-source.lua
    ]])
end
