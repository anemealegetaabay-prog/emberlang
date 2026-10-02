#ifndef EMBERLANG_PUBLIC_H
#define EMBERLANG_PUBLIC_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Public entry points used by both the CLI and the fuzz harnesses. */

/* Compile + run a script. Returns 0 on success, non-zero on
   compile/runtime error. The buffer need not be NUL-terminated. */
int emberlang_interpret(const char* source, size_t length);

/* Compile only (lex + parse + emit bytecode), discarding the result.
   Returns 0 if compilation succeeded, non-zero otherwise. */
int emberlang_compile(const char* source, size_t length);

#ifdef __cplusplus
}
#endif

#endif
