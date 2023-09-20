function varargout=guyotweather(doy,year,nset)
% [data,hdrv]=GUYOTWEATHER(doy,year,nset)
%
% Reads a day of Guyot Weather data as collected by the Vaisala WXT530
% weather station integrated with the Septentrio PolaRx5 receiver. 
% If there is no output requested, makes a plot of the nth header
% variable past the timestamp, i.e. the nth weather variable.
%
% INPUT:
%
% doy     Day of year (e.g., 212 is July 31 in 2019) [default: yesterday]
% year    Gregorian year (e.g., 19 or 2019 assuming post 2000)
% nset    One, two, three or four indices of the weather variables plotted [default: 5 3 4 6]
%         1 'MeanWindDirection_deg'
%         2 'MeanWindSpeed_mps'
%         3 'AirTemp_C'
%         4 'RelHum' 
%         5 'AirPress_bar'
%         6 'RainAcc_mm'
%         7 'HailAcc_hits'
%
% OUTPUT:
%
% data     A structure with the data fieldnames and values
% hdrv     A cell array with header variables 
%
% SEE ALSO:
%
% PTON2MARK
%
% TESTED ON: 
%
% 9.0.0.314360 (R2016a) - 9.1.0.441655 (R2016b)
%
% COMPILE WITH:
%
% mcc guyotweather
%
% Last modified by fjsimons-at-alum.mit.edu, 09/20/2023

% Default values are "yesterday" ...
defval('doy',dat2doy-1)
% ... and using this year's two-digit code
%defval('year',str2num(datestr(today,11)))
defval('year',str2num(datestr(now,11)))
% ... and plotting the temperature time series
defval('nset',[5 3 4 6])

% Two digits if the input wasn't
if year>2000; year=year-2000; end

% Specify the web address
urlbase='https://geoweb.princeton.edu/people/simons/PTON';
% Custom-make the last bit
urltail=sprintf('pton%3.3i0.%2.2i__ASC_ASCIIIn.mrk',doy,year);

% Four digit again for good measure 
if year<2000; year=year+2000; end

% WEBREAD or URLREAD are no different for this application
try
  dstring=urlread(sprintf('%s/%s',urlbase,urltail));
catch
  dstring=char(webread(sprintf('%s/%s',urlbase,urltail)))';
end
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
% If pos isn't what it should be, rewind, skip, move on? FSCANF?

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

