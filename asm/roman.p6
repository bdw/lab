use NativeCall;

sub roman_numeral(int32) returns Str is native('./libroman.so.1') {*};
my $str = roman_numeral(5);

say $str;

