#!/bin/bash
. $(dirname $0)/common.inc

cat <<EOF | $CC -c -o $t/a.o -xc -
int foo() { return 3; }
int bar() { return 5; }
EOF

rm -f $t/b.a
ar rcs $t/b.a $t/a.o

cat <<EOF | $CC -c -o $t/c.o -xc -
#include <stdio.h>

int foo() __attribute__((weak));
int foo() { return 42; }

int main() {
  printf("foo=%d\n", foo());
}
EOF

$CC --ld-path=./ld64 -o $t/exe1 $t/b.a $t/c.o
$t/exe1 | grep -q '^foo=42$'

cat <<EOF | $CC -c -o $t/d.o -xc -
#include <stdio.h>

int foo() __attribute__((weak));
int foo() { return 42; }
int bar();

int main() {
  printf("foo=%d bar=%d\n", foo(), bar());
}
EOF

$CC --ld-path=./ld64 -o $t/exe2 $t/b.a $t/d.o
$t/exe2 | grep -q '^foo=3 bar=5$'
