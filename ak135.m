function val=ak135(rad,fld,arg)
% val=AK135(rad,fld,arg)
%
% Interpolates the AK135 Earth model without discontinuities
%
% INPUT:
%
% rad       Radius [m]
% fld       1 P-velocity [m/s]
%           2 S-velocity [m/s]
%           3 Density [kg/m^3]
% arg       1 field itself
%           2 gradient
%
% OUTPUT:
%
% val       The interpolated output value
%
% SI Units everywhere
%
% Last modified by fjsimons-at-alum.mit.edu, 12/1/2013

global radius psd psdgrad

if ~length(psdgrad)
  load(fullfile(getenv('IFILES'),'EARTHMODELS','MATFILES','ak135'))
  disp('Velocity and gradient loaded')
end

method= 'linear';
switch arg
  case 1
    val=interp1(radius,psd(:,fld),rad,method);    
  case 2
    val=interp1(radius,psdgrad(:,fld),rad,method);
end

  
