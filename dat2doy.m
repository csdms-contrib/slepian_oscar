function doy=dat2doy(month,day,year)
% doy=DAT2DOY(month,day,year)
%
% Calculates day of year from calendar date.
%
% INPUT:
%
% month   The month (a number)
% day     The day (a number)
% year    The Gregorian year (a number)
% 
% OUTPUT:
%
% serial  The corresponding day of year
%
% TESTED ON:
%
% 8.3.0.532 (R2014a) and 9.0.0.314360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 09/20/2023

% Default values are today!
%defval('month',str2num(datestr(today, 5)))
defval('month',str2num(datestr(now, 5)))
%defval('day',  str2num(datestr(today, 7)))
defval('day',str2num(datestr(now, 7)))
%defval('year', str2num(datestr(today,10)))
defval('year', str2num(datestr(now,10)))

% Do the calculation!
doy=datenum(year,month,day)-datenum(['01-Jan-',num2str(year)])+1;
