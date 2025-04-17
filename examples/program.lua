local tlib = require("tlib")
local m1 = require("module1")
local m2 = require("module2")
local m3 = require("module3")

function help()
local helpmsg=[[
 🐢 Hey this script is running in embedded mode!
 Options:

 h | help
 a | args
 m | modules

 NOTE: (-) or (--) are optional

 To see how you can make embedded scripts like
 this, see: https://github.com/tortoiselinux/packer
]]
print(helpmsg)
end

function print_args()
   for i, v in ipairs(arg) do
      print(string.format("arg[%d] = %s", i, v))
   end
end

function test_modules()
   m1.hello()
   m2.hello()
   m3.hello()
   output = tlib.run("echo", "🐢 Hello from Tlib")
   print(output)
end

for i in ipairs(arg) do
   tlib.check_args(arg[i], {'h', '-h', 'help', '--help'}, help)
   tlib.check_args(arg[i], {'a', '-a', 'args', '--args'}, print_args)
   tlib.check_args(arg[i], {'m', '-m', 'modules', '--modules'}, test_modules)
end
