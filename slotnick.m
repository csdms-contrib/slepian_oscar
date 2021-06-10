function varargout=slotnick(qxy,alfa,velfun,x0xFxNum)
% [t,rxy,p]=SLOTNICK(qxy,alfa,velfun,x0xFxNum)
%
% Calculates ray paths (position, time and slowness) in Cartesian
% coordinates for a ONE-dimensional velocity field that varies LINEARLY in
% the vertical y direction only, via the exact solution of the
% distance-travel-time equations using a discretization of the horizontal
% dimension x. Only for use with these very restricted models. 
%
% INPUT:
%
% qxy           Source position [x,y], in meters, x horizontal, y down
%               Only for rays that start at the surface - for now!
% alfa          Take-off angle anticlockwise with the vertical, in radians
%               so sin(alfa)/speed is the slowness along x, the
%               "horizontal" slowness, or constant "ray parameter"
%               pi is straight up, pi/2 is horizontal, 0 is straight down
% velfun        Name of a velocity function [default: 'linmod']
% x0xFtnum      Horizontal coordinate specifications, in meter,
%               for use in LINSPACE
%
% OUTPUT:
%
% t             Time, in meters
% rxy           Cartesian position of the ray, in meters
% p             Slowness along the horizontal x direction in seconds/meter
%
% EXAMPLES:
%
% slotnick('demo1')
%
% SEE ALSO: 
%
% BULLENRAYS, MUNKRAYS
%
% NOTES:
%
% G. F. Margrave (2003), Numerical Methods of Exploration Seismology
% Slotnick (1959) gives the analytical form for a single linear-velocity layer
% See also SHOOTRAY. See other Crewes reports. Arenrin, Margrave, and Bancroft

if ~strcmp(qxy,'demo1')
  % The default velocity model 
  defval('velfun','linmod')

  % Horizontal span
  defval('x0xFxNum',[0 30 250]);
  x=linspace(x0xFxNum(1),x0xFxNum(2),x0xFxNum(3));
  % Margrave's example
  % x=1:50:35000;

  % P-velocity hardcoded here
  pors=1;

  % Slope of the velocity model (everywhere...)
  eval(sprintf('h=%s([0 0],%i,3);',velfun,pors))

  % Intercept of the velocity model
  eval(sprintf('k=%s([0 0],%i,1);',velfun,pors))

  % Margrave's example
  %k=1800; h=0.6;

  % The ray parameter
  p=sin(alfa)/k;
  
  % eq. (4.65)
  cs=cos(alfa);
  z=sqrt(1/(p^2*h^2)-(x-cs/(p*h)).^2)-k/h;
  % nonsense protection
  z(imag(z)~=0)=NaN;
  z(real(z)<=0)=NaN;
  x=x(~isnan(z));
  z=real(z(~isnan(z)));

  % eq. (4.63)
  t=1/h*log(([k+h*z]/k).*([1+sqrt(1-p^2*k^2)]./[1+sqrt(1-p^2*(k+h*z).^2)]));

  % Proper utput
  rxy=[x(:) z(:)];
  varns={t,rxy,p};
  varargout=varns(1:nargout);      
elseif strcmp(qxy,'demo1')
   alfa=[20:10:80]*pi/180; index=randi(length(alfa)); clf
 for index=1:length(alfa)
   [t,rxy,p]=slotnick([0 0],alfa(index),'linmod',[0 1800e3 100]);
   plot(rxy(:,1)/1000,rxy(:,2)/1000,'o-'); hold on
   % Compare to eikonal characteristic solution method
   [t,rxy,pxy]=raypath([0 0],alfa(index),'linmod',[0 100 100],0);
   plot(rxy(:,1)/1000,rxy(:,2)/1000,'+'); hold on
 end
 hold off; axis ij; grid on
 xlabel('x kilometers'); ylabel('z kilometers')
 legend('SLOTNICK','RAYTRACE','Location','SouthEast')
end
