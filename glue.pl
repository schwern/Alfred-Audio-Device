#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;

my $action = shift || 'list';
my $direction = shift || 'output';

if ($action eq 'list') {
    my $devices = get_possibilities($direction);
    print qq{<?xml version="1.0"?>\n<items>\n};
    print output_device($_) for @$devices;
    print "</items>\n";
}

if ( $action eq 'set' ) {
    my $device = shift;
    print set_device($direction, $device) . "\n";
}

sub run_command {
    open( my $fh, '-|', $FindBin::Bin . '/SwitchAudioSource', @_ );
    my $output = join "\n", <$fh>;
    close $fh;
    return $output;
}

sub get_possibilities {
    my $direction = shift;
    my $current_device = run_command('-ct', $direction );
    chomp($current_device);
    my @devices;
    for my $line (split "\n", run_command( '-at', $direction ) ) {
        chomp $line;
        next unless $line =~ s/ \(\Q$direction\E\)$//;
        next if $line eq $current_device;
        push @devices, $line;
    }
    return \@devices;
}

sub set_device {
    my ( $direction, $device ) = @_;
    return run_command( '-t', $direction, '-s', $device );
}

sub output_device {
    my $device = shift;
    ( my $device_no_space = $device ) =~ tr/ /_/;
    return qq{<item arg="$device" uid="$device_no_space"><title>$device</title><subtitle/><icon>icon.png</icon></item>\n};
}
