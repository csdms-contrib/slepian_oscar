function [t,rxy,rrtha]=raypathpol(qrth,alfa,velfun,t0tFtNum,rmax)
% [t,rxy,rrtha]=raypathpol(qrth,alfa,velfun,t0tFtNum,rmax)
%
% Calculates ray paths (position, time and angle) in polar coordinates
% for a ONE-dimensional velocity field that varies radially only via the
% characteristics of the eikonal equation, the ray equations.
%
% INPUT:
%
% qrth          Source position [r theta], in meters and radians
% alfa          Take-off angle, anticlockwise from the vertical, in radians
%               so r*sin(alfa)/speed is the slowness along th, the
%               "horizontal" slowness, or constant "spherical ray parameter"
% velfun        Name of a velocity function [default: 'ak135s']
% t0tFtNum      Time specifications, in seconds, seconds, and a number
%               for use in LINSPACE, or if no last number, until tF
% rmax          Radius beyond which we consider the result null and void
%               as the time integration may have gone on for too long
%
% OUTPUT:
%
% t             Time, in s
% rxy           Cartesian position of the ray, in meters
% rrtha         Polar coordinates of the ray [r, theta, alfa]
%               where rho is in meters, theta and angle in radians and
%               the angle alfa is measured anticlockwise from the vertical
%
% EXAMPLES:
%
% [t,rxy,rrtha]=raypathpol([6350000 pi/2-pi/12.5],pi/4,'ak135s');
% plot(rxy(:,1),rxy(:,2)); hold on
%
% grouprays
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

% Time span: note the discretization does not make the solution better, you
% may just get more points. Note that you may not reach the surface unless
% you refine at the end. The total travel time does depend on the temporal
% discretization. If you only give it two numbers, they are t0 and tF and
% the ODE solver decides to give you appropriate points in-between
% depending on the tolerance, and all of these affect the accuracy of the
% travel time. 
defval('t0tFtNum',[0 2000]);
if prod(size(t0tFtNum))==3
  tspan=linspace(t0tFtNum(1),t0tFtNum(2),t0tFtNum(3));
else
  tspan=t0tFtNum;
end

% Initial conditions - from the North Pole - note alfa convention in RAYEQ
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

% Get the Cartesian position of the ray - note the POL2CART convention
[rxy(:,1),rxy(:,2)]=pol2cart(pi/2-Y(:,2),Y(:,1));
% Get the polar coordinate position of the ray
rrtha=[Y(:,1) Y(:,2) pi-Y(:,3)];
