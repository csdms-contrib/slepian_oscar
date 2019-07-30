#!/usr/bin/perl
#
# Subroutines for interaction with SAC
#
# pands            - Calculates P and S arrival times
# getvar           - Returns a named SAC header variable
# setvar           - Updates a named SAC header variable
# hvars            - List of SAC header-variable word positions
# julianDate       - Julian day from MMDDYYYY
# leapday          - Does this date fall in a leap year?
# julianDateLocal  - Julian date from TIME
#
# Contributions by Thomas R. Kimpton
# Last modified by fjsimons-at-alum.mit.edu, 06/30/2019

# You can just say pands.pl seismogram.SAC and it'll do it
# as opposed what I now do in NEIC?.M and TMINS.M
##################################################
sub pands {
    my $gcarc = getvar($_[0],"GCARC");
    my $evdp = getvar($_[0],"EVDP");
    print $evdp;
    print $gcarc;

    @Ptime = `parrival P $evdp $gcarc`;
    @Stime = `parrival S $evdp $gcarc`;
    
    @P =  split(/\ +/,@Ptime[1]);
    @S =  split(/\ +/,@Stime[1]);
    
    setvar($_[0],"T0",@P[4]);
    setvar($_[0],"T1",@S[4]);
}
1;

##################################################
sub getvar {
    if (scalar(@_) < 1) {
	die "Need [1] SAC filename and [2] header variable name!";
    }
    %vars=hvars();
    if (exists $vars{$_[1]}){
	open(FID,$_[0]) or die "Couldn't find seismogram";
	seek(FID,$vars{$_[1]}*4,0);
        # If the variable name starts with K it is a string
        if (substr($_[1],0,1) =~ /K/){
	    # That's two words for the string variables
	    read(FID,$VARO,8) == 8 or die "Died reading$!";
	    return unpack("a8",$VARO);}
        else{
	    # That's one word for the non-string variables
	    read(FID,$VARO,4) == 4 or die "Died reading$!";
	    return unpack("f",$VARO);
            # Let's say they were byteswapped? Do this instead
	    # return unpack("f",reverse($VARO));
	}
	close(FID);
    }
    else{
	die "Header variable inexistent or unlisted";
    }
}
1;

##################################################
sub setvar {
    if (scalar(@_) < 2) {
	die "Need [1] SAC filename, [2] header variable, and [3] new value!";
    }
    %vars=hvars();
    if (exists $vars{$_[1]}){
	# Check file permissions for local overwriting without starting a new file
	open(FID,"+<$_[0]") or die "Couldn't find seismogram";
	seek(FID,$vars{$_[1]}*4,0);
        if (substr($_[1],0,1) =~ /K/){
	    # That's two words for the string variables
	    $buf = pack("a8",$_[2]);}
	else {
	    # That's one word for the non-string variables
	    $buf = pack("f",$_[2]);
	}
	print FID $buf or die "Couldn't write variable";
	close(FID);
    }
    else{
	die "Header variable inexistent or unlisted";
    }
}
1;

###############################################################################
# Meaning of LCALDA from http://www.llnl.gov/sac/SAC_Manuals/FileFormatPt2.html
# LCALDA is TRUE if DIST, AZ, BAZ, and GCARC are to be calculated from
# station and event coordinates; this is you set these to some other value,
# need to make sure that LCALDA is FALSE if you want SAC itself to find it.
# Self-made programs of course that query the header will return it anyway.
# However, I have not found of way of setting the variable to a logical yet.
###############################################################################
sub hvars {
    %hvars = (DELTA    =>   0,
	      SCALE    =>   3,
	      B        =>   5,
	      E        =>   6,
	      O        =>   7,
	      INTERNAL =>   9,
	      T0       =>  10,
	      T1       =>  11,
	      T2       =>  12,
	      T3       =>  13,
	      STLA     =>  31,
	      STLO     =>  32,
	      STEL     =>  33,
	      STDP     =>  34,
	      EVLA     =>  35,
	      EVLO     =>  36,
	      EVEL     =>  37,
	      EVDP     =>  38,
	      MAG      =>  39,
	      DIST     =>  50,
	      AZ       =>  51,
	      BAZ      =>  52,
	      GCARC    =>  53,
	      CMPAZ    =>  57,
	      CMPINC   =>  58,
	      NPTS     =>  79,
	      LCALDA   => 109,
	      KSTNM    => 110,
	      KHOLE    => 116,
	      KCMPNM   => 150,
	      KNETWK   => 152,
	      KINST    => 156,
	      );
    return %hvars;
}
1;
########################################################################	    
sub julianDate      
{
    @theJulianDate = ( 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 );
    my $mon = substr($_[0],0,2);
    my $mday = substr($_[0],2,2);
    my $year = substr($_[0],4,2);

    if ($year>38){$year="19$year"}
    if ($year<38){$year="20$year"}

    # Note that month starts with 0 but mday starts with 1
    return($year,$theJulianDate[$mon-1] + $mday + &leapDay($year,$mon,$mday));
}
1;
########################################################################
sub leapDay                  
# There is a leap year every year divisible by four except for years
# which are both divisible by 100 and not divisible by 400.
#************************************************************************
#****   Return 1 if we are after the leap day in a leap year.       *****
#************************************************************************
{                            
    my($year,$month,$day) = @_;
    
    # If the division by four has a remainder
    if ($year % 4) {
	return(0);  # Definitely not a leap year
    }
    
    # If the division by 100 does not have a remainder
    if (!($year % 100)) {            
	if ($year % 400) {           
	    return(0); # Definitely not a leap year
	}
    }

    # Watch out for these numerical/string comparisons!
    if ($month < 2) {
	return(0); # Definitely not applicable
    } elsif (($month == 2) && ($day < 29)) {
	return(0); # Definitely not applicable
    } else {
	return(1);
    }
}
1;
########################################################################	    
sub julianDateLocal
#************************************************************************
#****   Pass in the date, in seconds, of the day you want the       *****
#****   Julian date for. If your LOCALTIME returns the year-day     *****
#****   return that, otherwise figure out the Julian date.          *****
#************************************************************************
{           
    @theJulianDate = ( 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 );
    
    # This takes the input which, for juliantoday.pl is PERL's TIME...
    my($dateInSeconds) = @_;
    my($sec, $min, $hour, $mday, $mon, $year, $wday, $yday);

    # This converts the TIME into a human-understandable LOCALTIME
    ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday) =
	localtime($dateInSeconds);
    # Note that month starts with 0 but mday starts with 1
    # and yday seems to start with 0 and year 0 is 1900.
    if (defined($yday)) {
	return($yday+1);
    } else {
	# FJS could replace this with a call to julianDate on a string made from mon+1 mday year
	return($theJulianDate[$mon] + $mday + &leapDay($year+1900,$mon,$mday));
    }
}
1;
########################################################################	    
