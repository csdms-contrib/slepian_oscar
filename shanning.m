function [w,wl,wr]=shanning(n,r)
% [w,wl,wr]=fhanning(n,r)
%
% Calculates Hanning windows of a certain length and a certain width
% fraction the exact way SAC says it is doing it
%
% INPUT:
%
% n       The required length of the window
% r       The fraction of the window that is tapered
%
% OUTPUT:
%
% w       The Hanning window 
% wl      The left half of the window
% wr      The right half of the window
%
% EXAMPLE:
% 
% SAC> funcgen line 0 1 npts 20
% SAC> taper type hanning width 0.5
% SAC> w twenty
% difer(readsac('twenty')-shanning(20,0.5),6)
% SAC> funcgen line 0 1 npts 21
% SAC> taper type hanning width 0.5
% SAC> twentyone
% difer(readsac('twentyone')-shanning(21,0.5),6)
%
% This function does NOT work yet
%
% Last modified by fjsimons-at-alum.mit.edu, 05/26/2021

% See SAC help taper
t=ceil(r*n);
% The left bit
wl = .5*(1-cos(pi*(0:t-1)'/t));
% The right one
wr = flipud(wl);

% And then the full thing put together
w=[wl(1:end) ; wr(1+rem(n,2):end)];


