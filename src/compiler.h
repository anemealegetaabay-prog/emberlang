#ifndef VMLANG_COMPILER_H
#define VMLANG_COMPILER_H

#include "object.h"
#include "vm.h"

ObjFunction* compile(const char* source);
void markCompilerRoots(void);

#endif
