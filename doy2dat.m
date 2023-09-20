function monthdayyear=doy2dat(year,serial)
% [month,day,year]=DOY2DAT(year,serial)
%
% Calculates calendar date from day of year.
%
% INPUT:
%
% year    The Gregorian year
% serial  The day of year
%
% OUTPUT:
%
% month   The corresponding month
% day     The corresponding day
% year    The corresponding year
% 
% TESTED ON:
%
% 8.3.0.532 (R2014a) and 9.0.0.314360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 09/20/2023

% Default values are today!
defval('year',str2num(datestr(today,10)))
defval('serial',...
       dat2doy(str2num(datestr(today,5)),...
	       str2num(datestr(today,7)),...
	       str2num(datestr(today,10))))

% Do the calculation. Seems a little overcomplicated, now eleven years later.
monthdayyear=[str2num(datestr(datenum(['01-Jan-',num2str(year)])+serial-1,5))...
	      str2num(datestr(datenum(['01-Jan-',num2str(year)])+serial-1,7))...
	      year];

