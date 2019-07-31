function monthdayyear=jul2dat(year,serial)
% [month,day,year]=JUL2DAT(year,serial)
%
% Calculates calendar day from Julian day.
%
% INPUT:
%
% year    The Gregorian year
% serial  The Julian day
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
% Last modified by fjsimons-at-alum.mit.edu, 07/31/2019

% Default values are today!
defval('year',str2num(datestr(today,10)))
defval('serial',...
       dat2jul(str2num(datestr(today,5)),...
	       str2num(datestr(today,7)),...
	       str2num(datestr(today,10))))

% Do the calculation. Seems a little overcomplicated, now eleven years later.
monthdayyear=[str2num(datestr(datenum(['01-Jan-',num2str(year)])+serial-1,5))...
	      str2num(datestr(datenum(['01-Jan-',num2str(year)])+serial-1,7))...
	      year];

