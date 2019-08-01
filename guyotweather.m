function varargout=guyotweather(jday,year)
% [data,hdrv]=GUYOTWEATHER(jday,year)
%
% Reads a day of Guyot Weather data as collected by the Vaisala WXT530
% weather station integrated with the Septentrio PolaRx5 receiver
%
% INPUT:
%
% jday    Julian day (e.g., 212 is July 31 in 2019)
% year    Gregorian year (e.g., 19 or 2019 assuming post 2000)
%
% OUTPUT:
%
% data     A structure with the data fieldnames and values
% hdrv     A cell arraywith header variables 
%
% SEE ALSO:
%
% PTON2MARK
%
% TESTED ON: 
%
% 9.0.0.314360 (R2016a) - need DATETIME
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

% WEBREAD or URLREAD are no different for this application
dstring=urlread(sprintf('%s/%s',urlbase,urltail));
% Get rid of the header
try
  % How many characters for the header?
  hdrlen=103; 
  hdrv=strsplit(dstring(1,1:hdrlen));
catch
  % Alternatively, and, equivalently:
  % How many fields for the header?
  hdrfld=8;
  [hdrc,hdrlen]=textscan(dstring,'%s',hdrfld); 
  hdrv=hdrc{1}';
end
% Read the rest later; nonexisting integers are zero but nonexisting
% floats are NaN so make them all floats past the initial string
fmt='%s %f %f %f %f %f %f %f';
drest=textscan(dstring(1,hdrlen+1:end),fmt);

% Replace the T by a space and remove the Z in the date string
drest{1}=strrep(drest{1},'T',' ');
drest{1}=strrep(drest{1},'Z','');
% The last thing is a time zone which TEXTSCAN cannot handle as a DATETIME,
% the error MATLAB:textscan:TimeZoneSupport message was, when I tried the %D
% format instead of a plan string:: The format string 'YYYY-MM-ddTHH:mm:ssZ'
% contains a timezone field. TEXTSCAN does not support reading
% timezones. Use %q to read the data as strings and create a datetime array
% using DATETIME with the 'TimeZone' parameter.  Hence, DATETIME must exist!
% Only past a certain release...
drest{1}=datetime(datestr(drest{1}),'TimeZone','UTC');

% Make a structure - as in DEFSTRUCT and elsewhere
sinput=cell(2,length(hdrv));
sinput(1,:)=hdrv;
sinput(2,:)=drest;
data=struct(sinput{:});

% Output, as much as needed, but no more
varns={data,hdrv};
varargout=varns(1:nargout);

% DON'T FORGET TO RSYCN LEMAITRE FROM CRESSIDA SUCH THAT CRESSIDA CAN BE
% DECOMMISSIONED

