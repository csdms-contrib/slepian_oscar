function varargout=vit2tbl(fname,fnout)
% jentry=VIT2TABL(fname,fnout)
%
% Reads a MERMAID *.vit file, parses the content, and writes it to *.tbl
%
% (One would start with SERVERCOPY sync from our receiving server)
% (One would end with copying the output to our web server using VITEXPORT)
% (One would read those files off the Google Maps API on www.earthscopeoceans.org)
%
% INPUT:
%
% fname     A full filename string (e.g. '/u/fjsimons/MERMAID/serverdata/vitdata/452.020-P-08.vit')
% fnout     An output filename for the reformat [default: same path, extension changed to *.tbl]
%
% OUTPUT:
%
% jentry    The last journal entry as appeared in the file
%
% NOTE:
%
% *.vit files take the following form entries
% 20180409-08h33mn01: >>> BUOY 01 2018-04-09T08:33:02 <<<
% 20180409-08h33mn02: N34deg43.118mn, E135deg17.443mn
% 20180409-08h33mn03: hdop 1.270, vdop 2.150
% 20180409-08h33mn05: Vbat 15425mV (min 14962mV)
% 20180409-08h33mn08: Pint 91211Pa
% 20180409-08h33mn09: Pext -2147483648mbar (range -1mbar)
% 20180409-08h33mn45: 7 cmd(s) received
% 20180409-08h33mn52: 1 file(s) to upload
% 20180409-08h34mn37: 1 file(s) uploaded
% 20180409-08h34mn44: <<<<<<<<<<<<<<< Bye >>>>>>>>>>>>>>>
%
% NOTE:
%
% If the file is corrupted due to transmission problems, will handle gracefully
%
% TESTED ON MATLAB 9.0.0.341360 (R2016a)
% 
% Last modified by fjsimons-at-alum.mit.edu, 11/11/2018

% Default input filename, which MUST end in .vit
defval('fname','/u/fjsimons/MERMAID/serverdata/vitdata/452.020-P-08.vit')

% Default output filename, in case you didn't give on
defval('fnout',NaN)
if isnan(fnout)
  % Construct output filename for writing
  fnout=fname;
  % Old extension, with the dot
  oldext='.vit';
  % New extension, must be same length
  newext='.tbl';
  % Change extension from oldext to newext
  fnout(strfind(fname,oldext):strfind(fname,oldext)+length(oldext)-1)=newext;
end

% Open input for reading
fin=fopen(fname,'r');

% Always write a whole new file, always process the entire file (for now)
fout=fopen(fnout,'w+');

% EXACT markers of the journal entries
begmark='BUOY';
endmark='Bye';
% UNUSED number of blank lines in-between entries
nrblank=2;
% EXPECTED number of lines (NOT PUNITIVE)
nrlines=10;

% COMPARE WITH MER2HDR INSIDE MER2SAC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Keep going until the end
lred=0;
% Do not move past the end
while lred~=-1
  % Read line by line until you find a BEGMARK or hit an ENDMARK
  isbeg=[];

  % Reads lines until you hit a begin marker
  while isempty(isbeg)
    lred=fgetl(fin);
    % Terminate if you have reached the end of the file
    if lred==-1; break ; end
    % Was that a line opening a journal entry?
    isbeg=strfind(lred,begmark);
  end

  % Terminate if you have reached the end of the file
  if lred==-1; break ; end

  % Now you are inside the entry, and you have a good idea
  isend=[];
  % Initialize to a size probably good enough (but will grow)
  jentry=cellnan([nrlines 1],1,1);
  % Grab the line you already had
  jentry{1}=lred; index=1;
  % Reads lines until you hit the end marker, or a new begin
  while isempty(isend)
    % Keep the position in order to back up
    oldpos=ftell(fin);
    % Read another line... possibly one too many
    lred=fgetl(fin); 
    % Terminate if you have reached the end of the file
    if lred==-1; break ; end
    % Put the entries in the output array
    index=index+1;
    jentry{index}=lred;
    % Was that a line closing a journal entry?
    isend=strfind(lred,endmark);
    % But if it has hit a new beginning, need to reset
    isnew=strfind(lred,begmark);
    % The cannot both be true, but one needs to tell the other and back up
    if ~isempty(isnew); isend=isnew; fseek(fin,oldpos,-1) ; end
  end

  % Here there is no culling, unlike in MER2SAC

  % If an entry is corrupted, it could have too many lines
  % OVERRIDE SINCE FORMCONV WILL READ AS FAR AS IT CAN
  if 1==1 | [size(jentry,1)<=nrlines & index<=nrlines]
    % Format conversion 
    [stdt,STLA,STLO,hdop,vdop,Vbat,minV,Pint,Pext,Prange,cmdrcd,f2up,fupl]=...
	formconv(jentry);
    
    % Do not bother if you're in the testing phase, when Pext will be SUPER negative
    if Pext>-2e6
      % Write one line in the new file, if the data are not corrupted...
      fprintf(fout,fmtout,...
	      stdt,STLA,STLO,hdop,vdop,Vbat,minV,Pint,Pext,Prange,cmdrcd,f2up,fupl);

    end
  end
    
  % Read the prescribed number of blanks and reset or comparison will fail
  % for index=1:nrblank; lred=fgetl(fin); end; lred=0; 
