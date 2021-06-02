function dYdt=rayeq(t,Y,flag,velfun)
% dYdt=RAYEQ(t,Y,flag,velfun)
%
% Specifies the coupled system of homogenous differential equations for ray
% tracing, dYdt=0, which depend on a certain velocity model constant in time.
%
% INPUT:
%
% t        Times for which the derivatives are being calculated; note
%          that there is no time-dependence in this particular system
% Y        The unknown functions whose time-derivatives are being specified:
%          [x1 x2 p1 p2] with x1,x2 Cartesian coordinates and p1,p2
%          slowness components along those two directions
% flag     Leave this empty. See if I can remove later
% velfun   Function that interpolates a velocity model or its spatial
%          gradients along either of the coordinate directions, so that
%          velfun(x1,x2,1) is the propagation speed, and, respectively,
%          velfun(x1,x2,2) and velfun(x1,x2,3) its x1 and x2 derivatives.
% 
% OUTPUT:
%
% dYdt     d[x1 x2 p1 p2]/dt whose integration yields the unknown
%          Cartesian coordinates and slownesses of this system
%
% SEE ALSO:
%
% RAYPATH
%
% Last modified by fjsimons-at-alum.mit.edu, 06/02/2021

% Calculate the speed and its gradient since we need it many times
eval(sprintf('   c=%s(Y,1);',velfun))
% Calculate the speed and its gradient since we need it many times
eval(sprintf('dcdx1=%s(Y,2);',velfun))
eval(sprintf('dcdx2=%s(Y,3);',velfun))

% Bullen & Bolt, 1985, p. 156, eq. (11) 
dYdt(1,1)=c^2*Y(3);
dYdt(2,1)=c^2*Y(4);
dYdt(3,1)=-1/c*dcdx1;
dYdt(4,1)=-1/c*dcdx2;


