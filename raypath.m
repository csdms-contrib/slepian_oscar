function [t,rxy,pxy]=raypath(qxy,alfa,velfun,t0tFtNum,ymin,ymax)
% [t,rxy,pxy]=raypath(qxy,alfa,velfun,t0tFtNum,ymin,ymax)
%
% Calculates ray paths (position, time and slowness) in Cartesian
% coordinates for a (potentially) TWO-dimensional velocity field via the
% characteristics of the eikonal equation, the ray equations.
%
% INPUT:
%
% qxy           Source position [x,y], in meters, x horizontal, y down
% alfa          Take-off angle anticlockwise with the vertical, in radians
%               so sin(alfa)/speed is the slowness along x, the
%               "horizontal" slowness, or constant "ray parameter"
%               pi is straight up, pi/2 is horizontal, 0 is straight down
% velfun        Name of a velocity function [default: 'linmod']
% t0tFtnum      Time specifications, in seconds, seconds, and a number
%               for use in LINSPACE, or if no last number, until tF
% ymin          Depth above which we consider the result null and void
%               as the time integration may have gone on for too long
% ymax          Depth below which we consider the result null and void
%               as the time integration may have gone on for too long.
%
% OUTPUT:
%
% t             Time, in s
% rxy           Cartesian position of the ray, in meters
% pxy           Slowness along the x and y directions, in seconds/meter
%
% EXAMPLES:
%
% [t,rxy,pxy]=raypath([0 14500],50*pi/180,'bullen');
% plot(rxy(:,1),rxy(:,2)); hold on
%
% bullenrays
%
% SEE ALSO:
%
% RAYEQ, RAYPATHPOL, RAYEQPOL, BULLENRAYS
%
% Last modified by fjsimons-at-alum.mit.edu, 06/09/2021

% The default velocity model 

% The default velocity model 
defval('velfun','linmod')
% Do not leave the Earth
defval('ymin',0)
% Do not leave the Earth
defval('ymax',fralmanac('Radius','Earth'))

% Time span - see notes under RAYPATHPOL
defval('t0tFtNum',[0 30 250]);
if prod(size(t0tFtNum))==3
  tspan=linspace(t0tFtNum(1),t0tFtNum(2),t0tFtNum(3));
else
  tspan=t0tFtNum;
end

% P-velocity hardcoded here
pors=1;

% Find the speed applicable at the initial conditions
eval(sprintf('c=%s(qxy,%i,1);',velfun,pors))

% Initial conditions
Y0=[qxy sin(alfa)/c cos(alfa)/c];

% Integration of ray equations
options=odeset('RelTol',1e-8);
[t,Y]=ode45('rayeq',tspan,Y0,options,velfun);

% Protect against erroneous time steps
t=t(Y(:,2)>=ymin,:);
Y=Y(Y(:,2)>=ymin,:);
t=t(Y(:,2)<=ymax,:);
Y=Y(Y(:,2)<=ymax,:);

% Output
rxy=Y(:,1:2);
pxy=Y(:,3:4);
