hs.hotkey.bind({"ctrl", "shift", "cmd", "alt"}, "R", function()
   hs.execute(hs.fs.pathToAbsolute("~/tools/scripts/focus-devtools.sh"), true)
 end)