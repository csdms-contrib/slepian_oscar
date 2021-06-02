function val=iasp91s(rad,fld,arg)
% val=iasp91S(rad,fld,arg)
%
% Interpolates the IASP91 Earth model pretreated to smooth over
% discontinuities, and its radial gradient
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
% val       The interpolated fields or gradients
%
% SEE ALSO:
%
% AK135S, PREMISOS, EARTHMODEL, MODPREP
%
% Last modified by fjsimons-at-alum.mit.edu, 06/02/2021

% Specify where you keep them
defval('ddir',fullfile(getenv('IFILES'),'EARTHMODELS','MATFILES'))
% Load specially prepared data which contain radius, psd, psdgrad
load(fullfile(ddir,'iasp91s'))

% Perform the interpolation without thinking about discontinuities
method= 'linear';
switch arg
  case 1
    val=interp1(radius,psd(:,fld),rad,method);    
  case 2
    val=interp1(radius,psdgrad(:,fld),rad,method);
end

  