% Make a plot only if there is no output requested
if nargout==0
  clf
  % Note that subplot(111) is not identical in behavior to subplot(1,1,1)
  switch length(nset)
    case {1,2}
     ah=subplot(1,1,1);
    case {3,4}
     ah(1)=subplot(2,1,1);
     ah(2)=subplot(2,1,2);
  end
  
  % Remove the weird first data point in the preceding UTC day, see DAT2DOY
  jdai=ceil(datenum(data.Timestamp-['01-Jan-',datestr(data.Timestamp(end),'YYYY')]))==doy;
  % Make title string in the original time zone
  titsdate=datestr(data.Timestamp(min(find(jdai))),1);

  % Guyot Hall STLO and STLA
  lola=guyotphysics(0);
  
  % So the data.Timestamp.Timezone evaluated to UTC and we're going to
  % change that back to New York for display only
  data.Timestamp.TimeZone='America/New_York';

  % Independent variable
  taxis=data.Timestamp(jdai);
  % Dependent variables
  defval('var1',[])
  defval('var2',[])
  defval('var3',[])
  defval('var4',[])

  % We'll be allowing up to four independent variables
  col={'r','b','m','k'};

  % Add two minutes to come to a round number on the axis
  xels=[data.Timestamp(min(find(jdai))) data.Timestamp(max(find(jdai)))+minutes(2)];
  xells=xels(1):hours(4):xels(2);
  xlabs=sprintf('Guyot Hall (%10.5f%s,%10.5f%s) %s time [HH:mm]\n%s',...
		lola(1),176,lola(2),176,nounder(data.Timestamp.TimeZone'),...
						sprintf('%s/%s',urlbase,urltail));

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  axes(ah(1))

  % Dependent variable bits. There is always at least one, this one 
  [var1,varu1]=getvars(nset(1),jdai,data,hdrv);
  plot(taxis,var1,col{1})
  str1='%s %s (UTC day %i)';
  t(1)=title(sprintf(str1,varu1,titsdate,doy));
  ylabel(varu1);
  nsets1=1; ofs=20;
  
  if length(nset)>1 
    nsets1=[1 2]; ofs=15;
    [var2,varu2]=getvars(nset(2),jdai,data,hdrv);
    str2='%s / %s %s (UTC day %i)';

    delete(t(1))
    yyaxis right
    plot(taxis,var2,col{2})
    ylabel(varu2);
    yyaxis left
    t(1)=title(sprintf(str2,varu1,varu2,titsdate,doy));

    % Make the ylabels the same color as what's being plotted
    ah(1).YAxis(1).Color=col{1};
    ah(1).YAxis(2).Color=col{2};
  end
  if  length(nset)>2
    nsets2=3;
    [var3,varu3]=getvars(nset(3),jdai,data,hdrv);

    axes(ah(2))
    plot(taxis,var3,col{3})
    str1='%s %s (UTC day %i)';
    t(2)=title(sprintf(str1,varu3,titsdate,doy));
    ylabel(varu3);
 
    if length(nset)==4
      nsets2=[3 4];
      [var4,varu4]=getvars(nset(4),jdai,data,hdrv);
      str2='%s / %s %s (UTC day %i)';
    
      delete(t(2))
      yyaxis right
      plot(taxis,var4,col{4})
      ylabel(varu4);
      yyaxis left
      t(2)=title(sprintf(str2,varu3,varu4,titsdate,doy));
    
      ah(2).YAxis(1).Color=col{3};
      ah(2).YAxis(2).Color=col{4};
    end
  end

  % Markup
  [xl(1),yels{1}]=priti(ah(1),xels,xells,xlabs,var1,var2,col,nsets1);
    
  if length(ah)==1
    % Cosmetics
    shrink(ah,1.1,1.1)
  end

  movev(t(1),range(yels{1})/ofs)
  % The below is finicky, so check by eye!
  % t(1).Positions.Units='normalized'
  moveh(t(1),0.05)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if length(ah)>1
    delete(xl(1))
    
    % Markup
    [xl(1),yels{2}]=priti(ah(2),xels,xells,xlabs,var3,var4,col,nsets2);
    
    % Cosmetics
    movev(t(2),range(yels{2})/ofs)
    moveh(t(2),0.05)
  end
  
  longticks(ah,2)
  set(ah,'FontSize',11)
  set(xl,'FontSize',11)
  
  if length(nset)==1
    figdisp([],sprintf('%3.3i_%i_%i',doy,year,nset),'-bestfit',1,'pdf')
  elseif length(nset)==2
    figdisp([],sprintf('%3.3i_%i_%i_%i',doy,year,nset),'-bestfit',1,'pdf')
  elseif length(nset)==3
    figdisp([],sprintf('%3.3i_%i_%i_%i_%i',doy,year,nset),'-bestfit',1,'pdf')
  elseif length(nset)==4
    figdisp([],sprintf('%3.3i_%i_%i_%i_%i_%i',doy,year,nset),'-bestfit',1,'pdf')
  end
end

% Cleanup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vari,varu]=getvars(indi,jdai,data,hdrv)
% The actual variable, all of it
varn=hdrv{indi+1};
% The actual variable, only what we need
vari=data.(varn)(jdai);
varu=nounder(varn);

% Cleanup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xl,yels]=priti(ah,xels,xells,xlabs,var1,var2,col,coli)

axes(ah)
% The order matters!
yels=ylim;
% Day break
hold on; plot(xells([2 2]),ylim,'-','Color',grey); hold off	
ylim(yels)
% Average value of what's being plotted which it learns from the context
hold on ; plot(xels,[1 1]*nanmean(var1),'--','Color',col{coli(1)}); hold off
if length(coli)==2
  yyaxis right
  hold on ; plot(xels,[1 1]*nanmean(var2),'--','Color',col{coli(2)}) ; hold off
end	

try
  % Latest versions
  xlim(xels)
  set(ah(1),'xtick',xells)
catch
  % Earlier versions
  xlim(datenum(xels))
  set(ah(1),'xtick',datenum(xells))
end
datetick('x','HH:MM','keepticks','keeplimits')
xl=xlabel(xlabs);
% Finicky!
movev(xl,-range(yels)/20)
moveh(xl,0.05)
