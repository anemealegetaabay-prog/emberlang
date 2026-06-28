#include <stddef.h>
#include <stdint.h>

#include "vmlang.h"

// Drives lex + compile only (no execution): exercises scanner/compiler.
extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
  vmlang_compile(reinterpret_cast<const char*>(data), size);
  return 0;
}
