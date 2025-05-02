#!/usr/bin/env lua

local t = require("tlib")

local function help()
   local helpmsg = [[

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

local function exit(code)
	os.exit(code)
end

local MAGIC_MARK = "-- LUA_SCRIPT_START"
local linked_script = MAGIC_MARK .. "\n"
local filename, script
local namespace = "linked_"

local function extract_shebang(content)
   local first_line = content:match("^(#![^\n]*)\n")
   if first_line then
      content = content:gsub("^#![^\n]*\n", "")
      return first_line, content
   end
   return nil, content
end

local function link(lua_module)
	local content = "\n" .. "--modid:" .. lua_module .. "\n"
	local mod = t.read_file(lua_module)
	mod = mod:gsub("^#![^\n]*\n", "")
   	mod = mod:gsub("[\r\n]*%s*return%s+[%w_]+%s*$", "")
   	content = content .. mod .. "\n--modend:" .. lua_module .. "\n"
   	return content
end

-- filename = filename:match("^(.*)%.lua$")
if #arg == 0 then
   help()
   exit(1)
end
if t.verify_args(arg, { "h", "-h", "help", "--help" }) then
	help()
	exit(0)
end
if t.verify_args(arg, { "o", "-o", "output", "--output" }) then
	filename = namespace .. arg[2]
	script = arg[3]
	for i in ipairs(arg) do
		if i > 3 then
			print("linking the module [" .. i .. "]: " .. arg[i])
			linked_script = linked_script .. link(arg[i])
		end
	end
	local main = t.read_file(script)
	main = main
		:gsub('local%s+(%w+)%s*=%s*require%s*%("([^"]+)"%)', "local %1 = %2")
		:gsub("^#![^\n]*\n", "")
	linked_script = linked_script .. "\n" .. main
	t.write_file(filename, "w", linked_script)
	print("Generated linked file: " .. filename)
	exit(0)
end

script = arg[1]
filename = namespace .. script:match("([^/\\]+)%.lua$")
for i in ipairs(arg) do
	if i > 1 then
		print("linking the module [" .. i .. "]: " .. arg[i])
		linked_script = linked_script .. link(arg[i])
	end
end
local main = t.read_file(script)
main = main
	:gsub('local%s+(%w+)%s*=%s*require%s*%("([^"]+)"%)', "local %1 = %2")
	:gsub("^#![^\n]*\n", "")

linked_script = linked_script .. "\n" .. main
t.write_file(filename, "w", linked_script)
print("Generated linked file: " .. filename)
exit(0)
