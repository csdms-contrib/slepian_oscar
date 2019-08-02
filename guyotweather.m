function varargout=guyotweather(jday,year,n)
% [data,hdrv]=GUYOTWEATHER(jday,year,n)
%
% Reads a day of Guyot Weather data as collected by the Vaisala WXT530
% weather station integrated with the Septentrio PolaRx5 receiver. 
% If there is no output requested, makes a plot of the nth header
% variable past the timestamp, i.e. the nth weather variable.
%
% INPUT:
%
% jday    Julian day (e.g., 212 is July 31 in 2019) [default: yesterday]
% year    Gregorian year (e.g., 19 or 2019 assuming post 2000)
% n       Index of the weather variable to plot 
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
% 9.0.0.314360 (R2016a) - 9.1.0.441655 (R2016b)
%
% Last modified by fjsimons-at-alum.mit.edu, 08/02/2019

% Default values are "yesterday" ...
defval('jday',dat2jul-1)
% ... and using this year's two-digit code
defval('year',str2num(datestr(today,11)))
% ... and plotting the temperature time series
defval('n',3)

% Two digits if the input wasn't
if year>2000; year=year-2000; end

% Specify the web address
urlbase='http://geoweb.princeton.edu/people/simons/PTON/';
% Custom-make the last bit
urltail=sprintf('pton%3.3i0.%2.2i__ASC_ASCIIIn.mrk',jday,year);

% Four digit again for good measure 
if year<2000; year=year+2000; end

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
[drest,pos]=textscan(dstring(1,hdrlen+1:end),fmt);
% If pos isn't what it should be, rewind, skip, move on?

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

% Make a plot
if nargout==0
  clf
  % Take care of the weird first data point in the different UTC day, see DAT2JUL
  jdai=ceil(datenum(data.Timestamp-['01-Jan-',datestr(data.Timestamp(1),'YYYY')]))==jday;
  % So the data.Timestamp.Timezone evaluated to UTC and we're going to
  % change that back to New York for display only
  data.Timestamp.TimeZone='America/New_York';
  plot(data.Timestamp(jdai),data.(hdrv{n+1})(jdai),'k')
  ah=gca;
  t1=title(sprintf('%s (%s) UTC',jday,year));
keyboard
  t=title(sprintf('%s %s',nounder(hdrv{n+1}),...
      datestr(data.Timestamp(min(find(jdai))),1)));
  xels=[data.Timestamp(min(find(jdai))) data.Timestamp(max(find(jdai)))+minutes(2)];
  xlim(xels)
  xells=xels(1):hours(4):xels(2);
  set(ah,'xtick',xells)
  yels=ylim;
  hold on
  % Day break
  plot(xells([2 2]),ylim,'-','Color',grey)
  ylim(yels)
  % Average value of what's being plotted which it learns from the context
  plot(xels,[1 1]*nanmean(ah.Children(2).YData),'-','Color',grey)
  hold off
  datetick('x','HH:MM','keepticks','keeplimits')
  xlabel(sprintf('%s time',nounder(data.Timestamp.TimeZone')))
  longticks(ah,2)
  set(ah,'FontSize',12)
  % Cosmetics
  shrink(ah,1.1,1.1)
  movev(t,range(yels)/20)
end

keyboard

% DON'T FORGET TO RSYCN LEMAITRE FROM CRESSIDA SUCH THAT CRESSIDA CAN BE
% DECOMMISSIONED

