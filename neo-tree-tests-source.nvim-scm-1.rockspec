rockspec_format = '3.0'
-- TODO: Rename this file and set the package
package = "neo-tree-tests-source.nvim"
version = "scm-1"
source = {
    -- TODO: Update this URL
    url = "git+https://github.com/TimCreasman/neo-tree-tests"
}
dependencies = {
    "neo-tree.nvim"
}
test_dependencies = {
    "nlua"
}
build = {
    type = "builtin",
    copy_directories = {
        -- Add runtimepath directories, like
        -- 'plugin', 'ftplugin', 'doc'
        -- here. DO NOT add 'lua' or 'lib'.
    },
}
