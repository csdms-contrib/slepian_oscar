function val=bullen(rxy,fld,arg)
% val=BULLEN(rxy,fld,arg)
%
% Evaluates a one-dimensional Earth model in Cartesian coordinates:
% piecewise linear in the y direction with a low-velocity zone. There
% is no variation of the wavespeed profile in x, yet the function
% allows specifying an x position.
%
% INPUT:
% 
% rxy       Single set of Cartesian position coordinates [x,y], in m, with 
%           x the horizontal and y positive downward
% fld       1 P-velocity [m/s]
%           2 S-velocity [m/s]
%           3 density [kg/m^3]
% arg       1 returns the field
%           2 returns the field gradient d(fld)/dx
%           3 returns the field gradient d(fld)/dy
%
% OUTPUT:
%
% val       The field or its derivatives
%
% EXAMPLE:
%
% plot([bullen([0     0],1) bullen([0 12000],1)],[    0 12000]); hold on
% plot([bullen([0 12000],1) bullen([0 18000],1)],[12000 18000])
% plot([bullen([0 18000],1) bullen([0 30000],1)],[18000 30000])
% axis ij; hold off
%
% hold on; val=linmod([0 0;  0 3e4],1,1); plot(val,[0 3e4]); hold off
%
% SEE ALSO:
%
% BULLENRAYS, LINMOD
%
% Last modified by fjsimons-at-alum.mit.edu, 06/09/2021

% Speed and gradient parameters for the Bullen and Bolt example on page
% 156, which they credit to Cerveny et al., 1977 (the monograph!)
% Make sure that they match at the interfaces! I checked at some point.

% Default values
defval('fld',1)
defval('arg',1)

% Interfaces
interf=[12000 18000];
% Piecewise linear behavior - might vectorize differently for easy plotting
if rxy(2)<interf(1)
  % Wavespeed increases with positive y
  c0=5400;
  dcdy=+7.5e-2;
elseif rxy(2)<interf(2)
  % Wavespeed decreases with positive y
  c0=7296;
  dcdy=-8.3e-2;
else
  % Wavespeed increases with positive y
  c0=4650;
  dcdy=+6.4e-2;
end

% There is no distinction in the fld argument here
switch arg
 case 1
  val=rxy(2)*dcdy+c0;
 case 2
  val=0;
 case 3
  val=dcdy;
end
