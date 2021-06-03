function [t,rxy,pxy]=raypath(qxy,alfa,velfun,t0tFtNum)
% [t,rxy,pxy]=raypath(qxy,alfa,velfun,t0tFtNum)
%
% Calculates ray paths (position, time and slowness) in Cartesian
% coordinates for a TWO-dimensional velocity field
%
% INPUT:
%
% qxy           Source position [x1 x2], in meters
% alfa          Take-off angle with the vertical, in radians
%               so sin(alfa)/speed is the slowness along x1, the
%               "horizontal" slowness, or ray parameter
% velfun        Name of a velocity function [default: 'linmod']
% t0tFtnum      Time specifications, in seconds, seconds, and a number
%               for use in LINSPACE [defaulted: 0 s to 2000s in 250 steps]
% resc          Optional scaling factor to rescale Cartesian results
%
% OUTPUT:
%
% t             Time, in meters
% rxy           Cartesian position of the ray, in meters
% pxy           Slowness along the x1 and x2 direction, in seconds/meter
%
% EXAMPLE:
%
% [t,rxy,pxy]=raypath([6350000 pi/2-pi/12.5],pi/4,'linmod');
% plot(rxy(:,1),rxy(:,2)); hold on
%
% Last modified by fjsimons-at-alum.mit.edu, 06/02/2021

% The default velocity model 

% Time span
defval('t0tFtNum',[0 2000 250]);
tspan=linspace(t0tFtNum(1),t0tFtNum(2),t0tFtNum(3));

% Find the speed applicable at the initial conditions
eval(sprintf('c=%s(qxy,%i,1);',velfun,pors))

% Initial conditions
Y0=[qxy sin(alfa)/c cos(alfa/c)];

% Integration of ray equations
options=odeset('RelTol',1e-8);
[t,Y]=ode45('rayeq',tspan,Y0,options,velfun);

% Output
rxy=Y(:,1:2);
pxy=Y(:,3:4);
