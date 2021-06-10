function val=linmod(rxy,fld,arg)
% val=LINMOD(rxy,fld,arg)
%
% Specifies one-dimensional Earth model in Cartesian coordinates:
% the model is simply linear in the y direction.
%
% INPUT:
% 
% rxy       Cartesian position coordinates [x,y], in m, with 
%           x the horizontal and y positive downward
% fld       1 P-velocity [m/s]
%           2 S-velocity [m/s]
%           3 density [kg/m^3]
% arg       1 returns the field
%           2 returns the field gradient d(fld)/dx
%           3 returns the field gradient d(fld)/dy
%
% OUTPUT:
%
% val       The field or its derivatives
%
% EXAMPLE:
%
% val=linmod([0 0;  0 3e4],1,1); plot(val,[0 3e4]);
%
% SEE ALSO:
%
% BULLEN
%
% Last modified by fjsimons-at-alum.mit.edu, 06/09/2021

% Default values
defval('fld',1)
defval('arg',1)

% Slope and offset parameters
c0=5400;
dcdy=0.039;

% There is no distinction in the fld argument here
switch arg
 case 1
  if prod(size(rxy))==2
    val=rxy(2)*dcdy+c0;
  else
    val=rxy(:,2)*dcdy+c0;
  end
 case 2
  val=0;
 case 3
  val=dcdy;
end


