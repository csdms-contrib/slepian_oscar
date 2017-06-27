function varargout=readCMT(fname,dirn,tbeg,tend,mblo,mbhi,depmin,depmax)
% [QUAKES,Mw]=readCMT(fname,dirn,tbeg,tend,mblo,mbhi,depmin,depmax)
%
% Reads in CMT catalog of events (default format is that of jan76_dec13.ndk).
%
% INPUT:
%
% fname          CMT file name (www.globalcmt.org) [jan76_feb10.ndk]
% dirn           Directory of the .ndk file [IFILES/CMT]
% tbeg, tend     Serial datenumbers with the time interval of interest
%                If CMT catalog is not known to be chronological then
%                this should be set to infinity
% mblo, mbhi     Body-wave magnitude interval of interest
% depmin,depmax  Depth range of interest     
%
% OUTPUT:     
%
% QUAKES         [time depth lat lon Mtensor]
% Mw             All the scalar seismic moments
%
% EXAMPLES:
%
% readCMT('demo1') % Quakes between 1977/01/01 and 1985/03/31
% readCMT('demo2') % Chao & Gross earthquakes excluding shallow depth for '77-'80
% readCMT('demo3') % Quakes between 1977/01/01 and present
%
% SEE ALSO:
%
% CMTSOL
%
% Last modified by efwelch@princeton.edu, 06/25/2010
% Correction supplied by Xiaojun Chen (Yale), 04/14/2014
% Last modified by fjsimons-at-alum.mit.edu, 11/29/2015

% Check to see if it's a demo case
if isempty(strfind(fname,'demo'))
  % Assign default values
  defval('fname','jan76_dec13.ndk')
  defval('dirn',fullfile(getenv('IFILES'),'CMT'))
  defval('tbeg',0)
  defval('tend',Inf)
  defval('mblo',0)
  defval('mbhi',Inf)
  defval('depmin',0)
  defval('depmax',Inf)
  
  % Build filename
  fname=fullfile(dirn,sprintf(fname));
  disp(sprintf('Loading %s',fname))

  % Number of earthquakes (each event has 405 bytes associated with it)
  Nquakes=fsize(fname)/405;

  % Get file ID 
  fid=fopen(fname);

  % Initialize array for event time, location, moment tensor
  Mw=nan(Nquakes,1);
  QUAKES=nan(Nquakes,10);
  
  % Number of quakes not used (for resizing preallocated QUAKES array) 
  nogood=0;

  % Loop through CMT file
  for i=1:Nquakes
    % First line %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    line=fgetl(fid);
    mb=str2num(line(49:51));
    time=datenum(line(6:26));
    
    % Skip second line %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fgetl(fid);
    
    % Third line %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    line = fgetl(fid);
    depth = str2num(line(49:54));
    
    % Check if it's too late
    if (time > tend )
      nogood=nogood+(Nquakes-i+1);
      break
      
    elseif (time >= tbeg && depth <=depmax && depth >= depmin ...
	    && mb>= mblo && mb<= mbhi)
      
      % Finish getting 3rd line numbers (this could be moved above if to
      % equip this code to condition on lat and lon but since we are
      % concerned with global changes let's hold off on this to improve speed.
      lat=str2num(line(24:29));
      lon=str2num(line(36:42));
      
      % Fourth line %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      line=fgetl(fid);
      exponent=str2num(line(1:2));
      
      % Convert line to array of moment tensor elements and uncertainties 
      Mline=str2num(line(3:80));
      
      % Ignore the uncertainties
      Mtensor=Mline(1:2:11)*10^exponent;
      
      % Calculate the scalar seismic moment from the moment tensor components
      Mw(i-nogood)=2/3/log(10)*...
	 log(1/sqrt(2)*sqrt(Mtensor(1)^2+Mtensor(2)^2+Mtensor(3)^2+...
			    2*(Mtensor(4)^2)+2*(Mtensor(5)^2)+2*(Mtensor(6)^2)))-10.7;  
      
      % Store in the output array
      QUAKES(i-nogood,:)=[time depth lat lon Mtensor];
      fgetl(fid);
      
      % If earthquakes don't satisfy condition read 4th and 5th line to prepare
      % the pointer to read the next quake and count it as not used
    else
      nogood=nogood+1;
      fgetl(fid);
      fgetl(fid);
    end
    
    % Show progress
    if mod(i,1000)==0
      disp(sprintf('Have read %5.5d of %d events from CMT catalog',i,Nquakes));
    end
  end

  fclose(fid);

  % Resize array to correct output
  QUAKES=QUAKES(1:Nquakes-nogood,:);
  Mw=Mw(1:Nquakes-nogood,:);
elseif strcmp(fname,'demo1')
  % pick out Chao & Gross earthquakes including those at shallow depth  
  defval('dirn',fullfile(getenv('IFILES'),'CMT'))
  fname=fullfile(dirn,'quakes77_85.mat');
  if exist(fname,'file')==2
    load(fname)
  else
    QUAKES=readCMT([],[],datenum('1977/01/01 00:00:01'),...
		   datenum('1985/03/31 00:00:01'),[],[],[],[]);
    save(fname,'QUAKES')
  end
elseif strcmp(fname,'demo2')
  % Pick out C&G earthquakes excluding those at shallow depth during '77-'80
  defval('dirn',fullfile(getenv('IFILES'),'CMT'))
  fname=fullfile(dirn,'quakes77_85except.mat');
  if exist(fname,'file')==2
    load(fname)
  else
    include=readCMT([],[],datenum('1977/01/01 00:00:01'),...
		    datenum('1985/03/31 00:00:01'),5.5,[],[],[]);

    exclude=readCMT([],[],datenum('1977/01/01 00:00:01'),...
		    datenum('1981/01/01 00:00:01'),5.5,6.5,0,100);

    xcount=1;
    for j=1:size(include,1);
      if xcount>size(exclude,1)
	break
      elseif include(j,1)==exclude(xcount,1)
	include(j,:)=0; xcount=xcount+1;
      end
    end
    QUAKES=include(include(:,1)~=0,:);

    save(fname,'QUAKES')
  end
elseif strcmp(fname,'demo3')
  % Get all earthquakes from CMT catalog for 1977-2010 - or beyond!
  defval('dirn',fullfile(getenv('IFILES'),'CMT'))
  fname=fullfile(dirn,'quakes77_2010.mat');
  if exist(fname,'file')==2
    load(fname)
  else
    QUAKES=readCMT('jan76_dec13.ndk',[],datenum('1977/01/01 00:00:01'),...
		   [],[],[],[],[]);
    save(fname,'QUAKES')
  end
elseif strcmp(fname,'demo4')
  % Get all earthquakes from CMT catalog for '77-2010 except the
  % ones C&G claim to exclude in CG (1987)
  defval('dirn',fullfile(getenv('IFILES'),'CMT'))
  fname=fullfile(dirn,'quakes77_2010except.mat');
  if exist(fname,'file')==2
    load(fname)
  else
    pre=readCMT('demo2');
    post=readCMT('jan76_dec13.ndk',[],datenum('1985/03/31 00:00:01'),...
		 [],[],[],[],[]);
    QUAKES=vertcat(pre,post);
    save(fname,'QUAKES')
  end
end

% Provide output if requested
varns={QUAKES,Mw};
varargout=varns(1:nargout);

