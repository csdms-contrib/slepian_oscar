#!/usr/bin/perl
# Rewrites a named SAC header variable
#
# INPUT:
#
# [1] SAC file name
# [2] SAC header variable name, e.g.
#       GCARC
# [3] New value to be written into the file
#
# Last modified by fjsimons-at-alum.mit.edu, 10/13/2020

use saclib;

setvar(@ARGV[0],@ARGV[1],@ARGV[2]);
