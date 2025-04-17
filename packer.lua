#!/usr/bin/env lua
--[[LUA_SCRIPT_START]]

local t = require("tlib")
local luar = "build/runtime/luar"
local filename
function help()
   local helpmsg=
[[

 🐢 Tortoise Lua Packer

 How To use:
 packer script
 packer <platform> script
 packer -o filename script
 packer <platform> -o filename script

 Supported platforms: Linux, Windows

 NOTE: When you don't provide a filename, the first
       argument is used

 Options:
 h | help : prints help message
 o | output : define the executable filename

 NOTE: (-) or (--) are optional

 Hey, this script is part of the lua packer!
 To see how you can make embedded scripts
 see: https://github.com/tortoiselinux/packer 
]]
print(helpmsg)
end

local function concat(bin_path, script)
   local bin = assert(io.open(bin_path, "ab"))
   local txt = assert(io.open(script, "rb"))
   print("Appending: " .. script .. " to the binary enviroment: " .. bin_path)
   local content = txt:read("*a")
   bin:write(content)
   txt:close()
   bin:close()
end

local function copy_stub(src, dest)
   local input = assert(io.open(src, "rb"))
   local output = assert(io.open(dest, "wb"))
   output:write(input:read("*a"))
   input:close()
   output:close()
   if package.config:sub(1,1) == '/' then
      os.execute("chmod +x " .. dest)
   end
end

function pack_to_linux(script, filename)
   filename = filename or script
   output_linux = "./" .. script:gsub("%.lua$", "")
   copy_stub(luar, output_linux)
   concat(output_linux, script)
   print("✅ Executável Linux criado: " .. filename:gsub("%.lua$", ""))
   return output_linux
end

function pack_to_windows(script, filename)
   filename = filename or script
   output_windows = "./" .. script:gsub("%.lua$", "") .. ".exe"
   copy_stub(luar .. ".exe", output_windows)
   concat(output_windows, script)
   print("✅ Executável Windows criado: " .. filename:gsub("%.lua$", "") .. ".exe")
   return output_windows
end

if t.verify_args(arg, {'h', '-h', 'help', '--help'}) then
   help()
elseif t.verify_args(arg, {"linux"}) then
   if t.verify_args(arg,  {'o', '-o', 'output', '--output'}) then
      filename = arg[3]
      script = arg[4]
      packed_script = pack_to_linux(script, filename)
      os.rename(packed_script, filename)
   else
      script = arg[2]
      pack_to_linux(script)
   end
elseif t.verify_args(arg, {"windows"}) then
   if t.verify_args(arg,  {'o', '-o', 'output', '--output'}) then
      filename = arg[3] .. ".exe"
      script = arg[4]
      packed_script = pack_to_windows(script, filename)
      os.rename(packed_script, filename)
   else
      script = arg[2]
      pack_to_windows(script)
   end
else
   if t.verify_args(arg,  {'o', '-o', 'output', '--output'}) then
      filename = arg[2]
      script = arg[3]
      packed_script_linux = pack_to_linux(script)
      packed_script_windows = pack_to_windows(script)
      os.rename(packed_script_linux, filename)
      os.rename(packed_script_windows, filename .. ".exe")
   else
      script = arg[1]
      pack_to_linux(script)
      pack_to_windows(script)
   end
end
