#!/bin/bash
. $(dirname $0)/common.inc

cat <<EOF | $CC -o $t/a.o -c -xc -
void foo() {}
__attribute__((visibility("hidden"))) void bar() {}
void baz() {}
void abc() {}
void xyz() {}
EOF

cat <<EOF > $t/list
_foo
_a*
EOF

$CC --ld-path=./ld64 -shared -o $t/c.dylib $t/a.o

objdump --macho --exports-trie $t/c.dylib > $t/log1
grep -q _foo $t/log1
! grep -q _bar $t/log1 || false
grep -q _baz $t/log1
grep -q _abc $t/log1
grep -q _xyz $t/log1

$CC --ld-path=./ld64 -shared -o $t/d.dylib $t/a.o \
  -Wl,-exported_symbols_list,$t/list

objdump --macho --exports-trie $t/d.dylib > $t/log2
grep -q _foo $t/log2
! grep -q _bar $t/log2 || false
! grep -q _baz $t/log2 || false
grep -q _abc $t/log2
! grep -q _xyz $t/log2 || false

$CC --ld-path=./ld64 -shared -o $t/e.dylib $t/a.o -Wl,-exported_symbol,_foo

objdump --macho --exports-trie $t/e.dylib > $t/log3
grep -q _foo $t/log3
! grep -q _bar $t/log3 || false
! grep -q _baz $t/log3 || false
! grep -q _abc $t/log3 || false
! grep -q _xyz $t/log3 || false
