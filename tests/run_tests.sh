#!/bin/bash
# Minimal end-to-end test runner: each tests/cases/<name>.vl is run and its
# stdout compared against tests/cases/<name>.expected.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VM="$ROOT/vmlang"
CASES="$ROOT/tests/cases"

if [ ! -x "$VM" ]; then
  echo "error: build vmlang first (make)" >&2
  exit 1
fi

pass=0
fail=0
for script in "$CASES"/*.vl; do
  [ -e "$script" ] || continue
  name="$(basename "$script" .vl)"
  expected="$CASES/$name.expected"
  actual="$("$VM" "$script" 2>&1)"
  if [ "$actual" == "$(cat "$expected")" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    echo "FAIL: $name"
    echo "  expected: $(cat "$expected")"
    echo "  actual:   $actual"
  fi
done

echo "tests: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
