#!/usr/bin/perl
# Returns a named SAC header variable.
#
# INPUT:
#
# [1] SAC file name
# [2] SAC header variable name, e.g.
#       GCARC
#
# Last modified by fjsimons-at-alum.mit.edu, 10/13/2020

use saclib;

print getvar(@ARGV[0],@ARGV[1]),"\n";
