# Makefile para empacotar scripts Lua standalone multiplataforma

LUA_VERSION=5.4.6
LUA_URL=https://www.lua.org/ftp/lua-$(LUA_VERSION).tar.gz
LUA_TAR=lua-$(LUA_VERSION).tar.gz
LUA_DIR=lua-src
STUB=stub.c
BUILD_DIR=build/runtime
LUAR_LINUX=$(BUILD_DIR)/luar
LUAR_WINDOWS=$(BUILD_DIR)/luar.exe

CC_LINUX=gcc
CC_WINDOWS=x86_64-w64-mingw32-gcc

# FHS
PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib/packer
SHAREDIR := $(PREFIX)/share/packer

# Scripts e libs
PACKER_CLI = packer.lua
LINKER_CLI = linker.lua
LIBS = linkerlib.lua tlib.lua
STUBS = stub.c

INSTALL = install
MKDIR_P = mkdir -p
RM = rm -f
RMDIR = rmdir --ignore-fail-on-non-empty

.PHONY: all linux windows clean install uninstall

all: linux windows

# Baixa o código-fonte do Lua e move pra pasta lua-src/
$(LUA_TAR):
	curl -R -O $(LUA_URL)

$(LUA_DIR): $(LUA_TAR)
	tar zxf $(LUA_TAR)
	mv lua-$(LUA_VERSION) $(LUA_DIR)

# Compila Lua estaticamente para Linux
$(LUA_DIR)/src/liblua.a: $(LUA_DIR)
	$(MAKE) -C $(LUA_DIR) clean
	$(MAKE) -C $(LUA_DIR) linux MYCFLAGS="-fPIC" MYLIBS="-lm"

linux: $(LUA_DIR)/src/liblua.a
	@mkdir -p $(BUILD_DIR)
	$(CC_LINUX) -I$(LUA_DIR)/src -o $(LUAR_LINUX) $(STUB) $(LUA_DIR)/src/liblua.a -lm
	chmod +x $(LUAR_LINUX)
	@echo "✅ Executável Linux criado: $(LUAR_LINUX)"

windows: $(LUA_DIR)
	@mkdir -p $(BUILD_DIR)
	$(MAKE) -C $(LUA_DIR) clean
	$(MAKE) -C $(LUA_DIR) mingw CC=$(CC_WINDOWS)
	$(CC_WINDOWS) -I$(LUA_DIR)/src -o $(LUAR_WINDOWS) $(STUB) $(LUA_DIR)/src/liblua.a -lm
	@echo "✅ Executável Windows criado: $(LUAR_WINDOWS)"

clean:
	rm -rf $(BUILD_DIR) $(LUA_DIR) $(LUA_TAR)

# Instala CLI e bibliotecas
install: builddirs
	$(INSTALL) -m 755 $(PACKER_CLI) $(BINDIR)/packer
	$(INSTALL) -m 755 $(LINKER_CLI) $(BINDIR)/linker
	$(INSTALL) -m 644 $(LIBS) $(LIBDIR)
	$(INSTALL) -m 644 $(STUBS) $(SHAREDIR)
	@echo "✅ Packer e Linker instalados com sucesso em $(PREFIX)"

builddirs:
	$(MKDIR_P) $(BINDIR)
	$(MKDIR_P) $(LIBDIR)
	$(MKDIR_P) $(SHAREDIR)

uninstall:
	$(RM) $(BINDIR)/packer
	$(RM) $(BINDIR)/linker
	$(RM) $(addprefix $(LIBDIR)/, $(LIBS))
	$(RM) $(addprefix $(SHAREDIR)/, $(STUBS))
	$(RMDIR) $(LIBDIR)
	$(RMDIR) $(SHAREDIR)
	@echo "🗑️ Remoção concluída de $(PREFIX)"
