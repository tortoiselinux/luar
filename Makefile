# Makefile para empacotar scripts Lua standalone multiplataforma (Linux e Windows)

LUA_VERSION=5.4.6
LUA_URL=https://www.lua.org/ftp/lua-$(LUA_VERSION).tar.gz
LUA_TAR=$(LUA_DIR).tar.gz
LUA_DIR=lua-$(LUA_VERSION)

STUB=stub.c
SCRIPT=script.lua
BUILD=build

# Compilador (Linux nativo e cross para Windows)
CC_LINUX=gcc
CC_WINDOWS=x86_64-w64-mingw32-gcc

# Diretórios para build estático Windows
WIN_LUA_DIR=win-lua
WIN_LUA_INCLUDE=$(WIN_LUA_DIR)/include
WIN_LUA_LIB=$(WIN_LUA_DIR)/lib

# Artefatos
STATIC_LUA=$(LUA_DIR)/src/liblua.a
STATIC_WIN_LUA=$(WIN_LUA_LIB)/liblua.a

.PHONY: all linux windows win-lua clean

all: linux

# Download e extração do Lua
$(LUA_TAR):
	curl -R -O $(LUA_URL)

$(LUA_DIR): $(LUA_TAR)
	tar zxf $<

# Compila Lua estaticamente para Linux
$(STATIC_LUA): $(LUA_DIR)
	$(MAKE) -C $(LUA_DIR) clean
	$(MAKE) -C $(LUA_DIR) linux MYCFLAGS="-fPIC" MYLIBS="-lm"

# Build do executável para Linux
linux: $(STATIC_LUA)
	@mkdir -p $(BUILD)
	$(CC_LINUX) -o $(BUILD)/programa $(STUB) $(STATIC_LUA) -lm
	cat $(SCRIPT) >> $(BUILD)/programa
	chmod +x $(BUILD)/programa
	@echo "✅ Executável Linux criado: $(BUILD)/programa"

# Compila Lua para Windows (cross-compile)
$(STATIC_WIN_LUA): $(LUA_DIR)
	mkdir -p $(WIN_LUA_INCLUDE) $(WIN_LUA_LIB)
	cd $(LUA_DIR) && make clean && make mingw CC=$(CC_WINDOWS)
	cp $(LUA_DIR)/src/*.h $(WIN_LUA_INCLUDE)/
	cp $(LUA_DIR)/src/liblua.a $(WIN_LUA_LIB)/

win-lua: $(STATIC_WIN_LUA)

# Build do executável para Windows
windows: $(STATIC_WIN_LUA)
	@mkdir -p $(BUILD)
	$(CC_WINDOWS) -o $(BUILD)/programa.exe $(STUB) \
		-I$(WIN_LUA_INCLUDE) \
		$(STATIC_WIN_LUA) -lm
	cat $(SCRIPT) >> $(BUILD)/programa.exe
	@echo "✅ Executável Windows criado: $(BUILD)/programa.exe"

# Limpa tudo
clean:
	rm -rf $(BUILD) $(LUA_DIR) $(WIN_LUA_DIR) $(LUA_TAR)
