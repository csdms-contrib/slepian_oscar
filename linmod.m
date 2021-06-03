function val=linmod(rxy,fld,arg)
% val=LINMOD(rxy,fld,arg)
%
% Specifies a simple linear one-dimensional Earth model in Cartesian coordinates
%
% INPUT:
% 
% rxy       Cartesian position coordinates [x1, x2]
% fld       1 P-velocity [m/s]
%           2 S-velocity [m/s]
%           3 density [kg/m^3]
% arg       1 need the field
%           2 need the field gradient d(fld)/d(x1)
%           3 need the field gradient d(fld)/d(x2)
%
% OUTPUT:
%
% val       The field or its derivatives
%
% Last modified by fjsimons-at-alum.mit.edu, 06/02/2021

% Slope and offset parameters for the Bullen and Bolt example
rico=
offs=

% There is no distinction in the fld argument here
switch arg
 case 1
  val=rad*rico+offs; 
 case 2
  val=rico;
 case 3
  val=0;
end


