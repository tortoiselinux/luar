#!/usr/bin/env lua

local t = require("tlib")
-- local luar = "build/runtime/luar"
local function help()
   local help_msg = [[

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
print(help_msg)
end

local function exit(code)
	os.exit(code)
end

local luardir = "/usr/local/share/packer"
local luar_unix = luardir .. "/luar"
local luar_win = luardir .. "/luar.exe"
local script
local filename
local namespace = "packed_"

local function concat(bin_path, script)
   local bin = assert(io.open(bin_path, "ab"))
   local txt = assert(io.open(script, "rb"))
   print("Appending: " .. script .. " to the binary enviroment: " .. bin_path)
   local content = txt:read("*a")
   bin:write("\n--[[LUA_SCRIPT_START]]\n")
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
   if package.config:sub(1, 1) == "/" then
      os.execute("chmod +x " .. dest)
   end
end

local function pack_to_linux(script, filename)
   filename = filename or script
   local output_linux = "./" .. script:gsub("%.lua$", "")
   copy_stub(luar_unix, output_linux)
   concat(output_linux, script)
   print("✅ Executável Linux criado: " .. namespace .. filename:gsub("%.lua$", ""))
   return output_linux
end

local function pack_to_windows(script, filename)
   filename = filename or script
   local output_windows = "./" .. script:gsub("%.lua$", "") .. ".exe"
   copy_stub(luar_win, output_windows)
   concat(output_windows, script)
   print("✅ Executável Windows criado: " .. namespace .. filename:gsub("%.lua$", "") .. ".exe")
   return output_windows
end


if #arg == 0 then
   help()
   exit(1)
end

if t.verify_args(arg, { "h", "-h", "help", "--help" }) then
   help()
   exit(0)
end

if t.verify_args(arg, { "linux" }) then
   if t.verify_args(arg, { "o", "-o", "output", "--output" }) then
      filename = namespace .. arg[3]
      script = arg[4]
      local packed_script = pack_to_linux(script, filename)
      os.rename(packed_script, filename:gsub("%.lua$", ""))
      exit(0)
   else
      script = arg[2]
      local packed_script = pack_to_linux(script, namespace .. script)
      os.rename(packed_script, script:gsub("%.lua$", ""))
      exit(0)
   end
end

if t.verify_args(arg, { "windows" }) then
   if t.verify_args(arg, { "o", "-o", "output", "--output" }) then
      filename = arg[3] .. ".exe"
      script = arg[4]
      local packed_script = pack_to_windows(script, filename)
      os.rename(packed_script, filename:gsub("%.lua$", ""))
      exit(0)
   else
      script = namespace .. arg[2]
      local packed_script = pack_to_windows(script, namespace .. script)
      os.rename(packed_script, script:gsub("%.lua$", "") .. ".exe")
      exit(0)
   end
end

if t.verify_args(arg, { "o", "-o", "output", "--output" }) then
   filename = namespace .. arg[2]
   script = arg[3]
   local packed_script_linux = pack_to_linux(script)
   local packed_script_windows = pack_to_windows(script)
   os.rename(packed_script_linux, filename:gsub("%.lua$", ""))
   os.rename(packed_script_windows, filename:gsub("%.lua$", "") .. ".exe")
else
   script = arg[1]
   filename = namespace .. script:match("([^/\\]+)%.lua$")
   local packed_script_linux = pack_to_linux(script)
   local packed_script_windows = pack_to_windows(script)
   os.rename(packed_script_linux, filename)
   os.rename(packed_script_windows, filename .. ".exe")
end