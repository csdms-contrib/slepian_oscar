function A=woodanderson(Ml,Delta)
% A=WOODANDERSON(Ml,Delta)
%
% Calculates the "amplitude" of a "seismic wave".
%
% Use this for shallow and close-by events. Note that this is an
% extremely poor thing to do. Compare, e.g. Wu and Zhao (2006).
%
% Note this is the maximum amplitude, of the dominant phase, usually an
% Lg wave. Not for the P wave, in other words. See Udias for more.
%
% INPUT
%
% Ml       Local (Wood-Anderson) magnitude
% Delta    Epicentral distance (in degrees)
%
% OUTPUT
%
% A        Ground displacement amplitude, in micrometers (10^-6 m)
%
% NOTE:
%
% Ml is the original "Richter" magnitude
%
% See also: REID, GUTENBERGRICHTER
%
% Last modified by fjsimons-at-alum.mit.edu, 03/03/2020
%
% REFERENCES: 
%
% Simons et al., JGR 2009, doi:10.1029/2008JB006088, used for equation
% reference below

% Convert epicentral distance from degrees to kilometers
dkm=Delta*fralmanac('DegDis')/1000;

if dkm>=600
  disp('Epicentral distance too large to be valid - use GUTENBERGRICHTER')
end

% Shearer 1999, Eq. 9.37
% Udias 1999, Eq. 15.11
% Simons et al. 2009, equation 2
A=10.^(Ml-2.56*log10(dkm)+1.67);
