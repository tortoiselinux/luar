#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#define MARKER "--[[LUA_SCRIPT_START]]"

int run_embedded_script(lua_State *L, const char *filename, int argc, char **argv) {

  // open 
  FILE *f = fopen(filename, "rb");
  if (!f) { perror("fopen"); return 1; }

  fseek(f, 0, SEEK_END);
  long size = ftell(f);
  rewind(f);

  char *buffer = malloc(size + 1);
  fread(buffer, 1, size, f);
  buffer[size] = '\0';
  fclose(f);

  char *start = NULL;
  for (long i = size - strlen(MARKER); i >= 0; i--) {
    if (memcmp(buffer + i, MARKER, strlen(MARKER)) == 0) {
      start = buffer + i + strlen(MARKER);
      break;
    }
  }

  if (!start) {
    fprintf(stderr, "❌ Script não encontrado no executável.\n");
    free(buffer);
    return 1;
  }

  if (*start == '\r') start++;
  if (*start == '\n') start++;

  // Prepara tabela 'arg'
  lua_newtable(L);
  for (int i = 0; i < argc; i++) {
    lua_pushstring(L, argv[i]);
    lua_rawseti(L, -2, i);
  }
  lua_setglobal(L, "arg");

  if (luaL_dostring(L, start)) {
    fprintf(stderr, "💥 Erro ao executar: %s\n", lua_tostring(L, -1));
    lua_pop(L, 1);
  }

  free(buffer);
  return 0;
}

int main(int argc, char **argv) {
  lua_State *L = luaL_newstate();
  /*Open Lua standard libraries*/
  luaL_openlibs(L);
  run_embedded_script(L, argv[0], argc, argv);
  lua_close(L);
  return 0;
}
