#!/usr/bin/perl
# Rewrites a named SAC header variable
#
# INPUT:
#
# [1] SAC file name
# [2] SAC header variable name, e.g.
#       GCARC
# [3] New value to be written into the file

use saclib;

setvar(@ARGV[0],@ARGV[1],@ARGV[2]);
