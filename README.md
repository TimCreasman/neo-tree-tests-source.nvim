# Neo-tree-tests-source

# Introduction

This plugin serves to bridge the gap between [neotest](https://github.com/nvim-neotest/neotest) and [neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim) by providing a test tree source for neo-tree.

![Screenshot 2025-06-28 152804](https://github.com/user-attachments/assets/fdc21ce8-42f1-4b8e-a3ed-c38ad58a1690)

This is similar to the summary consumer that neotest provides, but adapted for the look-and-feel of neo-tree.

# Usage
This plugin needs to be added to both your neo-tree and neotest configs:

<details>
<summary>Lazy</summary>

#### Neo-tree:
```lua
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            -- other Dependencies --
            "TimCreasman/neo-tree-tests-source.nvim" -- This plugin
        },
        config = function()
            require("neo-tree").setup({
                sources = {
                    "filesystem",
                    "buffers",
                    "git_status",
                    "tests" -- Add the 'tests' source here
                },
                source_selector = {
                    winbar = true,
                    sources = {
                        { source = "filesystem" },
                        { source = "buffers" },
                        { source = "git_status" },
                        { source = "tests" }, -- I recommend adding the source to your selector
                    },
                },
                -- Here you can specify specific configurations for the test source. 
                -- Use :h neo-tree-test-source to see default configurations.
                tests = {
                    window = {
                        mappings = {
                            ['p'] = "run_tests"
                        }
                    }
                },
                window = {
                    mappings = {
                        ['E'] = function() vim.api.nvim_exec2('Neotree focus filesystem left', { output = true }) end,
                        ['b'] = function() vim.api.nvim_exec2('Neotree focus buffers left', { output = true }) end,
                        ['g'] = function() vim.api.nvim_exec2('Neotree focus git_status left', { output = true }) end,
                        ['t'] = function() vim.api.nvim_exec2('Neotree focus tests left', { output = true }) end, -- My personal shortcut to the tests source
                    }
                }
            })
        -- ... --
    }
```

#### Neotest:
```lua
    {
        "nvim-neotest/neotest",
        dependencies = {
            -- other dependencies --
            "TimCreasman/neo-tree-tests-source.nvim" -- This plugin
        },
        config = function()
            local neotest = require("neotest")
            neotest.setup({
                --  your config  --
                consumers = {
                    neotree = require("neotest.consumers.neotree") -- Specify our plugin as a test result consumer here:
                }
            })
        -- ... ---
    }
```
</details>

If you want to provide configuration for other plugin managers, please create a PR.

# Motivation

"I like the summary consumer neotest provides, but I wish it could exist within my neo-tree window"

This plugin was mainly developed as a way for me to learn how neovim plugins work and to brush up on my lua.

# Features 

* Provides a filesystem-like interface for tests
* Navigates just like any source in neo-tree
* Run tests `'r'`
* Stop tests `'u'`
* Debug tests `'d'`
* Watch tests `'w'`
* See test output `'o'`
* Configurable mappings
* See test statuses
* Navigate directly to individual namespaces and tests
* Supports multiple test adapters

## Roadmap

The end goal for this plugin is to be feature-complete with the summary consumer provided by neotest.
For this, the following still needs to be implemented:
* Marking tests with `'m'`
* Running, stopping, debugging marked tests 
* Setting targets
* Viewing shortened output with `'O'`

# Configuration

Configuration is handled completely in the neo-tree plugin setup. The one exception being the status icons, which are pulled from the neotest configuration.

<details>
<summary>Default configuration</summary>

Taken and adopted from the neo-tree defaults

```lua
local config = {
  auto_preview = {                   -- May also be set to `true` or `false`
    enabled = false,                 -- Whether to automatically enable preview mode
    preview_config = {},             -- Config table to pass to auto preview (for example `{ use_float = true }`)
    event = "neo_tree_buffer_enter", -- The event to enable auto preview upon (for example `"neo_tree_window_after_open"`)
  },
  bind_to_cwd = true,
  diag_sort_function = "severity", -- "severity" means diagnostic items are sorted by severity in addition to their positions
  -- "position" means diagnostic items are sorted strictly by their positions
  -- May also be a function
  follow_current_file = {             -- May also be set to `true` or `false`
    enabled = true,                   -- This will find and focus the file in the active buffer every time
    always_focus_file = false,        -- Focus the followed file, even when focus is currently on a diagnostic item belonging to that file
    expand_followed = true,           -- Ensure the node of the followed file is expanded
    leave_dirs_open = false,          -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
    leave_files_open = false,         -- `false` closes auto expanded files, such as with `:Neotree reveal`
  },
  group_dirs_and_files = true,        -- when true, empty folders and files will be grouped together
  group_empty_dirs = true,            -- when true, empty directories will be grouped together
  show_unloaded = true,               -- show diagnostics from unloaded buffers
  refresh = {
    delay = 100,                      -- Time (in ms) to wait before updating diagnostics. Might resolve some issues with Neovim hanging.
    event = "vim_diagnostic_changed", -- Event to use for updating diagnostics (for example `"neo_tree_buffer_enter"`)
    -- Set to `false` or `"none"` to disable automatic refreshing
    max_items = 10000,                -- The maximum number of diagnostic items to attempt processing
    -- Set to `false` for no maximum
  },
  renderers = {
    directory = {
      { "indent" },
      { "icon" },
      { "current_filter" },
      {
        "container",
        content = {
          { "name",        zindex = 10 },
          {
            "symlink_target",
            zindex = 10,
            highlight = "NeoTreeSymbolicLinkTarget",
          },
          { "clipboard",   zindex = 10 },
          { "diagnostics", errors_only = true, zindex = 20, align = "right", hide_when_expanded = true },
        },
      },
    },
    file = {
      { "indent" },
      { "icon" },
      {
        "container",
        content = {
          {
            "name",
            zindex = 10
          },
          {
            "symlink_target",
            zindex = 10,
            highlight = "NeoTreeSymbolicLinkTarget",
          },
          { "clipboard", zindex = 10 },
        },
      },
    },
    namespace = {
      { "indent" },
      { "icon" },
      { "name" },
    },
    test = {
      { "indent" },
      { "icon" },
      { "name" },
    }
  },
  window = {
    mappings = {
      ["r"] = "run_tests",
      ["u"] = "stop_tests",
      ["d"] = "debug_tests",
      ["R"] = "run_all_tests",
      ["w"] = "watch_tests",
      ["o"] = "show_test_output",
      -- While not necessary, this greatly improves the UX since namespaces/tests are nested
      ["<cr>"] = { "open", config = { expand_nested_files = true } }, -- expand nested file takes precedence
    },
  },
}
```
</details>
