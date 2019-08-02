function varargout=guyotweather(jday,year,nset)
% [data,hdrv]=GUYOTWEATHER(jday,year,nset)
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
% nset    One or two indices of the weather plot variable [default: 3, for AirTemp_C]
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
defval('nset',3)

% Guyot Hall STLO and STLA
lola=guyotphysics(0);

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
  % Note that subplot(111) is not identical in behavior to subplot(1,1,1)
  ah=subplot(1,1,1);
  % Remove the weird first data point in the preceding UTC day, see DAT2JUL
  jdai=ceil(datenum(data.Timestamp-['01-Jan-',datestr(data.Timestamp(end),'YYYY')]))==jday;
  % Make title string in the original time zone
  titsdate=datestr(data.Timestamp(min(find(jdai))),1);

  % So the data.Timestamp.Timezone evaluated to UTC and we're going to
  % change that back to New York for display only
  data.Timestamp.TimeZone='America/New_York';

  % Independent variable
  taxis=data.Timestamp(jdai);

  % Dependent variable bits
  varn1=hdrv{nset(1)+1};
  varu1=nounder(varn1);
  var1=data.(varn1)(jdai);
  col1='k';
  str1='%s %s (UTC day %i)';

  if length(nset)==1
    plot(taxis,var1,col1)
    t=title(sprintf(str1,varu1,titsdate,jday));
    ylabel(varu1);
  elseif length(nset)==2
    % Dependent variable bits
    varn2=hdrv{nset(2)+1};
    var2=data.(varn2)(jdai);
    varu2=nounder(varn2);
    col2='b';
    str2='%s / %s %s (UTC day %i)';

    plot(taxis,var1,col1)
    ylabel(varu1);
    yyaxis right
    plot(taxis,var2,col2)
    ylabel(varu2);
    yyaxis left
    t=title(sprintf(str2,varu1,varu2,titsdate,jday));
  else
     error('Supply at most TWO index variables for the weather plot!')
  end
  % Add two minutes to come to a round number on the axis
  xels=[data.Timestamp(min(find(jdai))) data.Timestamp(max(find(jdai)))+minutes(2)];
  xlim(xels)
  xells=xels(1):hours(4):xels(2);
  set(ah,'xtick',xells)
  yels=ylim;
  % Day break
  hold on; plot(xells([2 2]),ylim,'-','Color',grey); hold off	
  ylim(yels)
  % Average value of what's being plotted which it learns from the context
  hold on ; plot(xels,[1 1]*nanmean(var1),'--','Color',col1); hold off
  if length(nset)==2
    yyaxis right
    hold on ; plot(xels,[1 1]*nanmean(var2),'--','Color',col2) ; hold off
  end	
  datetick('x','HH:MM','keepticks','keeplimits')
  xlabel(sprintf('Guyot Hall (%10.5f%s,%10.5f%s) %s time',...
		 lola(1),176,lola(2),176,nounder(data.Timestamp.TimeZone')))
  longticks(ah,2)
  set(ah,'FontSize',12)
  % Cosmetics
  shrink(ah,1.1,1.1)
  movev(t,range(yels)/20)
end

% DON'T FORGET TO RSYNC LEMAITRE FROM CRESSIDA SUCH THAT CRESSIDA CAN BE
% DECOMMISSIONED

if length(nset)==1
   figdisp([],sprintf('%i_%i_%i',jday,year,nset),'-bestfit',1,'pdf')
elseif length(nset)==2
   figdisp([],sprintf('%i_%i_%i_%i',jday,year,nset),'-bestfit',1,'pdf')
end