end

% Optional output
varns={jentry};
varargout=varns(1:nargout);

% Close and done
fclose(fin);
fclose(fout);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE FORMAT STRING
function fmt=fmtout

% All but last one get spaces
stdt_fmt  ='%s ';
STLA_fmt  ='%11.6f ';
STLO_fmt  ='%11.6f ';
hdop_fmt  ='%8.3f ';
vdop_fmt  ='%8.3f ';
Vbat_fmt  ='%5i ';
minV_fmt  ='%5i ';
Pint_fmt  ='%5i ';
Pext_fmt  ='%12i ';
Prange_fmt='%5i ';
cmdrcd_fmt='%3i ';
f2up_fmt  ='%3i ';
% Last one gets a closure
fupl_fmt  ='%3i\n';

% Combine all the formats, the current result is:
% '%s %11.6f %11.6f %8.3f %8.3f %5i %5i %5i %12i %5i %3i %3i %3i\n'
fmt=[stdt_fmt,STLA_fmt,STLO_fmt,hdop_fmt,vdop_fmt,Vbat_fmt,minV_fmt,Pint_fmt,...
	   Pext_fmt,Prange_fmt,cmdrcd_fmt,f2up_fmt,fupl_fmt];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROBUST FORMAT CONVERSION FROM .vit ENTRY TO ONE-LINER FOR .tbl FILE
function [stdt,STLA,STLO,hdop,vdop,Vbat,minV,Pint,Pext,Prange,cmdrcd,f2up,fupl]=formconv(jentry)

% Robustness is increasingly meaning: down to first error

% Now you have one journal entry, and are ready to parse for output
% FIRST LINE: Time stamp
vitdat=jentry{1}(33:51); % Check this is like: 2018-04-09T08:33:02
% SECOND LINE: latitude and longitude
vitlat=jentry{2}(21:34); % Check this is like: N34deg43.118mn
vitlon=jentry{2}(37:51); % Check this is like: E135deg17.443mn
			 
% Convert these already
[stdt,STLA,STLO]=vit2loc(vitdat,vitlat,vitlon);

% ABORT HERE IF THE COORDINATES ARE 00, DOP PROBLEMS DOWN THE LINE
% ADDED PROVISIONS FOR WHEN CONVERSION PRODUCED AN EMPTY 
if ~isempty(STLO*STLA) && STLO~=0 && STLA~=0
  % THIRD LINE: horizontal and vertical dilution of precision
  vitdop=textscan(jentry{3},'%*s %*s %f %*s %*s %f');
  hdop=vitdop{1}; % Check this is like: 1.27
  vdop=vitdop{2}; % Check this is like: 2.15
elseif [~isempty(STLO) && STLO==0] && [~isempty(STLA) && STLA==0]
  STLO=NaN;
  STLA=NaN;
  % And do not even bother to read on, the dop might be negative
else
  STLO=NaN;
  STLA=NaN;
end
% If no hdop or vdop have been read, assign NaN to them
defval('hdop',NaN)
defval('vdop',NaN)
    
% FOURTH LINE: battery level and minimum voltage
vitbat=textscan(jentry{4},'%*s %*s %f %*s %*s %f');
Vbat=vitbat{1}; % Check this is like 15425
minV=vitbat{2}; % Check this is like 14962
% FIFTH LINE: internal pressure
Pint=cell2mat(textscan(jentry{5},'%*s %*s %f'));
% SIXTH LINE: external pressure and range
vitext=textscan(jentry{6},'%*s %*s %f %*s %*s %f');
Pext=vitext{1};
Prange=vitext{2};

% SEVENTH LINE: 
try ; cmdrcd=cell2mat(textscan(jentry{7},'%*s %f')); end
% Capture if the line was empty
defval('cmdrcd',0)
% EIGHT LINE: 
try ; f2up=cell2mat(textscan(jentry{8},'%*s %f')); end
% Capture if the line was empty
defval('f2up',0)
% NINTH LINE: 
try ; fupl=cell2mat(textscan(jentry{9},'%*s %f')); end
% Capture if the line was empty
defval('fupl',0)
