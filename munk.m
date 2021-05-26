function [cz,z,zc,B]=munk(zm,zc,dz,B)
% [cz,z,zc,B]=munk(zm,zc,dz,B)
%
% Makes the Munk (1979) sound speed profile (10.1121/1.1914492)
% also quoted by MIT Open Course Ware 2-S998 (Spring 2012, Lab 05)
%
% INPUT: 
%
% zm     The maximum depth (positive m)
% zc     The depth of the minimum speed (m)
% dz     The depth discretization (m) 
% B      The Munk (1979) scale depth parameter (m)
%
% OUTPUT:
%
% cv     The sound speed at the requested depth
% z      The requested depths (m)
% zc     The depth of the minimum speed (m)
% B      The Munk (1979) scale depth parameter (m)
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
defval('B',1300)
defval('dz',10)

% Make the depths
z=0:dz:zm;

% The sound speed profile
epsilon=0.00737;
zbar=2*(z-zc)/B;
cz=1500*[1+epsilon*(zbar-1+exp(-zbar))];


