local t = require("tlib")

local main = arg[1]
local modules = {}
local bundle_path = "bundle.lua"

local function normalize_name(path)
    return path
        :gsub("%.lua$", "")
        :gsub("^%./", "")
end

local function read_file(path)
    local f = io.open(path, "r")
    if not f then error("Cannot open " .. path) end
    local content = f:read("*a")
    f:close()
    return content
end

function get_last_name(path)
    local name = path:match("[/\\]([^/\\]+)$")

    if name then
        return name
    else
        return path:match("[^/\\]+$") or path
    end
end

local function wrap_module(name, content)
    return string.format([[
["%s"] = function()
%s
end,
]], name, content)
end

for i=2, #arg do
    table.insert(modules, arg[i])
end

print("Main: " .. main)

for i, v in ipairs(modules) do
    print(i .. " Module: " .. v)
end

local bundle = {}

table.insert(bundle, "local __modules = {")
for _, mod in ipairs(modules) do
    local content = t.read_file(mod)
    local normalized_path = normalize_name(mod)
    local name = get_last_name(normalized_path)
    table.insert(bundle, wrap_module(name, content))
end

table.insert(bundle, "}")

table.insert(bundle, [[
local __cache = {}
function require(name)
    if __cache[name] then return __cache[name] end
    local m = __modules[name]()
    __cache[name] = m
    return m
end
]])

local main_content = read_file(main)
table.insert(bundle, main_content)

local output = table.concat(bundle, "\n")

local f = io.open(bundle_path, "w")
f:write(output)
f:close()

print("Arquivo gerado em: " .. bundle_path)
