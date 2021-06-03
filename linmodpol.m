function val=linmodpol(rad,fld,arg)
% val=LINMODPOL(rad,fld,arg)
%
% Specifies a simple linear one-dimensional Earth model in polar coordinates
%
% INPUT:
% 
% rad       Radius [m]
% fld       1 P-velocity [m/s]
%           2 S-velocity [m/s]
%           3 density [kg/m^3]
% arg       1 need the field
%           2 need the field gradient d(fld)/d(radius)
%
% OUTPUT:
%
% val       The field or its radial derivative
%
% SEE ALSO:
%
% RAYPATHPOL, RAYEQPOL, GROUPRAYS, AK135S, IASP91S, PREMISOS
%
% Last modified by fjsimons-at-alum.mit.edu, 06/02/2021

% Slope and offset parameters
rico=-0.0034703;
offs=25563;

% There is no distinction in the fld argument here
switch arg
 case 1
  val=rad*rico+offs; 
 case 2
  val=rico;
end


