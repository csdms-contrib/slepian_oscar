function julday=dat2jul(month,day,year)
% julday=DAT2JUL(month,day,year)
%
% Calculates Julian day from calendar day 
%
% INPUT:
%
% month   The month (a number)
% day     The day (a number)
% year    The year (a number)
% 
% OUTPUT:
%
% serial  The corresponding Julian day
%
% TESTED ON:
%
% 8.3.0.532 (R2014a) and 9.0.0.314360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 02/21/2021

% Default values are today!
%defval('month',str2num(datestr(today, 5)))
defval('month',str2num(datestr(now, 5)))
%defval('day',  str2num(datestr(today, 7)))
defval('day',str2num(datestr(now, 7)))
%defval('year', str2num(datestr(today,10)))
defval('year', str2num(datestr(now,10)))

% Do the calculation!
julday=datenum(year,month,day)-datenum(['01-Jan-',num2str(year)])+1;
