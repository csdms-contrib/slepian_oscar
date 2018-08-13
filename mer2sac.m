function varargout=mer2sac(fname,fnout,ornot)
% [SeisData,HdrEvt,HdrData]=MER2SAC(fname,fnout,ornot)
%
% Reads a MERMAID *MER file and parses the content, and writes it out to SAC.
%
% INPUT:
%
% fname     A full string (e.g. '~/MERMAID/serverdata/merdata/22_5B278AF1.MER')
% fnout     An output filename for the reformat [default: changed extension]
% ornot     1 writes output
%           0 does not write output
%
% OUTPUT:
%
% SeisData        The numbers vector, the samples of the seismograms, a cell
% HdrEvt          The metadata, for each of the events, a cell
% HdrData         The main header entries array
%
% TESTED ON MATLAB 9.0.0.341360 (R2016a)
% 
% Last modified by fjsimons-at-alum.mit.edu, 08/11/2018

% Default output or not
defval('ornot',0)

% Default input filename, which MUST end in .MER
defval('fname','/u/fjsimons/MERMAID/serverdata/merdata/22_5B278AF1.MER')

% Construct output filenames for writing
fnout=fname;
% Old extension, with the dot
oldext='.MER';
% New extension, must be same length
newext='.sac';
% Change extension from oldext to newext
fnout(strfind(fname,oldext):strfind(fname,oldext)+length(oldext)-1)=newext;

% Open input for reading
fin=fopen(fname,'r');

% Read TOP HEADER data
HdrData=mer2hdr(fin,'<ENVIRONMENT>','</PARAMETERS>',58,30);

% Back up the file all the way to the beginning
fseek(fin,0,-1);

% This is the HdrData cell index where the number of events must be kept
evl=4;
% How many events are there?
nev=str2num(HdrData{evl}(strfind(HdrData{evl},'EVENTS=')+7:strfind(HdrData{evl},'/>')-2));

for index=1:nev
  % Read EVENT HEADER data
  HdrEvt{index}=mer2hdr(fin,'<EVENT>','<DATA>',7,4);

  % This is the HdrEvt cell index where the number of samples read must be kept
  evl=3;
  % How many data points need to be read??
  nrd=str2num(HdrEvt{index}{evl}(strfind(HdrEvt{index}{evl},'LENGTH=')+7:strfind(HdrEvt{index}{evl},'/>')-2));
  
  % Read data data
  SeisData{index}=mer2dat(fin,nrd);

  % Now the clock corrections and the inverse wavelet transform etc as in
  % the Python script.  But for this, we really should go to AUTOMAID...

  % Write out, need to work on the subfile names
  if ornot==1
    % 
    % writesac(SeisData,HdrData,fnout)
  end
end

% Maybe check that we are at the very end of the file?
% All that should follow is two closing tags, </DATA> and </EVENT>, which
% I  think should amount to 1767 bytes

% There may have bee none, so prepare empty output
defval('SeisData',NaN)
defval('HdrEvt',NaN)

% Optional output
varns={SeisData,HdrEvt,HdrData};
varargout=varns(1:nargout);

% Close and done
fclose(fin);
%fclose(fout);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hdr=mer2hdr(fin,begmark,endmark,nrlines,nrvalid)
% Subroutine to read the header data

% EXACT markers of the journal entries, e.g. 
defval('begmark','<ENVIRONMENT>');
defval('endmark','</PARAMETERS>');
% EXPECTED number of lines (NOT PUNITIVE), e.g.
defval('nrlines',58);
% EXPECTED number of nonempty entries, will grow/shrink, e.g.
defval('nrvalid',30);

% Initialize to a size probably good enough (but will grow)
hdr=cellnan([nrvalid 1],1,1);

% COMPARE WITH VIT2TBL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

  % Now you have captured the header; get rid of any blanks and NaNs
  index=0;
  for ondex=1:length(jentry)
    if ~isempty(jentry{ondex}) & ~isnan(jentry{ondex})
      index=index+1;
      hdr{index}=jentry{ondex};
    end
  end
  % If you had fewer than expected entries, cull the final result also
  if index<nrvalid
    % The non-curly braces are crucial here
    hdr=hdr(1:index);
  end

  % Now you make sure you do not continue
  lred=-1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read data data
function dat=mer2dat(fin,nrd)

% EXACT number of data to read
defval('nrd',64);

dat=fread(fin,nrd,'int32');
