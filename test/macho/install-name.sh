#!/bin/bash
. $(dirname $0)/common.inc

cat <<EOF | $CC -o $t/a.o -c -xc -
void foo() {}
EOF

$CC --ld-path=./ld64 -shared -o $t/b.dylib $t/a.o -Wl,-install_name,foobar
otool -l $t/b.dylib | grep -q 'name foobar'
