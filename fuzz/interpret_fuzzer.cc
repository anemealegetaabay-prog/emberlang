#include <stddef.h>
#include <stdint.h>

#include "emberlang.h"

// Drives the full pipeline: source bytes -> lex -> compile -> execute.
extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
  emberlang_interpret(reinterpret_cast<const char*>(data), size);
  return 0;
}
