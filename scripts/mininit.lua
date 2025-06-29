-- -- Need the absolute path as when doing the testing we will issue things like `tcd` to change directory
-- -- to where our temporary filesystem lives
-- local root_dir = vim.fn.fnamemodify(vim.trim(vim.fn.system("git rev-parse --show-toplevel")), ":p")
-- --
-- package.path = string.format("%s;%s?.lua;%s?/init.lua", package.path, root_dir, root_dir)
-- --
-- vim.opt.packpath:prepend(root_dir .. "deps")
--
-- vim.opt.rtp = {
--     root_dir,
--     vim.env.VIMRUNTIME,
-- }
-- --
--
-- -- Add current directory to 'runtimepath' to be able to use 'lua' files
-- -- vim.cmd([[let &rtp.=','.getcwd()]])
--
-- -- Set up 'mini.test' and 'mini.doc' only when calling headless Neovim (like with `make test` or `make documentation`)
-- if #vim.api.nvim_list_uis() == 0 then
--     -- vim.opt.packpath:prepend(root_dir .. "deps")
--
--     vim.cmd([[
--       filetype on
--       packadd plenary.nvim
--       " packadd nui.nvim
--       " packadd nvim-web-devicons
--     ]])
--
--     vim.opt.swapfile = false
--     -- Add 'mini.nvim' to 'runtimepath' to be able to use 'mini.test'
--     -- Assumed that 'mini.nvim' is stored in 'deps/mini.nvim'
--     -- vim.cmd("set rtp+=deps/mini.nvim")
--
--     -- -- Set up 'mini.test'
--     -- require("").setup()
--
--     -- Set up 'mini.doc'
--     require("mini.doc").setup()
-- end
--
-- Need the absolute path as when doing the testing we will issue things like `tcd` to change directory
-- to where our temporary filesystem lives
--
-- Add current directory to 'runtimepath' to be able to use 'lua' files
vim.cmd("set rtp+=deps/plenary.nvim")

vim.cmd([[let &rtp.=','.getcwd()]])

vim.cmd([[
  runtime plugin/neo-tree-tests-source.lua
]])

-- vim.cmd([[
--   filetype on
--   packadd plenary.nvim
-- ]])

-- vim.opt.swapfile = false

-- vim.cmd([[
--   runtime plugin/neo-tree.lua
-- ]])

-- For debugging
