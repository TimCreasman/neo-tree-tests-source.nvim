.SUFFIXES:

all: documentation lint luals test

# runs all the test files.
test:
	nvim --headless --noplugin -u ./scripts/mininit.lua \
		-c "lua require('plenary.test_harness').test_directory('tests/', {minimal_init='scripts/mininit.lua',sequential=true})"

# Dependencies:

DEPS := ${CURDIR}/deps

$(DEPS):
	mkdir -p "$(DEPS)"

$(DEPS)/mini.nvim: $(DEPS)
	@test -d "$(DEPS)/mini.nvim" || git clone https://github.com/echasnovski/mini.nvim "$(DEPS)/mini.nvim"

$(DEPS)/neo-tree.nvim: $(DEPS)
	@test -d "$(DEPS)/neo-tree.nvim" || git clone https://github.com/nvim-neo-tree/neo-tree.nvim "$(DEPS)/neo-tree.nvim"

$(DEPS)/nui.nvim: $(DEPS)
	@test -d "$(DEPS)/neotest" || git clone https://github.com/nvim-neotest/neotest "$(DEPS)/neotest"

$(DEPS)/plenary.nvim: $(DEPS)
	@test -d "$(DEPS)/plenary.nvim" || git clone https://github.com/nvim-lua/plenary.nvim "$(DEPS)/plenary.nvim"

$(DEPS)/nvim-nio: $(DEPS)
	@test -d "$(DEPS)/nvim-nio" || git clone https://github.com/nvim-neotest/nvim-nio "$(DEPS)/nvim-nio"

deps: $(DEPS)/mini.nvim $(DEPS)/neo-tree.nvim $(DEPS)/nui.nvim $(DEPS)/plenary.nvim $(DEPS)/nvim-nio
	@echo "[setup] environment ready"

# installs deps before running tests, useful for the CI.
test-ci: deps test

# generates the documentation.
documentation:
	nvim --headless --noplugin -u ./scripts/mininit.lua -c "lua require('mini.doc').generate()" -c "qa!"

# installs deps before running the documentation generation, useful for the CI.
documentation-ci: deps documentation

# performs a lint check and fixes issue if possible, following the config in `stylua.toml`.
lint:
	stylua . -g '*.lua' -g '!deps/' -g '!nightly/'
	luacheck plugin/ lua/

CONFIGURATION = ${CURDIR}/.luarc.json
luals-ci:
	VIMRUNTIME="`nvim --clean --headless --cmd 'lua io.write(vim.env.VIMRUNTIME)' --cmd 'quit'`" lua-language-server --configpath=$(CONFIGURATION) --check=.

luals:
	mkdir -p .ci/lua-ls
	curl -sL "https://github.com/LuaLS/lua-language-server/releases/download/3.7.4/lua-language-server-3.7.4-darwin-x64.tar.gz" | tar xzf - -C "${PWD}/.ci/lua-ls"
	make luals-ci

