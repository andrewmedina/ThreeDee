#!/bin/bash
flex "scanner.l"
gcc lex.yy.c -o scanner /usr/local/opt/flex/lib/libfl.a
./scanner $1
