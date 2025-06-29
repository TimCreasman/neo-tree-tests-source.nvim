rockspec_format = '3.0'
package = "neo-tree-tests-source.nvim"
version = "scm-1"
source = {
    url = "git+https://github.com/TimCreasman/neo-tree-tests-source.nvim"
}
dependencies = {
    "neo-tree.nvim",
    "neotest"
}
test_dependencies = {
    "nlua"
}
build = {
    type = "builtin",
    copy_directories = {
        'doc'
    },
}
