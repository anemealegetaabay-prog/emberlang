# emberlang

A small stack-based bytecode virtual machine for a dynamically typed scripting
language. Source is scanned into tokens, compiled to bytecode in a single pass,
and executed by a stack VM with a string-interning hash table for globals.

## Language

- Values: `nil`, booleans, numbers (double), strings
- Arithmetic, comparison, and logical (`and` / `or`) operators
- String concatenation with `+`
- Global and block-scoped local variables
- Control flow: `if` / `else`, `while`, `for`
- `print` statement

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
./emberlang script.vl
./emberlang        # REPL
make test       # run the end-to-end suite in tests/
```

## Layout

```
src/        scanner, compiler, vm, object model, hash table, public API
include/    emberlang.h  (public entry points used by the CLI and fuzzers)
fuzz/       libFuzzer harnesses + seed corpus + dictionary
tests/      end-to-end cases (script -> expected stdout)
.clusterfuzzlite/  build.sh + project.yaml (ClusterFuzzLite entry point)
```

## Fuzzing

Two harnesses exercise different entry points:

- `interpret_fuzzer` — full pipeline (lex → compile → execute)
- `compile_fuzzer`   — lex + compile only

`.clusterfuzzlite/build.sh` builds both into `$OUT`. Locally with libFuzzer:

```sh
clang -fsanitize=address,fuzzer -Iinclude -Isrc \
    fuzz/interpret_fuzzer.cc src/{value,chunk,memory,object,table,scanner,compiler,vm,emberlang}.c \
    -o interpret_fuzzer
./interpret_fuzzer fuzz/corpus/interpret_fuzzer
```
