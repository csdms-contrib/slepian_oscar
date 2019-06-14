function [tstp,tS,tP,raypP,raypS,namP,namS]=tmins(dlta,depth)
% [tstp,tS,tP,raypP,raypS,namP,namS]=TMINS(dlta,depth)
%
% Calculates "P" and "S" arrival times and ray parameters for a given
% earthquake using the compiled FORTRAN code PARRIVAL.
%
% INPUT:
%
% dlta            Epicentral distance (degrees, vector)
% depth           Hypocenter depth (km, scalar)
%
% OUTPUT:
%
% tstp            Travel time of S wave minus P wave under IASP91
% tS              Travel time of S wave [s]
% tP              Travel time of P wave [s]
% raypP           Spherical ray parameter of P wave [s/rad]
% raypS           Spherical ray parameter of S wave [s/rad]
% namP            Name of the first arriving P-branch phase
% namS            Name of the first arriving S-branch phase
%
% Note that "P" and "S" is the first phase in the branch - 
% this might be Pn, Pdiff, PKP, etc. 
% 
% For the phase speed, need the inverse of the ray parameter but in km/s
% I suppose.
%
% Last modified by fjsimons-at-alum.mit.edu, 06/14/2019

% Supply some defaults, for testing purposes
defval('dlta',46.45)
defval('depth',33)

if length(depth)==1
  depth=repmat(depth,length(dlta),1);
end

% It's going to best to initialize these arrays.
[tP,tS,raypP,raypS]=deal(nan(length(dlta),1));

% Set limit value to get a waitbar, or not
% Note that for large numbers, it will be faster or at least more
% convenient to run this program in a loop and write the data out as you
% go. 
limval=100;

if length(dlta)>limval
  h=waitbar(0,'Calculating arrival times and ray parameters');
end

for index=1:length(dlta)
  % s1 and s2 need to return zero if no mistakes are made
  [s1,tPs]=system(sprintf(...
      'parrival P %f %f',depth(index),dlta(index)));
  % Get rid of the annyoing "floating exception" from /usr/bin/[
  if strmatch('Floating exception',tPs)
    tPs=tPs(42:end);
  end
  % Need the space here
  if isempty(strmatch(' Bad interpolation',tPs))
    % Parse the returned (multi-line) output string
    Pparse=parse(tPs,' ');
    % Get the P-branch travel time
    tP(index,1)=str2num(rindeks(Pparse,5));
    % Get the P-branch ray parameter
    raypP(index,1)=str2num(rindeks(Pparse,8));
    if nargout>5
      % Get the name of the P-branch
      namP{index}=deblank(rindeks(Pparse,4));
    end
  else
    namP{index}=NaN;
  end

  % Now for the S wave
  [s2,tSs]=system(sprintf(...
      'parrival S %f %f',depth(index),dlta(index)));
  if strmatch('Floating exception',tSs)
    tSs=tSs(42:end);
  end
  % Need the space here
  if isempty(strmatch(' Bad interpolation',tSs))
    % Parse the returned (multi-line) output string
    Sparse=parse(tSs,' ');
    % Get the S-branch travel time
    tS(index,1)=str2num(rindeks(Sparse,5));
    % Get the S-branch ray parameter
    raypS(index,1)=str2num(rindeks(Sparse,8));
    if nargout>6
      % Get the name of the S-branch
      namS{index}=deblank(rindeks(Sparse,4));
    end
  else
    namS{index}=NaN;
  end
  if length(dlta)>limval
    waitbar(index/length(dlta),h);
  end
end
if length(dlta)>limval
  delete(h)
end

% Return the difference, in s, between (assumed) P and S wave arrivals
tstp=(tS-tP);

% Clean up after yourself
system('/bin/rm ttim1.lis');
