function varargout=swpressure(dorp,lat,dtop)
% pord=SWPRESSURE(dorp,lat,dtop)
% 
% Pressure/depth in seawater of a global ocean following
% Saunders (1981) "Practical conversion of pressure to depth"
% 10.1175/1520-0485(1981)011<0573:PCOPTD>2.0.CO;2
% 
% INPUT:
% 
% dorp     Depth(s), in positive meters down from the surface, OR:
%          Pressure(s), in decibar (=1e4 Pa)
% lat      Latitude(s), in decimal degrees
% dtop     1 Input is depth and output is pressure [default]    
%          2 Input is pressure and output is depth
%          3 Input is depth and output is pressure [obsolete]
%
% OUTPUT:
%
% pord     Pressure, in decibar (=1e4 Pa), OR:
%          Depth(s), in positive meters down from the surface, OR:
%
% EXAMPLE:
%
% x=rand(1)*1000; lat=rand(1)*180-90;
% diferm(swpressure(swpressure(x,lat,1),lat,2),x)
%
% SEE ALSO:
%
% RDGDEM3S.f by Michael Carnes, Naval Oceanographic Office (2002)
% SW_PRES.f by Phil Morgan, CSIRO (1993)
% CALPRESSURE.m by Yifeng Wang, Princeton (2010)
%
% Last modified by Thalia Gueroult, 05/10/2023
% Last modified by fjsimons-at-alum.mit.edu, 05/10/2023

% Default - the result should be 7500 db give or take
defval('dorp',7321.45)
defval('dtop',1)
defval('lat',30)

% Note that both inputs must be equal sized or one of them scalar
dorp=dorp(:);
lat=lat(:);

% The Saunders parameters c1 [m/db] and c2 [m/db^2]
c1=(5.92+5.25*sin(abs(lat)*pi/180).^2)*1e-3;
c2=2.21*1e-6;

% The equation in m and decibar is the quadratic in 2]
switch dtop
 case 1
  % Depth to pressure via the quadratic equation solution
  pord=[(1-c1)-sqrt((1-c1).^2-4*c2*dorp)]/2/c2;
 case 2
  % Pressure to depth
  pord=(1-c1).*dorp-c2*dorp.^2;
  case 3
  % Note thPythonOceans (note they hardwire for 45 degrees latitude)
  % "From the UNESCO algorithms (referring to ANON (1970) BULLETIN
  % GEODESIQUE) we have this formula for g as a function of latitude"
  % First in kg/cm^2 then in dbar
  pord=(dorp/9.780318*(1.0+(5.2788e-3+2.36e-5*sin(lat*pi/180))*sin(lat*pi/180))+1.092e-6*dorp)/1.01972*10;;
end

% Variable output
varns={pord};
varargout=varns(1:nargout);
