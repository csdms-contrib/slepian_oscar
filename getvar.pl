#!/usr/bin/perl
# Returns a named SAC header variable.
#
# INPUT:
#
# [1] SAC file name
# [2] SAC header variable name, e.g.
#       GCARC

use saclib;

print getvar(@ARGV[0],@ARGV[1]),"\n";
