#!/usr/bin/env perl6

use NativeCall;

sub rot13_encrypt (Str $message is encoded('ascii')) returns Str is encoded('ascii') is native('./librot13.so') {*};

sub MAIN(Str $message) {
    say rot13_encrypt($message);
}
