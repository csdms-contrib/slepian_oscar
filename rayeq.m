function dYdt=rayeq(t,Y,flag,velfun)
% dYdt=RAYEQ(t,Y,flag,velfun)
%
% Specifies the coupled system of differential equations for position and
% slowness in seismic ray tracing, for a velocity model that is constant in
% time, and specified with its derivatives, in two Cartesian dimensions.
%
% INPUT:
%
% t        Times for which the derivatives are being calculated; note
%          that there is no time-dependence in this particular system
% Y        The unknown functions whose time-derivatives are being specified:
%          [x1 x2 p1 p2] with x1,x2 Cartesian coordinates and p1,p2 the 
%          slowness components along those two directions
% flag     A passthrough option flag that needs to remain empty
% velfun   Function that interpolates a velocity model or its spatial
%          gradients along either of the coordinate directions, so that
%          velfun([x1 x2],[],1) is the propagation speed, and, respectively,
%          velfun([x1 x2],[],2) and velfun([x1 x2],[],3) its x1 and x2
%          derivatives. The empty variable is for P, S when applicable.
% 
% OUTPUT:
%
% dYdt     d[x1 x2 p1 p2]/dt whose integration yields the unknown
%          Cartesian coordinates and slownesses of this system
%
% SEE ALSO:
%
% RAYPATH, RAYPATHPOL, RAYEQPOL, BULLENRAYS
%
% Last modified by fjsimons-at-alum.mit.edu, 06/09/2021

% P-velocity hardcoded here
pors=1;

% Find the applicable speed
eval(sprintf('   c=%s(Y(1:2),%i,1);',velfun,pors))
% Find the applicable speed gradients
eval(sprintf('dcdx1=%s(Y(1:2),%i,2);',velfun,pors))
eval(sprintf('dcdx2=%s(Y(1:2),%i,3);',velfun,pors))

% Bullen & Bolt, 1985, p. 156, eq. (11) 
dYdt(1,1)=c^2*Y(3);
dYdt(2,1)=c^2*Y(4);
dYdt(3,1)=-1/c*dcdx1;
dYdt(4,1)=-1/c*dcdx2;
