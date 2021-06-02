function ydot=rayeq(t,Y,flag,velfun)
% ydot=RAYEQ(t,Y,flag,velfun)
%
% Used by RAYPATH.
%
% Calculates the set of four differential equations Ydot=0
% where Ydot=d[x1 x2 p1 p2]/dt so that the integrated Ydot
% will yield two position coordinates Y[x1 and x2] and the 
% horizontal and vertical slownesses [p1 and p2]
% This is an expression of the ray equations as found in Bullen & Bolt.
% The string variable 'velfun' contains the name of a function with
% a velocity field such as cfun(x1,x2,arg), where arg=1 returns the field,
% arg=2 the x1-derivative and arg=3 the x2-derivative at x1 and x2.
% In this formalism, always set flag to [].
%
% Last modified by fjsimons-at-alum.mit.edu, 13.1.2005

eval([ 'ydot(1,1)=(',velfun,'(Y,1)^2)*Y(3);'])
eval([ 'ydot(2,1)=(',velfun,'(Y,1)^2)*Y(4);'])
eval([ 'ydot(3,1)=-',velfun,'(Y,2)/',velfun,'(Y,1);'])
eval([ 'ydot(4,1)=-',velfun,'(Y,3)/',velfun,'(Y,1);'])

