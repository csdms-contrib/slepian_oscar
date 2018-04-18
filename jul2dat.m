function monthdayyear=jul2dat(year,serial)
% [month,day,year]=JUL2DAT(year,serial)
%
% Calculates calendar day from Julian day.
%
% Written by FJS, April 20th 1998

monthdayyear=[str2num(datestr(datenum(['01-Jan-',num2str(year)])+serial-1,5))...
      str2num(datestr(datenum(['01-Jan-',num2str(year)])+serial-1,7))...
      year];
