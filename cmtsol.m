function varargout=cmtsol(cmtcode,fname)
% earthquake=CMTSOL(cmtcode,fname);
%
% Reads a CMT-event file (.ndk format) to create structure array of 
% information pertaining to (a) particular event(s).
%
% INPUT: 
% 
% cmtcode        The unique CMT-event identifier, or: 'all'. 
%                Older events have 8-character names (e.g. 'C010676A') 
%                newer events have 16-character names (e.g. 'C200512311214A')
% fname          The name string of the .ndk formatted CMT-events file
% 
% OUTPUT:
%
% earthquake     A structure for the requested event (if not all)
%                containing the following fields:
%      DateTime       A string containing the time of the event
%                     in the format 'yyyy/mm/dd hh/mm/ss.s'
%      Magnitude      reported magnitude (usually mb and MS)
%      Location       geographical location (24 characters max)
%      EventName      see INPUT:cmtcode
%      MomentType     The type of moment-rate function. 
%                     BOXHD <-> boxcar; TRIHD <-> triangular
%      HalfDuration   Half the duration of the moment rate function
%      CentroidTime   Offset in seconds w.r.t. DateTime
%      Lat            Centroid Latitude [degrees]
%      Lon            Centroid Longitude [degrees]
%      Dep            Centroid Depth [km]
%      Exp            Moment tensor components are to be multiplied by
%                     to get M in units of dyne/cm 
%      M              M=[Mrr Mtt Mpp Mrt Mrp Mtp] in [dyne cm]
%      Mw             Moment magnitude (Hanks & Kanamori 1979)
%
% EXAMPLES:
%
% cmtsol('all') % Makes all the *.mat files
% CMT=cmtsol('M012176A') % Returns a specific one
% CMT=cmtsol('demo1') ----  Denali Fault, Alaska     2002/11/03
% CMT=cmtsol('demo2') ----  Santa Cruz Islands       1999/02/06 
% CMT=cmtsol('demo3') ----  Sumatra-Andaman Islands  2004/12/26
% CMT=cmtsol('demo4') ----  Bolivia                  1994/06/09
% CMT=cmtsol('demo5') ----  Offshore Maule, Chile    2010/02/27
%
% Last modified by efwelch@princeton.edu 07/20/2010 
% Last modified by lmberg@princeton.edu, 08/03/2017
% Last modified by fjsimons-at-alum.mit.edu, 02/08/2023

defval('cmtcode','demo1')
defval('fname',fullfile(getenv('IFILES'),'CMT','jan76_dec20.ndk'));

if isempty(strmatch('demo',cmtcode))
  if ~strcmp(cmtcode,'all')
    tobesaved=fullfile(fileparts(fname),...
		       'MATFILES',sprintf('%s.mat',cmtcode));
  else
    tobesaved='neveravailable';
  end
  % Load it
  if exist(tobesaved,'file') 
    disp(sprintf('load %s',tobesaved));
    load(tobesaved);
    eval(sprintf('earthquake=%s;',cmtcode));
  else 
    % Make it
    % Format for the textscan of the .ndk CMT events file
    % type HELP TEXTSCAN for the formatting conventions
    format=['%*5c%21c%*f%*f%*f%*f%f%[^\n]%*[\n]',...
	    '%s%*[^:]%*[:]%*[^:]%*[:]%*[^:]%*[:]%*[^:]%*[:]%*s%[^:]%*[:]%f%*[\n]',...
	    '%*s%f%*f%f%*f%f%*f%f%*f%*[^\n]%*[\n]',...
	    '%f%f%*f%f%*f%f%*f%f%*f%f%*f%f%*f%*[\n]',...
	    '%*s%*[^\n]%*[\n]'];
    fid=fopen(fname);
    % There should be 5 lines of 80 characters and a newline on each
    C=cell(fsize(fname)/405,17);
    C=textscan(fid,format);
    fclose(fid);
    % MAKE ALL events in cmt file [no output]
    if strcmp(cmtcode,'all')
       jj=1:length(C{4});
       disp('Making MAT files for all earthquakes in catalog\n');
    else
      jj=find(ismember(C{4},cmtcode));
      disp(sprintf('Making MAT file for event %s\n',cmtcode));
    end

    for in=jj
      earthquake=makestruct(C,in);
      cmtcode=C{4}{in};
      tobesaved=fullfile(fileparts(fname),...
			 'MATFILES',sprintf('%s.mat',cmtcode));
      eval(sprintf('%s=earthquake;',cmtcode))
      save(tobesaved,cmtcode);
      clear(cmtcode)
      if ~mod(in,1000)
	disp(sprintf('Finished making MAT files for %5.5d / %d events',...
		     in,length(C{4})));
      end
    end
    disp(sprintf('Finished making MAT files for %5.5d / %d events',...
		 in,length(C{4})));
    if strcmp(cmtcode,'all')
      earthquake=[];
    end
  end
else % It's a demo
  if strcmp(cmtcode,'demo1')
    cmtcode='M110302J';
  elseif strcmp(cmtcode,'demo2')
    cmtcode='C020699C';
  elseif strcmp(cmtcode,'demo3')
    cmtcode='M122604A';
  elseif strcmp(cmtcode,'demo4')
    cmtcode='M060994A'; 
  elseif strcmp(cmtcode,'demo5')
    cmtcode='C201002270634A';
  else
    error('Specify one of five demos')
  end
  earthquake=cmtsol(cmtcode,[]);
end

% Output
vars={earthquake};
varargout=vars(1:nargout);  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S=makestruct(C,in)
kb
% See also: as in DEFSTRUCT or GUYOTWEATHER
S=struct('DateTime',    C{1}(in,:),...
         'Magnitude',   C{2}(in),...
         'Location',    deblank(C{3}{in}),...
	 'EventName',   C{4}{in},...
	 'MomentType',  C{5}{in},...
	 'HalfDuration',C{6}(in),...
	 'CentroidTime',C{7}(in),...
	 'Lat',         C{8}(in),...
	 'Lon',         C{9}(in),...
	 'Dep',         C{10}(in),...
	 'Exp',         C{11}(in),...
	 'M',...
	                [C{12}(in) C{13}(in) C{14}(in)...
	                 C{15}(in) C{16}(in) C{17}(in)],...
	 'Mw',2/3/log(10)*...
	 log(1/sqrt(2)*10^C{11}(in)*sqrt(C{12}(in)^2+C{13}(in)^2+C{14}(in)^2+...
			    2*(C{15}(in)^2)+2*(C{16}(in)^2)+2*(C{17}(in)^2)))-10.7);
         % Calculated the scalar seismic moment from the moment tensor components
	 

