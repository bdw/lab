#!/usr/bin/env perl
use strict;
use POSIX;

sub time_to_seconds {
    my $time = shift;
    my ($h, $m, $s_and_ms) = split /:/, $time;
    my ($s, $ms) = split /,/, $s_and_ms;
    return ($s + ($ms / 1000)) + ($m * 60) + ($h * 3600);
}

sub seconds_to_time {
    my $num = shift;
    my $h = floor($num / 3600);
    my $m = floor(($num % 3600) / 60);
    my $s = floor($num % 60);
    my $ms = floor(($num - floor($num)) * 1000);
    return sprintf("%02d:%02d:%02d,%03d", $h, $m, $s, $ms);
}

sub cat_srt_files {
    local $/ = "\r\n\r\n";
    local $\ = "\r\n\r\n";
    local $, = "\r\n";
    my $time = qr/\d\d:\d\d:\d\d,\d{3}/;
    my $re = qr/^($time) --> ($time)$/;
    my $offset = 0;
    my $last = 0;
    my $line = 1;
    while (@_) {
	my $file = shift;
	open(my $handle, '<', $file) or die "could not open $file";
	while (<$handle>) {
	    chomp;
	    my @lines = split /\r\n/;
	    my ($start, $stop) = ($lines[1] =~ m/$re/);
	    my $start_sec = time_to_seconds($start) + $offset;
	    my $stop_sec = time_to_seconds($stop) + $offset;
	    $last = $stop_sec;
	    my $time_line = sprintf("%s --> %s", seconds_to_time($start_sec), seconds_to_time($stop_sec));
	    my @text_lines = @lines[2 .. $#lines];
	    print $line++, $time_line, @text_lines;
	}
	$offset = $last;
	close $handle;
    }
}

cat_srt_files(@ARGV);
