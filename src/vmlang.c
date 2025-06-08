#include <stdlib.h>
#include <string.h>

#include "compiler.h"
#include "object.h"
#include "vm.h"
#include "vmlang.h"

/* Both entry points accept a (possibly non-NUL-terminated) byte buffer,
   as delivered by the fuzzing harness, and copy it into a NUL-terminated
   scratch buffer the scanner can consume. */

static char* nul_terminate(const char* source, size_t length) {
  char* buf = (char*)malloc(length + 1);
  if (buf == NULL) return NULL;
  if (length > 0) memcpy(buf, source, length);
  buf[length] = '\0';
  return buf;
}

int vmlang_interpret(const char* source, size_t length) {
  char* buf = nul_terminate(source, length);
  if (buf == NULL) return -1;

  initVM();
  InterpretResult result = interpret(buf);
  freeVM();

  free(buf);
  return result == INTERPRET_OK ? 0 : (int)result;
}

int vmlang_compile(const char* source, size_t length) {
  char* buf = nul_terminate(source, length);
  if (buf == NULL) return -1;

  initVM();
  ObjFunction* function = compile(buf);
  bool ok = function != NULL;
  freeVM();

  free(buf);
  return ok ? 0 : 1;
}
