# Done:
  - [x] Tree of tests showing for each adapter
  - [x] Show multiple roots
  - [x] Get neo-busted working
  - [x] Highlight and format different item types
  - [x] Selecting item should go to exact range place in testing suite
  - [x] Setup 'r' command to run the selected test tree
  - [x] Figure out how to tap into the neotest event pipeline?
      ~Neotest gives the same client to all its consumers but I have to create my own...~
      ~Maybe creating a faux consumer is the correct route?~ Faux-consumer ftw!
  - [x] Add test runner feedback (icons, status, etc.) 
  - [x] Show results up the tree
  - [x] Fix not collapsing files
  - [x] Run all tests with 'R' by default
  - [x] Switch all uses of the client to call the neotree consumer instead
  - [x] Fix run all tests only running one adapter and not both
  - [x] Implement watching a test with 'w'
  - [x] Implement calling test output with 'o'
  - [x] Fix nesting adapters not working until saving...?
  - [x] Do not eagerly require modules
      See: https://github.com/nvim-neorocks/nvim-best-practices?tab=readme-ov-file#is-your-plugin-not-filetype-specific-but-it-likely-wont-be-needed-every-single-time-a-user-opens-a-neovim-session
  - [x] Add plugin config for key mappings, by default use neotest/neo-tree mappings
  - [x] How to run neotest apis (aka 'r' on a test, etc.) with neotest config?
  - [x] Adapt tests to async 
  - [x] Implement stopping running of tests through 'u'

# In Progress:

  - [ ] Implement marking test through 'm' and clear marking/ run marked/ debug marked
  - [-] Look through all TODOs and cleanup
  - [-] Implement debug/dap test through 'd' - I need a dap installed to fully test it 
  - [ ] Add vimdoc via README convertion to vimdoc (panvimdoc ga)

# Later:

## Necessity:
  - [ ] Create README with installation instructions
  - [ ] Add github ci

## Feature completeness:

  - [ ] Add ability to pass custom args to neotest runner

## Nice-to-haves:
  - [ ] Add common mocks to module
  - [ ] Updated results up the tree when a child's status changes
  - [ ] Implement expand on fail
  - [ ] Implement runner animation

## Backlog:
  META_TODO: Confirm this
  - [ ] Initial call to Tests items lags (async?)
