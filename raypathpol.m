function [t,pos,rta]=raypathpol(spos,alfa,velfun,resc)
% [t,pos,rta]=raypathpol(spos,alfa,velfun,resc)
%
% Calculates ray paths in polar coordinates.
%
% INPUT:
%
% spos      Source position [rho theta], in meters
% alfa      Take-off angle (with the vertical) of the ray, in radians
% velfun    Name of a velocity function [default: 'akk135']
% resc      Scale the radius back to this value
%
% OUTPUT:
%
% t         Time
% pos       Cartesian position of the ray
% rta       Rho, Theta and Angle
%
% EXAMPLE:
%
% [t,pos,rta]=raypathpol([6350000 pi/2-pi/12.5],pi/4,'ak135');
% plot(pos(:,1),pos(:,2)); hold on
%
% This program is very sensitive to the exact gradient and the
% number of points calculated and the integration method. No fun.
% Also, for rays close to the surface, the velocity specification is not
% good enough, and so on.... Crap!
%
% See also AUSTVEL1, AUSTVEL2, AK135, IASP91
%
% Last modified by fjsimons-at-alum.mit.edu, 12/1/2013

Erad=fralmanac('Radius','Earth');
defval('resc',Erad)
defval('velfun','ak135')

% Time span
tmin=0; % Minimum time
tmax=2000; % Maximum time
tstep=250; % Maximum number of steps
tint=linspace(tmin,tmax,tstep);

% Initial conditions
initials=[spos(1) 0 pi-alfa];

% Integration of ray equations
more off
options=odeset('RelTol',1e-8);
[t,Y]=ode45('rayeqpol',tint,initials,options,velfun);
more on

% Generate output
Y(:,2)=Y(:,2)+spos(2);
% disp(sprintf('Got rid of %i time steps',sum(Y(:,1)>Erad)))
t=t(Y(:,1)<=Erad,:);
Y=Y(Y(:,1)<=Erad,:);
% Now still add the last bit in there
% ONLY FOR THE P-VELOCITY...
t=[t; 0];
Y=[Y; Erad Y(end,2:3)];

[pos(:,1),pos(:,2)]=pol2cart(Y(:,2),Y(:,1)/Erad*resc);
rta=[Y(:,1) Y(:,2) pi-Y(:,3)];

% Reminder of parameters
% disp([ 'tmin= ',num2str(tmin)])
% disp([ 'tmax= ',num2str(tmax)])
% disp([ 'tstep= ',num2str(tstep)])
