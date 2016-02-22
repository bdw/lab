#/usr/bin/env perl6
use v6;

sub MAIN(IO() $csv-filename where $csv-filename ~~ :f) {
    my @rows;
    for $csv-filename.lines -> $line {
        @rows.push($line.split(','));
    }
    my $max-columns = @rows>>.elems.max;
    my @max-width  = 0 xx $max-columns;
    for @rows -> @row {
        my @row-width = @row>>.chars;
        @max-width = (@max-width Z @row-width)>>.max;
    }

    sub print-row-separator($line = '-') {
        for ^$max-columns {
            print '+', $line x (@max-width[$_] + 2);
        }
        print "+\n";
    }
    sub print-columns($row) {
        for ^$max-columns {
            print '| ', $row[$_], ' ' x (@max-width[$_] - $row[$_].chars + 1);
        }
        print "|\n";
    }
    print-row-separator;
    print-columns @rows.shift;
    print-row-separator '=';
    for @rows -> $row {
        print-columns $row;
        print-row-separator;
    }
}
