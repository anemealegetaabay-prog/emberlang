# emberlang

Built following Robert Nystrom's *Crafting Interpreters* (clox), extended with fuzz testing and an end-to-end test suite.

A small stack-based bytecode virtual machine for a dynamically typed scripting
language (the book's Lox). Source is scanned into tokens, compiled to bytecode
in a single pass, and executed by a stack VM with string interning and a
mark-and-sweep garbage collector.

## Language

- Values: `nil`, booleans, numbers (double), strings
- Arithmetic, comparison, and logical (`and` / `or`) operators
- String concatenation with `+`
- Global and block-scoped local variables
- Control flow: `if` / `else`, `while`, `for`
- `print` statement
- Functions and closures
- Classes with initializers, methods, and single inheritance (`<`, `super`)
- Native `clock()` function

```
var total = 0;
for (var i = 1; i <= 4; i = i + 1) {
  total = total + i;
}
print total;            // 10
print "foo" + "bar";    // foobar
```

## Build & run

```sh
make            # produces ./emberlang
./emberlang script.ember
./emberlang     # REPL
make test       # run the end-to-end suite in tests/
```

## What I added beyond the book

- **Embedding API:** `include/emberlang.h` and `src/emberlang.c`.
  `emberlang_interpret()` and `emberlang_compile()` take a pointer and a
  length, so they accept buffers that are not NUL-terminated (as a fuzzer
  delivers them), and they set up and tear down the VM on every call.
- **Two libFuzzer harnesses** in `fuzz/`. `interpret_fuzzer` runs the full
  pipeline (scan, compile, execute) and `compile_fuzzer` stops after
  compilation.
- **Fuzzing inputs:** a dictionary of keywords and punctuation
  (`fuzz/dictionary.txt`) and seed corpora of 650 inputs for
  `interpret_fuzzer` and 1 for `compile_fuzzer`.
- **ClusterFuzzLite config** in `.clusterfuzzlite/`. `build.sh` builds both
  harnesses and packages their seed corpora, and `project.yaml` enables
  AddressSanitizer and UndefinedBehaviorSanitizer.
- **End-to-end test suite** in `tests/`. `run_tests.sh` runs each
  `tests/cases/*.ember` script and compares its output with the matching
  `.expected` file. Six cases cover arithmetic, strings, control flow, scopes,
  functions and closures, and classes with inheritance. `make test` runs it.
- A standalone **Makefile** for the CLI and the tests.

## Layout

```
src/        scanner, compiler, vm, object model, hash table, GC, CLI
include/    emberlang.h  (embedding API used by the fuzz harnesses)
fuzz/       libFuzzer harnesses + seed corpus + dictionary
tests/      end-to-end cases (script -> expected stdout)
.clusterfuzzlite/  build.sh + project.yaml (ClusterFuzzLite entry point)
```

## Fuzzing

Two harnesses exercise different entry points:

- `interpret_fuzzer`: full pipeline (lex → compile → execute)
- `compile_fuzzer`: lex + compile only

`.clusterfuzzlite/build.sh` builds both into `$OUT`. To build and run one
locally with libFuzzer (Apple's Xcode clang does not include libFuzzer; on
macOS use Homebrew LLVM's `clang`):

```sh
mkdir -p build/corpus
clang -fsanitize=address,fuzzer -Iinclude -Isrc \
    fuzz/interpret_fuzzer.cc src/{value,chunk,memory,object,table,scanner,compiler,vm,emberlang}.c \
    -o build/interpret_fuzzer
./build/interpret_fuzzer -dict=fuzz/dictionary.txt build/corpus fuzz/corpus/interpret_fuzzer
```

New inputs go to `build/corpus` (ignored by git), and the checked-in seeds
in `fuzz/corpus/interpret_fuzzer` are only read.

## License

MIT, see [LICENSE](LICENSE). The VM follows clox from
[Crafting Interpreters](https://craftinginterpreters.com/), whose code is MIT
licensed by Robert Nystrom.
