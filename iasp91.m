function val=iasp91(rad,fld,arg)
% val=iasp91(rad,fld,arg)
%
% Interpolates the IASP91 Earth model without discontinuities
%
% INPUT:
%
% rad       Radius [m]
% fld       1 P-velocity [m/s]
%           2 S-velocity [m/s]
%           3 Density [kg/m^3]
% arg       1 need the field
%           2 need the field gradient d(fld)/d(radius)
%
% OUTPUT:
%
% val       The interpolated fields or gradients
%
% Last modified by fjsimons-at-alum.mit.edu, 06/02/2021

% Specify where you keep them
defval('ddir',fullfile(getenv('IFILES'),'EARTHMODELS','MATFILES'))
% Load data
load(fullfile(ddir,'iasp91'))

% Perform the interpolation without thinking about discontinuities
method= 'linear';
switch arg
  case 1
    val=interp1(radius,psd(:,fld),rad,method);    
  case 2
    val=interp1(radius,psdgrad(:,fld),rad,method);
end

  
