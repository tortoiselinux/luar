#!/usr/bin/env lua

local t = require("tlib")

local function help()
 local helpmsg = [[

 Luar Parser

 How To use:
 parser filename

 NOTE: When you don't provide a filename, the first
       argument is used
 
 Options:
 h | help : prints help message
	   
 NOTE: (-) or (--) are optional

 Hey, this script is part of the lua packer!
 To see how you can make embedded scripts
 see: https://github.com/tortoiselinux/luar
 
]]
    print(helpmsg)
end

-- TODO: Diminuir a quantidade de tabelas criadas nesse programa, para melhorar o desempenho.
-- TODO: Carregar mais informações sobre as linhas do programa na tabela
-- TODO: Informar linha e coluna de cada token


local function p(msg, value) print(msg, value) end

local function exit(code)
    os.exit(code)
end

local function string_lines_to_table(str)
    local new_table = {}

    for line in str:gmatch("[^\n]+") do
	table.insert(new_table, {line = line})
    end

    return new_table
end

local function get_lines(program)
    local program_lines = {}

    for pos, t in ipairs(program) do
	table.insert(program_lines, {value = t.line, pos = pos})
    end

    return program_lines
end

local function get_words(program_lines)
    local words = {}

    for i, line in ipairs(program_lines) do
	for word in line.value:gmatch("%S+") do
	    table.insert(words, { value = word, line = line.pos, col = i})
	end
    end
    return words
end

local symbols	= {
    _local	= "local",
    _req        = "require",
    _func	= "function",
    _for	= "for",
    _if		= "if",
    _elseif	= "elseif",
    _else	= "else",
    _then	= "then",
    _do		= "do",
    _in		= "in",
    _eq		= "=",
    _plus	= "+",
    _minus	= "-",
    _mult	= "*",
    _div	= "/",
}

local function lex(words)
    local lexemes = {}

    for _, word in ipairs(words) do
	local value	= word.value
	local line	= word.line
	local col	= word.col

	-- reserved words
	if value == symbols._local then
	    p("declaration founded: ", value)
	    table.insert(lexemes, {token = word.value, t_type = "declaration", line = line, col = col})
	elseif value == symbols._req then
	    p("code import: ", value)

	-- operators
	elseif value == symbols._eq then
	    p("assignment founded: ", value)
	    table.insert(lexemes, {token = word.value, t_type = "assignment", line = line, col = col})
	elseif value == symbols._plus then
	    p("plus operation: ", value)
	    table.insert(lexemes, {word = word.value, t_type = "plus", line = line, col = col})
	elseif value == symbols._minus then
	    p("minus operation: ", value)
	    table.insert(lexemes, {token = word.value, t_type = "minus", line = line, col = col})
	elseif value == symbols._mult then
	    p("mult operation: ", value)
	    table.insert(lexemes, {token = word.value, t_type = "mult", line = line, col = col})
	elseif value == symbols._div then
	    p("div operation: ", value)
	    table.insert(lexemes, {token = word.value, t_type = "div", line = line, col = col})

	-- others
	elseif type(tonumber(value)) == "number" then
	    p("number founded: ", value)
	    table.insert(lexemes, {token = word.value, t_type = "number", line = line, col = col})
	elseif type(value) == "string" then
	    p("symbol founded: ", value)
	    table.insert(lexemes, {token = word.value, t_type = "symbol", line = line, col = col})
	else
	    if word.value ~= nil then
		p("unexpected token: ", value)
	    end
	end
    end

    return lexemes
end

if #arg == 0 then
    help()
    exit(1)
elseif t.verify_args(arg, { "h", "-h", "help", "--help" }) then
    help()
    exit(0)
else
    local program = string_lines_to_table(t.read_file(arg[1]))
    if program == nil then 
	error("No program loaded")
    end

    print("program loaded:")
    for _, v in ipairs(program) do
	print(v.line)
    end

    local program_lines = get_lines(program)
    local words = get_words(program_lines)
    local lexemes = lex(words)
    -- for _, lexeme in ipairs(lexemes) do
    -- 	if lexeme.token ~= nil then
    -- 	    p("token: " .. lexeme.token, lexeme.t_type)
    -- 	end
    -- end
end
