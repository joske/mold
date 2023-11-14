#!/bin/bash
. $(dirname $0)/common.inc

cat <<EOF | $CC -o $t/a.o -c -xc -
#include <stdio.h>
int main() {
  printf("Hello world\n");
}
EOF

$CC --ld-path=./ld64 -o $t/exe $t/a.o
strip $t/exe
$t/exe | grep -q 'Hello world'
