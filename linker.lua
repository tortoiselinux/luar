#!/usr/bin/env lua

local t = require("tlib")
local l = require("linkerlib")

function help()
   local helpmsg=
[[

 🐢 Tortoise Lua Linker

 How To use:
 linker -o filename lua_script module1 module2 module3 ...
 linker lua_script module1 module2 module3 ...

 NOTE: When you don't provide a filename, the first
       argument is used
 
 Options:
 h | help : prints help message
	   
 NOTE: (-) or (--) are optional

 Hey, this script is part of the lua packer!
 To see how you can make embedded scripts
 see: https://github.com/tortoiselinux/packer
 
]]
print(helpmsg)	
end
local MAGIC_MARK = "--[[LUA_SCRIPT_START]]"
local linked_script = MAGIC_MARK .. "\n"

-- filename = filename:match("^(.*)%.lua$")
if t.verify_args(arg, {'h', '-h', 'help', '--help'}) then
   help()
else
   if t.verify_args(arg, {'o', '-o', 'output', '--output'}) then
      local filename = arg[2]
      local script = arg[3]
       
      for i in ipairs(arg) do
	 if i > 3 then
	    print("linking the module [" .. i .. "]: " .. arg[i])
	    linked_script = linked_script .. l.link(script, arg[i])
	 end
      end
      local main_script = t.read_file(script)
      main_script = main_script:gsub('local%s+(%w+)%s*=%s*require%s*%("([^"]+)"%)', "local %1 = %2")
      linked_script = linked_script .. "\n" .. main_script
      t.write_file(filename, "w", linked_script)

      print("Generated linked file: ".. filename)
   else
      script = arg[1]
      filename = script:match("([^/\\]+)%.lua$")
      for i in ipairs(arg) do
	 if i > 1 then
	    print("linking the module [" .. i .. "]: " .. arg[i])
	    linked_script = linked_script .. l.link(script, arg[i])
	 end
      end
      local main_script = t.read_file(script)
      main_script = main_script:gsub('local%s+(%w+)%s*=%s*require%s*%("([^"]+)"%)', "local %1 = %2")
      linked_script = linked_script .. "\n" .. main_script
      t.write_file(filename, "w", linked_script)
      print("Generated linked file: " .. filename)
   end
end
