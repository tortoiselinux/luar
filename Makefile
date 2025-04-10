# Makefile completo para build standalone Lua
LUA_VERSION=5.4.6
LUA_URL=https://www.lua.org/ftp/lua-$(LUA_VERSION).tar.gz
LUA_DIR=lua-$(LUA_VERSION)
STUB=stub.c
#SCRIPT=script.lua
BUILD=build
STATIC_LUA=$(LUA_DIR)/src/liblua.a

# Compilador (Linux nativo e cross para Windows)
CC_LINUX=gcc
CC_WINDOWS=x86_64-w64-mingw32-gcc

.PHONY: all linux windows clean

all: linux

# Baixa e compila Lua estaticamente
$(STATIC_LUA):
	@echo "📦 Baixando Lua $(LUA_VERSION)..."
	curl -R -O $(LUA_URL)
	tar zxf lua-$(LUA_VERSION).tar.gz
	$(MAKE) -C $(LUA_DIR) linux MYCFLAGS="-fPIC" MYLIBS="-lm"

linux: $(STATIC_LUA)
	@mkdir -p $(BUILD)
	$(CC_LINUX) -o $(BUILD)/programa $(STUB) $(STATIC_LUA) -lm
	cat $(SCRIPT) >> $(BUILD)/programa
	chmod +x $(BUILD)/programa
	@echo "✅ Executável Linux criado: $(BUILD)/programa"

windows: $(STATIC_LUA)
	@mkdir -p $(BUILD)
	$(CC_WINDOWS) -o $(BUILD)/programa.exe $(STUB) $(STATIC_LUA) -lm
	cat $(SCRIPT) >> $(BUILD)/programa.exe
	@echo "✅ Executável Windows criado: $(BUILD)/programa.exe"

clean:
	rm -rf $(BUILD) $(LUA_DIR) lua-$(LUA_VERSION).tar.gz
