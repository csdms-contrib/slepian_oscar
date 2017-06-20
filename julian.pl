#!/usr/bin/perl
#
# Computes Julian date for a date string
#
# Last modified by fjsimons-at-alum.mit.edu, 08.03.2006 

use saclib;

if ($#ARGV == -1) {
    die "Input format MMDDYY";
}
else
{
    ($year,$jul)=julianDate(@ARGV[0]);
    printf "Julian date is %i %3.3i\n", $year, $jul;
}




