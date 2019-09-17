function varargout=readCMT(fname,dirn,tbeg,tend,mblo,mbhi,depmin,depmax)
% [QUAKES,Mw]=readCMT(fname,dirn,tbeg,tend,mblo,mbhi,depmin,depmax)
%
% Reads in CMT earthquake catalog in default format of www.globalcmt.org, 
% http://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/jan76_dec13.ndk
%
% INPUT:
%
% fname          CMT filename in .ndk format [default: jan76_feb10.ndk]
% dirn           Directory containing the CMT file [default: $IFILES/CMT]
% tbeg, tend     Serial datenumbers [e.g. datenum('1985/03/31 00:00:01')]
%                with the time interval of interest 
%                If CMT catalog is not known to be chronological then
%                tbeg should be set to 0 and tend should be set to Inf
% mblo, mbhi     Body-wave moment magnitude interval of interest
% depmin,depmax  Depth range of interest [km]
%
% OUTPUT:     
%
% QUAKES         [time depth lat lon Mtensor]
% Mw             All the scalar seismic moments
%
% EXAMPLES:
%
% readCMT('demo1') % Chao & Gross quakes between 1977/01/01 and 1985/03/31
% readCMT('demo2') % Chao & Gross quakes excluding shallow ones for '77-'80
% readCMT('demo3') % Quakes since 1977/01/01 and present
% readCMT('demo4') % Quakes since 1977/01/01 excluding shallow ones as demo2
%
% SEE ALSO:
%
% CMTSOL, SMOMENT
%
% NOTES:
%
% The monthly CMT solutions are here:
% http://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/NEW_MONTHLY/
% And the quick (not-final) ones are here:
% http://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/NEW_QUICK/qcmt.ndk
%
% We refer to Chao and Gross 1987, doi: 10.1111/j.1365-246X.1987.tb01659.x
%
% Note that this is slow, see CMTSOL for how to use textscan, which is
% much faster. 
%
% Last modified by efwelch@princeton.edu, 06/25/2010
% Correction supplied by Xiaojun Chen (Yale), 04/14/2014
% Last modified by fjsimons-at-alum.mit.edu, 09/17/2019

% Check to see if it's a demo case
if isempty(strfind(fname,'demo'))
  % Assign default catalog filename
  defval('fname','jan76_dec17.ndk')
  % You will need to make sure $IFILES returns something, or else change
  defval('dirn',fullfile(getenv('IFILES'),'CMT'))
  % Assign default catalog search parameters
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
      % Get two more lines!
      fgetl(fid);
      fgetl(fid);
    end
    
    % Show progress
    if mod(i,2000)==0
      disp(sprintf('Have read %5.5d of %d events from CMT catalog',i,Nquakes));
    end
  end

  % Sew it shut
  fclose(fid);

  % Resize array to correct output
  QUAKES=QUAKES(1:Nquakes-nogood,:);
  Mw=Mw(1:Nquakes-nogood,:);

elseif strcmp(fname,'demo1')
  % Pick out Chao & Gross earthquakes including those at shallow depth
  defval('dirn',fullfile(getenv('IFILES'),'CMT'))
  fname=fullfile(dirn,'quakes77_85.mat');
  if exist(fname,'file')==2
    load(fname)
  else
    [QUAKES,Mw]=readCMT([],[],datenum('1977/01/01 00:00:01'),...
		         datenum('1985/03/31 00:00:01'),[],[],[],[]);
    save(fname,'QUAKES','Mw')
  end
elseif strcmp(fname,'demo2')
  % Pick out C&G earthquakes excluding those at shallow depth during '77-'80
  defval('dirn',fullfile(getenv('IFILES'),'CMT'))
  fname=fullfile(dirn,'quakes77_85except.mat');
  if exist(fname,'file')==2
    load(fname)
  else
    [include,Mwin]=readCMT([],[],datenum('1977/01/01 00:00:01'),...
		          datenum('1985/03/31 00:00:01'),5.5,[],[],[]);

    [exclude,Mwex]=readCMT([],[],datenum('1977/01/01 00:00:01'),...
		          datenum('1981/01/01 00:00:01'),5.5,6.5,0,100);

    xcount=1;
    for j=1:size(include,1);
      if xcount>size(exclude,1)
	break
      elseif include(j,1)==exclude(xcount,1)
	include(j,:)=0; 
	Mwin(j)=0; 
	xcount=xcount+1;
      end
    end
    QUAKES=include(include(:,1)~=0,:);
    Mw=Mwin(Mwin~=0,:);
    save(fname,'QUAKES','Mw')
  end
elseif strcmp(fname,'demo3')
  % Get all earthquakes from CMT catalog for 1977 to however long you have it
  defval('dirn',fullfile(getenv('IFILES'),'CMT'))
  fname=fullfile(dirn,'quakes77_2013.mat');
  if exist(fname,'file')==2
    load(fname)
  else
    [QUAKES,Mw]=readCMT('jan76_dec13.ndk',[],datenum('1977/01/01 00:00:01'),...
		   [],[],[],[],[]);
    save(fname,'QUAKES','Mw')
  end
elseif strcmp(fname,'demo4')
  % Get all earthquakes from CMT catalog for '77-2010 except the
  % ones C&G claim to exclude in C&G (1987)
  defval('dirn',fullfile(getenv('IFILES'),'CMT'))
  fname=fullfile(dirn,'quakes77_2010except.mat');
  if exist(fname,'file')==2
    load(fname)
  else
    [pre,Mwpre]=readCMT('demo2');
    [post,Mwpost]=readCMT('jan76_dec13.ndk',[],datenum('1985/03/31 00:00:01'),...
		 [],[],[],[],[]);
    QUAKES=vertcat(pre,post);
    Mw=vertcat(Mwpre,Mwpost);
    save(fname,'QUAKES','Mw')
  end
end

% Provide output if requested
varns={QUAKES,Mw};
varargout=varns(1:nargout);
