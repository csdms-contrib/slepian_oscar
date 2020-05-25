function varargout=readsac(filename,plotornot,osd,resol)
% [SeisData,HdrData,tnu,pobj,tims]=READSAC(filename,plotornot,osd,resol)
%
% READSAC(...)
%
% Reads SAC-formatted data (and makes a plot)
%
% INPUT:
%
% filename        The filename, full path included
% plotornot       1 Makes a plot
%                 0 Does not make a plot [default]
% osd             'b' for data saved on Solaris read into Linux
%                 'l' for data saved on Linux read into Linux
% resol           1 Resolves the integer catergorical variables
%                 0 Does not [default]
%
% OUTPUT:
%
% SeisData        The numbers vector
% HdrData         The header structure array
% tnu             The handle to the plot title; or appropriate string
% pobj            The handle to the plot line and the xlabel
% tims            The times on the x-axis
%
% See SETVAR.PL out of SACLIB.PM
%
% SEE ALSO:
%
% WRITESAC, PLOTSAC
% 
% Last modified by fjsimons-at-alum.mit.edu, 05/25/2020

defval('plotornot',0)
defval('osd',osdep)
defval('resol',0)

fid=fopen(filename,'r',osd);
if fid==-1
  error([ 'File ',filename,' does not exist in current path ',pwd])
end
% Floating points
HdrF=fread(fid,70,'float32');
% Integers
HdrN=fread(fid,15,'int32');
% Enumerated
HdrI=fread(fid,20,'int32');
% Logical
HdrL=fread(fid,5,'int32');
% Alphanumeric
HdrK=str2mat(fread(fid,[8 24],'char'))';
% The actual data
SeisData=fread(fid,HdrN(10),'float32');
fclose(fid);

% Meaning of LCALDA from http://www.llnl.gov/sac/SAC_Manuals/FileFormatPt2.html
% LCALDA is TRUE if DIST, AZ, BAZ, and GCARC are to be calculated from
% station and event coordinates. But I don't know how to set this
% variable to a logical yet using setvar.pl. What is the TRUE/FALSE
% format in SAC? 18.1.2006

% If you change any of this, change it in WRITESAC as well!
HdrData=struct(...
  'AZ',HdrF(52),...
  'B',HdrF(6),...
  'BAZ',HdrF(53),...
  'DIST',HdrF(51),...
  'DELTA',HdrF(1),...
  'E',HdrF(7),...
  'EVDP',HdrF(39),...
  'EVEL',HdrF(38),...
  'EVLA',HdrF(36),...
  'EVLO',HdrF(37),...
  'GCARC',HdrF(54),...
  'IDEP',HdrI(2),...
  'IFTYPE',HdrI(1),...
  'KCMPNM',HdrK(21,HdrK(21,:)>64),...
  'KINST',HdrK(24,HdrK(24,:)>64),...
  'KSTNM',HdrK(1,:),...
  'KEVNM',[HdrK(2,:) , HdrK(3,:)],...
  'KUSER0',HdrK(18,HdrK(18,:)>64),...
  'KNETWK',HdrK(22,:),...
  'LCALDA',HdrL(4),... 
  'MAG',HdrF(40),...
  'NPTS',HdrN(10),...
  'NVHDR',HdrN(7),...
  'NZHOUR',HdrN(3),...
  'NZJDAY',HdrN(2),...
  'NZMIN',HdrN(4),...
  'NZMSEC',HdrN(6),...
  'NZSEC',HdrN(5),...
  'NZYEAR',HdrN(1),...
  'SCALE',HdrF(4),...
  'STDP',HdrF(35),...
  'STEL',HdrF(34),...
  'STLA',HdrF(32),...    
  'STLO',HdrF(33),...
  'T0',HdrF(11),...
  'T1',HdrF(12),...
  'T2',HdrF(13),...
  'T3',HdrF(14),... 
  'USER0',HdrF(41),...
  'USER1',HdrF(42),...
  'USER2',HdrF(43));

% Need a table with the enumerated header variables from 
% https://ds.iris.edu/files/sac-manual/manual/file_format.html
% So far we have IFTYPE and IDEP covered, but there are many more
% [IVOLTS] would be 50 but I didn't get that far
% [FJS STUCK IN THE EXTRA TOP ROW TO USE MAX BELOW IN
% CASE THE VALUE IS -12345 i.e. the not-set one]
IVARS={'UNKNOWN',... 
       'TIME SERIES FILE',...  % [ITIME]
       'Spectral file---real and imaginary',... % [IRLIM]
       'Spectral file---amplitude and phase',... % [IAMPH]
       'General X versus Y data',... % [IXY]
       'UNKNOWN',... % [IUNKN]
       'DISPLACEMENT (NM)',...  % [IDISP]
       'VELOCITY (NM/SEC)',... % [IVEL]
       'ACCELERATION (NM/SEC/SEC)',... % [IACC]
      };
% Substitute the name for the code
if resol==1
  HdrData.IFTYPE=IVARS{max(HdrData.IFTYPE+1,1)};
  HdrData.IDEP=IVARS{max(HdrData.IDEP+1,1)};
end

% For the time sequence
tims=linspace(HdrData.B,HdrData.E,HdrData.NPTS);

if plotornot==1
  pobj=plot(tims,SeisData);
  filename(find(abs(filename)==95))='-';
  tito=nounder(suf(filename,'/'));
  if isempty(tito)
    tito=nounder(filename);
  end
  tnu=title(tito);
  axis tight
  pobj(2)=xlabel(['time (s)']);
else
  tnu=nounder(suf(filename,'/'));
  pobj=0;
end

% Optional output
varns={SeisData,HdrData,tnu,pobj,tims};
varargout=varns(1:nargout);
