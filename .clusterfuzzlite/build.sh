#!/bin/bash -eu
# Builds every fuzz harness into $OUT. Runs with the repo as $SRC and as
# the working directory, so all paths are rooted at $SRC.

LIB_SRCS=(value chunk memory object table scanner compiler vm emberlang)

OBJS=""
for unit in "${LIB_SRCS[@]}"; do
  $CC $CFLAGS -I"$SRC/src" -I"$SRC/include" \
      -c "$SRC/src/${unit}.c" -o "${unit}.o"
  OBJS="$OBJS ${unit}.o"
done

for harness in interpret compile; do
  $CXX $CXXFLAGS -I"$SRC/src" -I"$SRC/include" \
      $LIB_FUZZING_ENGINE \
      "$SRC/fuzz/${harness}_fuzzer.cc" $OBJS \
      -o "$OUT/${harness}_fuzzer"
done

# Package shared seed corpus for each harness, if present.
if [ -d "$SRC/fuzz/corpus" ]; then
  for harness in interpret compile; do
    seeds="$SRC/fuzz/corpus/${harness}_fuzzer"
    [ -d "$seeds" ] || seeds="$SRC/fuzz/corpus"
    (cd "$seeds" && zip -q -r "$OUT/${harness}_fuzzer_seed_corpus.zip" . \
        2>/dev/null) || true
  done
fi
