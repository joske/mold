#!/bin/bash
. $(dirname $0)/common.inc

cat <<EOF | $CC -o $t/a.o -c -xc -
void foo() {}
EOF

$CC --ld-path=./ld64 -shared -o $t/libfoo.dylib $t/a.o

cat <<EOF | $CC -o $t/b.o -c -xc -
void bar() {}
EOF

$CC --ld-path=./ld64 -shared -o $t/libbar.dylib $t/b.o -L$t -Wl,-reexport-lfoo

objdump --macho --dylibs-used $t/libbar.dylib | grep -q 'libfoo.*reexport'

cat <<EOF | $CC -o $t/c.o -c -xc -
void baz() {}
EOF

$CC --ld-path=./ld64 -shared -o $t/libbaz.dylib $t/c.o -L$t -Wl,-reexport-lbar

objdump --macho --dylibs-used $t/libbaz.dylib | grep -q 'libbar.*reexport'

cat <<EOF | $CC -o $t/d.o -c -xc -
void foo();
void bar();
void baz();

int main() {
  foo();
  bar();
  baz();
}
EOF

$CC --ld-path=./ld64 -o $t/exe $t/d.o -L$t -lbaz
