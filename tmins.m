function [tstp,tS,tP,namP,namS]=tmins(delta,depth)
% [tstp,tS,tP,namP,namS]=TMINS(delta,depth)
%
% INPUT:
%
% delta           Epicentral distance (degrees, vector)
% depth           Hypocenter depth (km, scalar)
%
% OUTPUT:
%
% tstp            Travel time of S wave minus P wave under IASP91
% tS              Travel time of S wave 
% tP              Travel time of P wave
% namP            Name of the first arriving P-branch phase
% namS            Name of the first arriving S-branch phase
%
% Note that "P" and "S" is the first phase in the branch - 
% this might be Pdiff, PKP, etc. 
%
% Last modified by fjsimons-at-alum.mit.edu, 13.11.2004

if length(depth)==1
  depth=repmat(depth,length(delta),1);
end

for index=1:length(delta)
  % s1 and s2 need to return zero if no mistakes are made
  [s1,tPs]=system(sprintf(...
      'parrival P %f %f',depth(index),delta(index)));
  Pparse=parse(tPs,' ');
  tP(index,1)=str2num(rindeks(Pparse,5));
  namP{index}=rindeks(Pparse,4);
  
  [s2,tSs]=system(sprintf(...
      'parrival S %f %f',depth(index),delta(index)));
  Sparse=parse(tSs,' ');
  tS(index,1)=str2num(rindeks(Sparse,5));
  namS{index}=rindeks(Sparse,4);
end

tstp=(tS-tP);




