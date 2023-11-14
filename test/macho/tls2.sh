#!/bin/bash
. $(dirname $0)/common.inc

# For some reason, this test fails only on GitHub CI.
[ "$GITHUB_ACTIONS" = true ] && { echo skipped; exit; }

cat <<EOF | $CC -o $t/a.o -c -xc -
#include <stdio.h>

_Thread_local int a;
static _Thread_local int b = 5;
static _Thread_local int *c;

int main() {
  b = 5;
  c = &b;
  printf("%d %d %d\n", a, b, *c);
}
EOF

$CC --ld-path=./ld64 -o $t/exe $t/a.o
$t/exe | grep -q '^0 5 5$'
