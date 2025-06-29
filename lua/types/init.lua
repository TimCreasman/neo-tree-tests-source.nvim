---@meta

---@class neotree-neotest.Node.Extra
---@field real_path string
---@field position_id string
---@field range? integer[]
---@field adapter_ids? string[]

---@class neotree-neotest.Node : NuiTree.Node
---@field extra neotree-neotest.Node.Extra

---Nil allowed version of neotest.RunArgs
---@class neotree-neotest.RunArgs : neotest.RunArgs
---@field tree? neotest.Tree
---@field extra_args? string[]
---@field strategy? string

---@class neotree-neotest.FileItem.Directory : neotree.FileItem
---@field extra neotree-neotest.Node.Extra?
