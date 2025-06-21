Things I Learned

* Lua require modules are cached and have to be explicitly reloaded if you want them to re-run (via package.preload)
* Since lua modules rely on project directories, renaming these directories can lead to unforseen problems
    * I had updated the project structure, but the plugins were still pointing to an old cached version of the project
    * This took awhile to figure out until I had the neo-tree print out where it was loading the module from (searchpath)
    * You can also see all loaded packages used in the lua runtime (nvim runtime)
