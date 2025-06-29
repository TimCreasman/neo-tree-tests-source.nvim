.SUFFIXES:

all: documentation lint luals test

# runs all the test files.
test:
	nvim --headless --noplugin -u ./scripts/mininit.lua \
		-c "lua require('plenary.test_harness').test_directory('tests/', {minimal_init='scripts/mininit.lua',sequential=true})"

# # runs all the test files on the nightly version, `bob` must be installed.
# test-nightly:
# 	bob use nightly
# 	make test
#
# # runs all the test files on the 0.8.3 version, `bob` must be installed.
# test-0.8.3:
# 	bob use 0.8.3
# 	make test

# installs `mini.nvim`, used for both the tests and documentation.
deps:
	@mkdir -p deps
	git clone --depth 1 https://github.com/echasnovski/mini.nvim deps/mini.nvim
	git clone --depth 1 https://github.com/nvim-neo-tree/neo-tree.nvim deps/neo-tree.nvim
	git clone --depth 1 https://github.com/nvim-neotest/neotest deps/neotest
	git clone --depth 1 https://github.com/nvim-lua/plenary.nvim deps/plenary.nvim

# installs deps before running tests, useful for the CI.
test-ci: deps test

# generates the documentation.
documentation:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua require('mini.doc').generate()" -c "qa!"

# installs deps before running the documentation generation, useful for the CI.
documentation-ci: deps documentation

# performs a lint check and fixes issue if possible, following the config in `stylua.toml`.
lint:
	stylua . -g '*.lua' -g '!deps/' -g '!nightly/'
	luacheck plugin/ lua/

luals-ci:
	rm -rf .ci/lua-ls/log
	lua-language-server --configpath .luarc.json --logpath .ci/lua-ls/log --check .
	[ -f .ci/lua-ls/log/check.json ] && { cat .ci/lua-ls/log/check.json 2>/dev/null; exit 1; } || true

luals:
	mkdir -p .ci/lua-ls
	curl -sL "https://github.com/LuaLS/lua-language-server/releases/download/3.7.4/lua-language-server-3.7.4-darwin-x64.tar.gz" | tar xzf - -C "${PWD}/.ci/lua-ls"
	make luals-ci

