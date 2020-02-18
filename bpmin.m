function epb=bpmin(H,F,dB)
% epb=BPMIN(H,F,dB)
%
% Takes a filter, figures out where its gain drops below a certain frequency
%
% INPUT:
%
% H     Squared magnitude response (in DECIBEL)
% F     Frequency vector
% dB    Stopband level (positive)
%
% OUTPUT:
% 
% epb   Frequencies where the pass band exceeds dB level
%
% SEE ALSO:
%
% BANDPASS, DECIBEL
%
% Tested on MATLAB Version: 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 02/18/2020

keyboard

% Supply defaults
defval('dB',3)

% Make the points that you look for zero
H=H+dB;
% Find the single maximum so you can split the search
Hm=find(H==max(H));

% Both are now monotonic functions
% I used to go from 1 but then it hits -Inf so now I go from 2
F1=interp1(H(2:Hm),F(2:Hm),0);
F2=interp1(H(Hm+1:end),F(Hm+1:end),0);

% The two requested points
epb=[F1 F2];

