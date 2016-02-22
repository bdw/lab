use v6.c;

sub MAIN(Int() $n, Bool :$dump?) {
    # apply sieve of erasthothenes
    my @sieve;
    my @primes;
    for 2..$n -> $x {
        unless @sieve[$x] {
            @primes.push($x);
            loop (my $y = $x; $y <= $n; $y += $x) {
                @sieve[$y].push($x);
            }
        }
    }
    my @factors;
    my $t = +$n;
    for @sieve[$n].list -> $p {
        last if $t == 1;
        while $t mod $p == 0 {
            @factors.push($p);
            $t = ($t div $p);
        }
    }
    say "Factors of $n: {@factors}";
    say "Largest prime: {@primes[*-1]}";
    if $dump {
        @primes>>.say;
    }
}

