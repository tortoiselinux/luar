local t = require("tlib")
local linkerlib = {}
local MAGIC_MARK = "--[[LUA_SCRIPT_START]]"

function linkerlib.link(script, lua_module)
   content = "\n" .. "--modid:" .. lua_module .. "\n"
   content = content .. t.read_file(lua_module)
   content = content:gsub("[\r\n]*%s*return%s+[%w_]+%s*$", "")
   content = content .. "\n" .. "--modend:" .. lua_module .. "\n"
   return content
end

return linkerlib
