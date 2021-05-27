function pbar=oceanpressure(dm,lat)
% pbar=OCEANPRESSURE(dm,lat)
% 
% Calculate pressure in seawater of a global ocean
% Saunders (1981) Practical Conversion of Pressure to Depth
% 10.1175/1520-0485(1981)011<0573:PCOPTD>2.0.CO;2
% 
% INPUT:
% 
% dm       Depth(s), in positive meters down from the surface
% lat      Latitude, in decimal degrees
%
% OUTPUT:
%
% pbar     Pressure, in bar 
%
% Written by Yifeng Wang, 03/28/2010

% parameter
DEG2RAD = pi/180;
pres=zeros(length(depth),length(lat));

% calculation
X=sin(abs(lat)*DEG2RAD);
C1=5.92e-3+X.^2*5.25e-3;
for j=1:length(depth)
    pres(j,:)=((1-C1)-sqrt(((1-C1).^2)-(8.84e-6*depth(j))))/4.42e-6/10;
end

