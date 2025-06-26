Done:
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

Next:

- [ ] Implement watching a test with 'w'

Later:

- [ ] Updated results up the tree when a child's status changes
- [ ] Implement calling test output with 'o'

- [ ] Initial call to Tests items lags (async?)
- [ ] How to run neotest apis (aka 'r' on a test, etc.) with neotest config?
- [ ] Adapt tests to async 
- [ ] Add plugin config for key mappings, by default use neotest/neo-tree mappings
- [ ] Implement runner animation
