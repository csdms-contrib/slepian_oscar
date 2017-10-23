function varargout=gps2median(fname,intvm,method,ifwrite,offsetm,utmtrue)
% [tims,meds,tor,mor]=GPS2MEDIAN(fname,intvm,method,ifwrite,offsetm,utmtrue)
%
% Converts an ASCII file with GPS position and times into another ASCII
% file that reports medians of the accuracy, defined as the mean
% squared deviation, with respect to a location known in true UTM.
% 
% DATA FILE FORMAT IN DECIMAL DEGREES LATITUDE AND LONGITUDE:
%
% ladecimal,+lodecimal,year/mo/dy,hh:mm:ss,
% 40.345266,-74.655144,2015/11/25,00:54:01
%
% INPUT:
%
% fname    Complete path and filename string [default: 'HargravsGPS_60cx']
% intvm    Desired reporting interval (in minutes) [default: 5]
% method   1 Exact mapping by binning to intervals (exact, slow!) [default]
%          2 Interpolated to sequential intervals (approximate, fast!)
% ifwrite  1 Writes another ASCII file with these data in DATENUM format
%          0 Does not write a new file [default]
% offsetm  At which minute in the data set do we begin [default: 0]
% utmtrue  True UTM easting and northing of the site whose accuracy we verify
%
% OUTPUT:
%
% tims     The midpoint times of the intervals [in DATENUM format]
%          compared to the first (potentially offset) sample
%          -> For method 1, inherits non-equal time increments from the data
%          -> For method 2, forces equal time increments except for large gaps
% meds     The median accuracy values over those intervals
%          -> For method 1, will get a long vector, potentially with NaNs
%          -> For method 2, will get a short vector, without any Nans
% tor      The original time axis (with respect to offsetm)
% mor      The original accuracy values (with respect to offsetm)
%
% EXAMPLE:
%
% [times1,meds1]=gps2median([],[],1);
% [times2,meds2]=gps2median([],[],2);
% 
% Last modified by fjsimons-at-alum.mit.edu, 02/11/2017

% This is very specifically, for Hargraves Hall, on Princeton Campus
% Suply the true location in UTM of the same zone
defval('utme', 529286.6939);
defval('utmn',4466132.8936);

% Daylight Saving Time ends in North America at this local time
dstend=datenum(2015,11,1,2,0,0);

% Default filename, interval, method, write-flag and offset
defval('fname','HargravesGPS_60cx')
defval('intvm',5)
defval('method',1)
defval('ifwrite',0)
defval('offsetm',0)

% BEGIN READING AND INTERPRETING OF THE DATA FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the data, open the file first
fid=fopen(fname);

% This creates a cell array with one cell per each column of the file 
h=textscan(fid,'%f %f %s %s','Delimiter',',');

% The actual GPS readings, converted from decimal degrees to UTM coordinates
[gpse,gpsn,utmz]=deg2utm(h{1},h{2});

% Calculate ACCURACY in UTM coordinates; this now is the primary variable
gpsa=sqrt([gpse-utme].^2+[gpsn-utmn].^2);

% Convert the time into DATENUM format and order chronologically
gpst=flipud(datenum(strcat(h{3},h{4}),'yyyy/mm/ddHH:MM:SS'));

% Might not be the end of the world, but should look into it!
if length(gpst)~=length(unique(gpst))
  % They could have been poorly sorted, and thus escaped sort | uniq detection
  warning('Duplicate times detected');
end

% Turn into GMT as the weather station respected DST
% Check out this condition, which depends on the sampling rate and the
% precision of the representation of DATENUM and DATESTR, which isn't great
cond=min(find([gpst>((dstend-datenum(0,0,0,0,round(median(diff(gpst))*60*24),1)))]));
gpst(1:cond)=gpst(1:cond)-datenum(0,0,0,1,0,0);
% And obviously if we're into Spring again this will require adjustment
disp(sprintf('First date %s and last date %s',datestr(gpst(1)),datestr(gpst(end))))
% You must reference to the first sample (thus zero) for subdivision
gpst=[gpst-gpst(1,1)];

% Close the data file
fclose(fid);
% END READING AND INTERPRETING OF THE DATA FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BEGIN MEDIAN MAPPING OF THE DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define where the beginining of the data set is as a fraction of a day
beg=offsetm/24/60;
% Define the length interval of interest as a fraction of a day
intv=intvm/24/60;
% How many times will this interval - potentially - be repeated?
ntms=ceil([max(gpst)-beg]/intv);
% Initialize the medians vector
meds=nan(ntms,1);
% Initialize the medians plot line handles
medp=nan(ntms,1);

% Might as well cut the data off altogether if there is an offset
% Note that this is necessary for method 2
gpsa =gpsa(gpst>=beg);
gpst=gpst(gpst>=beg);

% Now do the actual calculation
switch method 
 case 1
  %% METHOD 1
  % The way of the "for" loop - this is very slow
  more off
  tic
  ent=beg+intv;

  % Go through the time intervals
  for index=1:ntms
    % Report in minutes but only every so often
    if mod(index-1,ntms/10)==0
      disp(sprintf('Working between minutes %5.5i and %5.5i',...
		   floor(beg*60*24),ceil(ent*60*24)))
    end
    % Use NANMEDIAN in case there are NaNs in the data vector
    meds(index)=nanmedian(gpsa(gpst>=beg & gpst<ent));
    % Update the beginning and the end
    beg=ent;
    ent=ent+intv; 
  end
  toc
  % Output - add the time reference and the offset back in
  meds=meds';
  tims=[intv*[1:ntms]-intv/2]+offsetm/24/60;
 case 2
  % METHOD 2
  % There has to be a quicker way!
  tic
  % Figure out the median sampling intervals
  newdt=median(diff(gpst));

  % Report in seconds if you must
  disp(sprintf('The median sampling interval in seconds is %f',...
	       newdt*60*60*24))
  % Snap every value to the nearest increment of newdt seconds, this is better for data drops 
  newt=round(gpst/newdt)*newdt;
  
  % Could consider reporting norm([gpst-newt]) to get a feel for the interpolation
  
  % Interpolate the data to the median sampling intervals
  gpsai=interp1(gpst,gpsa,newt);

  % Rearrange them by sets of intv at a time, or nearly so, almost all
  multp=round(intv/newdt);
  % Report in samples if you must
  disp(sprintf('The number of samples taken together consecutively is %i',...
	       multp))
  % This is roughly how many of those will find into the vector that you have
  multc=floor(length(gpsai)/multp);
  % Could have saved us the initialization. Compute the medians
  meds=nanmedian(reshape(gpsai(1:multp*multc),multp,multc),1);
  % But... there's a couple you might have missed, so add their medians also
  meds=[meds nanmedian(gpsai(multp*multc+1:end))];
  toc
  % From this you can learn at which time "meds" should be quoted
  tims=newt([round(multp/2):multp:multp*multc ...
           multp*multc+round([length(gpsai)-multp*multc]/2)])';
end
% END MEDIAN MAPPING OF THE DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Output to a new file
if ifwrite==1
  fid=fopen(sprintf('%s_%i_%i.txt',...
      strtok(fname,'.'),intvm,method),'w');
  fprintf(fid,'%9.3f %9.6f\n',[meds ; tims]);
  fclose(fid);
end

% Output, if so desired
varns={tims,meds,gpst,gpsa};
varargout=varns(1:nargout);
