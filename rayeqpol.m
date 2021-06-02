function ydot=rayeqpol(t,Y,flag,velfun)
% ydot=rayeqpol(t,Y,flag,velfun)
%
% Used by RAYPATHPOL.
%
% Calculates the set of four differential equations Ydot=0
% where Ydot=d[rho theta inc]/dt in polar coordinates.
%
% Last used by fjsimons-at-alum.mit.edu, May 10th, 2004

svel=1;% 1 for pvel, 2 for svel

eval([ 'spd=',velfun,'(Y(1),',num2str(svel),',1);'])
eval([ 'dspd=',velfun,'(Y(1),',num2str(svel),',2);'])

ydot(1,1)=spd*cos(Y(3));
ydot(2,1)=spd/Y(1)*sin(Y(3));
ydot(3,1)=sin(Y(3))*(dspd-spd/Y(1));
