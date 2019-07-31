function julday=dat2jul(month,day,year)
% julday=DAT2JUL(month,day,year)
%
% Calculates Julian day from calendar day 
%
% INPUT:
%
% month   The month
% day     The day
% year    The year
% 
% OUTPUT:
%
% serial  The corresponding Julian day
%
% TESTED ON:
%
% 8.3.0.532 (R2014a) and 9.0.0.314360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 07/31/2019

% Default values are today!
defval('month',str2num(datestr(today, 5)))
defval('day',  str2num(datestr(today, 7)))
defval('year', str2num(datestr(today,10)))

% Do the calculation!
julday=datenum(year,month,day)-datenum(['01-Jan-',num2str(year)])+1;
