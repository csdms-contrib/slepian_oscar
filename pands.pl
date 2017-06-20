#!/usr/bin/perl
#
# Given a seismogram for which GCARC and EVDP is defined, 
# puts down the P and S arrival time from IASP91 as the 
# T0 and T1 header variable
#
# INPUT:
#
# [1] Name of seismogram

use saclib;

pands(@ARGV[0]);
