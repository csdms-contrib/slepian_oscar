function [cz,z]=munk(zm,zc,dz)
% [cz,z]=munk(zm,zc,dz)
%
% Makes the Munk sound speed profile (10.1121/1.1914492)
%
% INPUT: 
%
% zm     The maximum depth (positive m)
% zc     The depth of the minimum speed (m)
% dz     The depth discretization (m) 
%
% OUTPUT:
%
% cv     The sound speed at the requested depth
% z      The requested depths (m)
%
% EXAMPLE:
%
% [cz,z]=munk(-gebco(-149,-17),1300,10); plot(cz,z); axis ij
% xlabel('sound speed (m/s)'); ylabel('depth (m)'); title('Munk profile')
% 
% Last modified by fjsimons-at-alum.mit.edu, 5/24/2021

% Default values
defval('zm',5000)
defval('zc',1300)
defval('dz',10)

% Make the depths
z=0:dz:zm;

% The sound speed profile
epsilon=0.00737;
zbar=2*(z-zc)/zc;
cz=1500*[1+epsilon*(zbar-1+exp(-zbar))];


