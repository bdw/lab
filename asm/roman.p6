use NativeCall;

sub roman_numeral(int32) returns Str is encoded('ascii') is native('./libroman.so.1') {*};
say roman_numeral(1987);
say roman_numeral(2016);
say roman_numeral(29);

