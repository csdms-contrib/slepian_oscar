#!/usr/bin/perl
#
# Computes day of year for a date string
#
# Last modified by fjsimons-at-alum.mit.edu, 09/20/2023 

use saclib;

if ($#ARGV == -1) {
    die "Input format MMDDYY";
}
else
{
    ($year,$jul)=dayofyear(@ARGV[0]);
    printf "Day of year is %i %3.3i\n", $year, $jul;
}
