function val=linmodpol(rad,psord,arg)
% val=LINMODPOL(rad,psord,arg)
%
% Specifies a simple linear one-dimensional Earth model in polar coordinates
%
% INPUT:
% 
% rad       Radius [m]
% psord     1 P-velocity [m/s]
%           2 S-velocity [m/s]
%           3 density [kg/m^3]
% arg       1 returns the field
%           2 returns the field gradient d(psord)/dr
%
% OUTPUT:
%
% val       The field or its radial derivative
%
% SEE ALSO:
%
% RAYPATHPOL, RAYEQPOL, GROUPRAYS, AK135S, IASP91S, PREMISOS
%
% Last modified by fjsimons-at-alum.mit.edu, 06/09/2021

% Default values
defval('psord',1)
defval('arg',1)

% Slope and offset parameters
c0=25563;
dcdr=-0.0034703;

% There is no distinction in the psord argument here
switch arg
 case 1
  val=rad*dcdr+c0; 
 case 2
  val=dcdr;
end


