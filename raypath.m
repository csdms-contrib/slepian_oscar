function [t,pos,slow]=raypath(spos,alfa,velfun)
% [t,pos,slow]=raypath(spos,alfa,velfun)
%
% Calculates ray paths in Cartesian coordinates.
%
% Calculates ray paths for a two-dimensional velocity field
% specified by the string 'velfun' for a source at position
% 'spos'=[x1 x2] and a take-off angle (with the vertical) of the ray,
% 'alfa'. Angle in radians, sin(alfa)/c is the x1-slowness.
%
% Calculated are times 't', positions 'pos' and horizontal and vertical 
% slownesses 'slow'. The horizontal slowness is the ray parameter; this
% remains constant for a given ray.  The default integration total time is
% 100 s in 100 equally spaced steps.  Each row in solution array 
% Y=[pos slow] corresponds to a time returned  in column vector 't'.  
%
% Integration of a set of four  coupled differential equations (ray
% equations) given in the function 'rayeq' as described
% by Bullen and Bolt, 1985, "An introduction to the theory of seismology",  
% pp 154-157.

% Last modified by FJS, December 13th 1998

% Time span
tmin=0; % Minimum time
tmax=1200; % Maximum time
tstep=200; % Maximum number of steps
tint=linspace(tmin,tmax,tstep);
disp([ 'tmin= ',num2str(tmin)])
disp([ 'tmax= ',num2str(tmax)])
disp([ 'tstep= ',num2str(tstep)])
%tint=[0 100];

% Initial conditions
eval([ 'initials=[spos sin(alfa)/',velfun,...
      '(spos,1)  cos(alfa)/',velfun,'(spos,1)];'])

% Integration of ray equations
[t,Y]=ode45('rayeq',tint,initials,[],velfun);

% Output
pos=Y(:,1:2);
slow=Y(:,3:4);
