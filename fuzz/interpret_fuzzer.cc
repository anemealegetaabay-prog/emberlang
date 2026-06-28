#include <stddef.h>
#include <stdint.h>

#include "vmlang.h"

// Drives the full pipeline: source bytes -> lex -> compile -> execute.
extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
  vmlang_interpret(reinterpret_cast<const char*>(data), size);
  return 0;
}
