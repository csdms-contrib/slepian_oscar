function varargout=vit2tbl(fname,foutname)
% jentry=VIT2TABL(fname,foutname)
%
% Reads a Mermaid *vit file and parses the content, and writes it out
%
% INPUT:
%
% fname     A full filename string (e.g. '/u/fjsimons/MERMAID/server/452.112-N-01.vit')
% foutname  An output file for the reformatted data
%
% OUTPUT:
%
% jentry    The last journal entry as appeared in the file
%
% NOTE:
%
% *.vit files take the following form
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
% Last modified by fjsimons-at-alum.mit.edu, 05/17/2018

% Default filename, which MUST end in .vit
defval('fname','/u/fjsimons/MERMAID/server/452.112-N-01.vit')

% Open output for writing
fnout=fname;
% Old extension, with the dot
oldext='.vit';
% New extension, must be same length
newext='.tbl';
% Change extension from oldext to newext
fnout(strfind(fname,oldext):strfind(fname,oldext)+length(oldext)-1)=newext;
% Always write a whole new file, always process the entire file (for now)
fout=fopen(fnout,'w+');

% Open input for reading
fin=fopen(fname,'r');

% EXACT markers of the journal entries
begmark='BUOY';
endmark='Bye';
% EXACT number of blank lines in-between entries (NOT USED TO BE FLEXIBLE)
nrblank=2;
% EXPECTED number of lines per entry, reject if not the same
nrlines=10;

% Keep going until the end
lred=0;
% Do not move past the end
while lred~=-1
  % Read line by line until you find a "BUOY" or hit "Bye"
  isbeg=[];
  % Reads lines until you hit a begin marker
  while isempty(isbeg)
    lred=fgetl(fin);
    % Terminate if you have reached the end
    if lred==-1; break ; end
    % Was that a line opening a journal entry?
    isbeg=strfind(lred,begmark);
  end

  % Terminate if you have reached the end
  if lred==-1; break ; end

  % Now you are inside the entry, and you have a good idea
  isend=[];
  % Initialize to a size probably good enough (but will grow)
  jentry=cellnan([nrlines 1],1,1);
  % Grab the line you already had
  jentry{1}=lred; index=1;
  % Reads lines until you hit the end marker
  while isempty(isend)
    lred=fgetl(fin);
    % Put the entries in the output array
    index=index+1;
    jentry{index}=lred;
    % Was that a line closing a journal entry?
    isend=strfind(lred,endmark);
  end

  % If an entry is corrupted, it could have too many lines, or too few
  if size(jentry,1)==nrlines & index==10
    % Format conversion 
    [stdt,STLA,STLO,hdop,vdop,Vbat,minV,Pint,Pext,Prange,cmdrcd,f2up,fupl]=...
	formconv(jentry);
    
    % Write one line in the new file
    fprintf(fout,'%s %11.6f %11.6f %8.3f %8.3f %5i %5i %5i %12i %5i %3i %3i %3i\n',...
	    stdt,STLA,STLO,hdop,vdop,Vbat,minV,Pint,Pext,Prange,cmdrcd,f2up,fupl);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FORMAT CONVERSION FROM .vit ENTRY TO ONE-LINER FOR .tbl FILE
function [stdt,STLA,STLO,hdop,vdop,Vbat,minV,Pint,Pext,Prange,cmdrcd,f2up,fupl]=formconv(jentry)

% Now you have one journal entry, and are ready to parse for output
% FIRST LINE: Time stamp
vitdat=jentry{1}(33:51); % Check this is like: 2018-04-09T08:33:02
 % SECOND LINE: latitude and longitude
vitlat=jentry{2}(21:34); % Check this is like: N34deg43.118mn
vitlon=jentry{2}(37:51); % Check this is like: E135deg17.443mn
			 
% Convert these already
[stdt,STLA,STLO]=vit2loc(vitdat,vitlat,vitlon);
 
% THIRD LINE: horizontal and vertical dilution of precision
vitdop=textscan(jentry{3},'%*s %*s %f %*s %*s %f');
hdop=vitdop{1}; % Check this is like: 1.27
vdop=vitdop{2}; % Check this is like: 2.15
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
cmdrcd=cell2mat(textscan(jentry{7},'%*s %f'));
% EIGHT LINE: 
f2up=cell2mat(textscan(jentry{8},'%*s %f'));
% NINTH LINE: 
fupl=cell2mat(textscan(jentry{9},'%*s %f'));
