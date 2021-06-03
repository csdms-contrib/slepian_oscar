function [t,rxy,rrtha]=raypathpol(qrth,alfa,velfun,t0tFtNum,rmax)
% [t,rxy,rrtha]=raypathpol(qrth,alfa,velfun,t0tFtNum,rmax)
%
% Calculates ray paths (position, time and angle) in polar coordinates
% for a ONE-dimensional velocity field that varies radially only
%
% INPUT:
%
% qrth          Source position [r theta], in meters and radians
% alfa          Take-off angle, anticlockwise from the vertical, in radians
%               so r*sin(alfa)/speed is the slowness along th, the
%               "horizontal" slowness, or spherical ray parameter
% velfun        Name of a velocity function [default: 'ak135s']
% t0tFtNum      Time specifications, in seconds, seconds, and a number
%               for use in LINSPACE [defaulted: 0 s to 2000s in 500 steps]
% rmax          Radius beyond which we consider the result null and void
%               as the time integration may have gone on for too long
%
% OUTPUT:
%
% t             Time, in meters
% rxy           Cartesian position of the ray, in meters
% rrtha         Polar coordinates of the ray [r, theta, alfa]
%               where rho is in meters, theta and angle in radians and
%               the angle alfa is measured anticlockwise from the vertical
%
% EXAMPLE:
%
% [t,rxy,rrtha]=raypathpol([6350000 pi/2-pi/12.5],pi/4,'ak135s');
% plot(rxy(:,1),rxy(:,2)); hold on
% 
% NOTES:
%
% Very sensitive to the gradient, the number of points calculated and the
% integration method. For rays close to the surface, the velocity
% specification is not good enough, and so on. Use at your own peril.
%
% SEE ALSO:
%
% AUSTVEL1, AUSTVEL2, AK135S, IASP91S, PREMISOS, RAYEQPOL, POLARPLOT
%
% Last modified by fjsimons-at-alum.mit.edu, 06/02/2021

% The default velocity model 
defval('velfun','ak135s')
% Do not leave the Earth
defval('rmax',fralmanac('Radius','Earth'))

% Time span
defval('t0tFtNum',[0 2000 500]);
tspan=linspace(t0tFtNum(1),t0tFtNum(2),t0tFtNum(3));

% Initial conditions - do the rau from the North Pole
Y0=[qrth(1) 0 pi-alfa];

% Integration of ray equations
options=odeset('RelTol',1e-8);
[t,Y]=ode45('rayeqpol',tspan,Y0,options,velfun);

% Generate output - add the proper latitude back in
Y(:,2)=Y(:,2)+qrth(2);
% Protect against erroneous time steps
t=t(Y(:,1)<=rmax,:);
Y=Y(Y(:,1)<=rmax,:);
% Now still add the last bit in there... a bit of a hack when you really
% should do the last time steps more properly
t=[t; t(end)];
Y=[Y; rmax Y(end,2:3)];

% Get the Cartesian position of the ray
[rxy(:,1),rxy(:,2)]=pol2cart(Y(:,2),Y(:,1));
% Get the polar coordinate position of the ray
rrtha=[Y(:,1) Y(:,2) pi-Y(:,3)];
