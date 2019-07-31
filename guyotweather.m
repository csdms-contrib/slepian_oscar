function guyotweather(jday,year)
% GUYOTWEATHER(jday,year)
%
% Reads a day of Guyot Weather data as collected by the Vaisala WXT530
% weather station integrated with the Septentrio PolaRx5 receiver
%
% INPUT:
%
% jday    Julian day (e.g., 212 is July 31 in 2019)
% year    Gregorian year (e.g., 19 or 2019 assuming post 2000))
%
% SEE ALSO:
%
% PTON2MARK
%
% TESTED ON: 
%
% 9.0.0.314360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 07/31/2019

% Default values are "yesterday" using two-digit year...
defval('jday',dat2jul-1)
defval('year',str2num(datestr(today,11)))

if year>2000
  year=year-2000;
end

% Specify the web address
urlbase='http://geoweb.princeton.edu/people/simons/PTON/';
% Custom-make the last bit
urltail=sprintf('pton%3.3i0.%2.2i__ASC_ASCIIIn.mrk',jday,year);

% This requires URLREAD in older versions of MATLAB 
data=webread(sprintf('%s/%s',urlbase,urltail));

% DON'T FORGET TO RSYCN LEMAITRE FROM CRESSIDA SUCH THAT CRESSIDA CAN BE DECOMMISSIONED
keyboard

