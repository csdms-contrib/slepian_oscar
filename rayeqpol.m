function dYdt=rayeqpol(t,Y,flag,velfun)
% dYdt=RAYEQPOL(t,Y,flag,velfun)
%
% Specifies the coupled system of differential equations for position and
% angle with the radial basis vector in seismic ray tracing, for a velocity
% model that is constant in time, and specified with its radial derivative,
% in polar coordinates.
%
% INPUT:
%
% t        Times for which the derivatives are being calculated; note
%          that there is no time-dependence in this particular system
% Y        The unknown function whose time-derivatives are being specified:
%          [r theta alfa] with r,theta polar coordinates and alfa the
%          angle that the ray makes with the radial basis vector
% flag     A passthrough option flag that needs to remain empty
% velfun   Function that interpolates velocity model or its radial
%          gradient, so that velfun(r,[],1) is the propagation speed, and
%          velfun(r,[],2) its r derivative. The empty variable is for P, S.
%
% OUTPUT:
%
% dYdt     d[rho theta alfa]/dt in polar coordinates and takeoff angle
%          measured anticlockwise from the vertical
%
% SEE ALSO:
%
% RAYPATHPOL, RAYPATH, RAYEQ, GROUPRAYS
%
% Last modified by fjsimons-at-alum.mit.edu, 06/08/2021

% P-velocity hardcoded here
pors=1;

% Find the applicable speed
eval(sprintf('c=%s(Y(1),%i,1);',velfun,pors))
% Find the radial speed gradient
eval(sprintf('dcdr=%s(Y(1),%i,2);',velfun,pors))

% Julian 1970, eq. (9)-(13) for one-dimensional media
dYdt(1,1)=c*cos(Y(3));
dYdt(2,1)=c*sin(Y(3))/Y(1);
dYdt(3,1)=sin(Y(3))*(dcdr-c/Y(1));
