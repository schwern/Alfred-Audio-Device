#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;

our $VERSION = '0.02';

my $action    = shift || 'list';
my $direction = shift || 'output';


if ($action eq 'list') {
    my $devices = get_possibilities($direction);
    print qq{<?xml version="1.0"?>\n<items>\n};
    print output_device($_) for @$devices;
    print "</items>\n";
}
elsif ( $action eq 'set' ) {
    my $device = shift;
    print set_device($direction, $device) . "\n";
}
elsif ( $action eq 'toggle' ) {
    my $device1 = shift;
    my $device2 = shift;
    my $default_device = shift;

    my $current_device = get_current_device($direction);
    if( $current_device eq $device1 ) {
        print set_device($direction, $device2) . "\n";
    }
    elsif( $current_device eq $device2 ) {
        print set_device($direction, $device1) . "\n";
    }
    elsif( $default_device ) {
        print set_device($direction, $default_device) . "\n";
    }
}
else {
    print "Unrecognized action '$action'\n";
}

sub run_command {
    open( my $fh, '-|', $FindBin::Bin . '/SwitchAudioSource', @_ );
    my $output = join "\n", <$fh>;
    close $fh;
    return $output;
}

sub get_current_device {
    my $direction = shift;

    my $current_device = run_command('-ct', $direction );
    chomp($current_device);

    return $current_device;
}

sub get_possibilities {
    my $direction = shift;
    my $current_device = get_current_device($direction);
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
