#!/bin/bash

if [ !  -f "$1" -o ! -f "$2" ]; then
    echo Please enter two files to compare
    exit 1
fi

DIGEST=`which sha256sum`

if [ ! -x "$DIGEST" ]; then
    DIGEST=`which shasum`
fi

if [ ! -x "$DIGEST" ]; then
    echo You do not seem to have a checksum program installed.
    echo This program cannot "function" without it.
    echo Please install either sha256sum or shasum.
    exit 1
fi

CHECK=`$DIGEST $1 $2 | cut -d ' ' -f 1 | uniq | wc -l`
if [ $CHECK -gt 1 ]; then
    echo Files $1 and $2 differ.
    exit 1
else
    echo Files $1 and $2 are the same.
fi
