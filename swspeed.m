function c=swspeed(P,T,S,meth,DP,DT,DS)
% c=SWSPEED(P,T,S,meth,DP,DT,DS)
%
% Ocean sound speed in m/s given pressure, temperature and salinity.
%
% INPUT: 
%
% P       Pressure [decibar]
% T       Temperature [degrees Celsius]
% S       Salinity [parts per thousand]
% meth    1 Following Del Grosso (1974, doi: 10.1121/1.1903388)
%         2 Using the Millero and Li (1994, doi: 10.1121/1.409844)
%           adjustment to Chen and Millero (1977, doi: 10.1121/1.381646)
%         3 Inputs are standard deviations of T and S and in turn the
%           output is standard deviation of the sound speed
%         4 Del Grosso in a different implementation arrangement
%         5 Standard deviations are input and output is one also
% DP      Standard deviation of pressure [decibar]
% DT      Standard deviation of temperature [degrees Celsius]
% DS      Standard deviation of salinity [parts per thousand]
%
% OUTPUT:
%
% c         Sound speed [m/s] or it standard deviation (for meth=3)
%
% EXAMPLE:
%
% swspeed(swpressure(1500,45,1),[],[],1)
%
% RDGDEM3S.f by Michael Carnes, Naval Oceanographic Office (2002)
% CALSNDSPD.m by Yifeng Wang, 03/28/2010
% CALSNDSPDSD.m by Yifeng Wang, 03/28/2010
% Last modified by Thalia Gueroult, 05/10/2023
% Last modified by fjsimons-at-alum.mit.edu, 05/10/2023

% Approximate pressure in dbar at 100 m
defval('P',100)
% Average ocean temperature at surface
defval('T',25)
% Average salinity at surface
defval('S',35)
% Default method is Del Grosso, reported (by SeaBird/IHO) to be better at large depth
defval('meth',1)

switch meth
  case 1 
    % Del Grosso
    % Convert input in decibar = 1e4 Pa to kg/cm^2 of pressure for this calculation, generic
    P=P*1.01972/10;
    % From Del Grosso (1974), eqs 1-6
    C000=1402.392;
    DCT=(0.501109398873e1-(0.550946843172e-1-0.221535969240e-3*T)*T)*T;
    DCS=(0.132952290781e1+0.128955756844e-3*S)*S;
    DCP=(0.156059257041e0+(0.244998688441e-4-0.883392332513e-8*P)*P)*P;
    DCSTP=-0.127562783426e-1*T*S+0.635191613389e-2*T*P +0.265484716608e-7*T*T*P*P ...
          -0.159349479045e-5*T*P*P+0.522116437235e-9*T*P*P*P-0.438031096213e-6*T*T*T*P...
          -0.161674495909e-8*S*S*P*P+0.968403156410e-4*T*T*S+0.485639620015e-5*T*S*S*P...
          -0.340597039004e-3*T*S*P;
    % SOUND SPEED
    c=C000+DCT+DCS+DCP+DCSTP;
  case 2
    % Millero and Li 
    % Convert input in decibar to bar for this calculation
    P=P/10;
    % From Chen and Millero (1977), eqs 3-5
    % S^2 TERM
    D=1.727E-3-7.9836E-6*P;
    % S^3/2 TERM
    B1=7.3637E-5 +1.7945E-7*T;
    B0=-1.922E-2 -4.42E-5*T;
    B=B0+B1.*P;
    % S^1 TERM 
    A3 = (-3.389E-13*T+6.649E-12).*T+1.100E-10;
    A2 = ((7.988E-12*T-1.6002E-10).*T+9.1041E-9).*T-3.9064E-7;
    A1 = (((-2.0122E-10*T+1.0507E-8).*T-6.4885E-8).*T-1.2580E-5).*T+9.4742E-5;
    A0 = (((-3.21E-8*T+2.006E-6).*T+7.164E-5).*T-1.262E-2).*T+1.389;
    A = ((A3.*P+A2).*P+A1).*P+A0;
    % S^0 TERM
    C3=(-2.3643E-12*T+3.8504E-10).*T-9.7729E-9;
    C2=(((1.0405E-12*T-2.5335E-10).*T+2.5974E-8).*T-1.7107E-6).*T+3.1260E-5;
    C1=(((-6.1185E-10*T+1.3621E-7).*T-8.1788E-6).*T+6.8982E-4).*T+0.153563;
    C0=((((3.1464E-9*T-1.47800E-6).*T+3.3420E-4).*T-5.80852E-2).*T+5.03711).*T+1402.388;
    % Millero and Li (1994)
    % S^0 CORRECTION TERM 
    CC1=(1.4E-5*T-2.19E-4).*T+0.0029;
    CC2=(-2.59E-8*T+3.47E-7).*T-4.76E-6;
    CC3=2.68E-9;
    CC=((CC3*P+CC2).*P+CC1).*P;
    C=((C3.*P+C2).*P+C1).*P+C0-CC;
    % SOUND SPEED
    c=C+(A+B.*sqrt(S)+D.*S).*S;
  case 3
    % Standard deviation inputs and outputs
    % Convert input in decibar to bar for this calculation
    P=P/10;

    % From Yifeng
    error('Needs to be reviewed and documented')

    C1=3.1464e-9;
    C2=-1.478e-6-(6.1185e-10).*P+(1.0405e-12).*P.^2;
    C3=(-2.5335e-10).*P.^2+(1.3621e-7).*P+3.342e-4;
    C4=(-2.3643e-12).*P.^3+(2.5974e-8).*P.^2-(8.1788e-6).*P-5.8055e-2-(2.59e-8).*P.^2+(1.4e-5).*P;
    C5=(3.8504e-10).*P.^3-(1.7107e-6).*P.^2+(6.8982e-4).*P+5.03711+(3.47e-7).*P.^2-(2.19e-4).*P;
    % Temperature derivative in decreasing powers of T
    dCdT=5*T.^4.*C1+4*T.^3.*C2+3*T.^2.*C3+2*T.*C4+T.*C5;

    A1=-3.389e-13.*T.^2+6.649e-12.*T+1.1e-10;
    A2=7.988e-12.*T.^3-1.6002e-10.*T.^2+9.1041e-8.*T-3.9064e-7;
    A3=-2.0122e-10.*T.^4+1.0507e-8.*T.^3-6.4885e-8.*T.^2-1.258e-5.*T+9.4742e-5;
    A4=-3.21e-8*T.^4+2.006e-6*T.^3+7.164e-5*T.^2-1.262e-2*T+1.389;
    % Pressure derivative in decreasing powers of P
    dASdS=A1.*P.^3+A2.*P.^2+A3.*P+A4;

    A5=-2.0122e-10*P-3.21e-8;
    A6=7.988e-12*P.^2+1.0507e-8.*P+2.006e-6;
    A7=-3.389e-13.*P.^3-1.6002e-10.*P.^2-6.4885e-8*P+7.184e-15;
    A8=6.649e-12*P.^3+9.1041e-8*P.^2-1.258e-5*P-1.262e-2;
    % Temperature derivative in decreasing powers of T
    dASdT=S.*(4*T.^3.*A5+3*T.^2.*A6+2*T.*A7+A8);

    B=-1.922e-2-4.42e-5*T+(7.3637e-5+1.7945e-7*T).*P;
    dBSdS=3/2*sqrt(abs(S)).*B;
    % Temperature derivative in decreasing powers of P
    dBSdT=S.*sqrt(abs(S)).*(-4.42e-5+1.7945e-7*P);

    D=1.727e-3-7.9836e-6*P;
    dDSdS=2*S.*D;
    dDSdT=0;

    % Temperature and salinity derivatives of the sound speed
    dcdT=sqrt(dASdT.^2+dBSdT.^2+dCdT.^2+dDSdT.^2);
    dcdS=sqrt(dASdS.^2+dBSdT.^2+dCdS.^2+dDSdS.^2);

    % SOUND C STANDARD DEVIATION
    c=sqrt((TSD.*dcdT).^2+(SSD.*dcdS).^2);
 case 4
    % Del Grosso
    % Convert input in decibar = 1e4 Pa to kg/cm^2 of Pressure for this calculation, generic
    P=P*1.01972/10;
    % Get the powers of the expansion
    abc=homopoly;
    TSP=repmat([T S P],size(abc,1),1);
    TSPabc=prod(TSP.^abc,2);

    % From Del Grosso (1974), eqs 1-6
    % The coefficient matrix in columns of T, S, and P
    c_abc=[ 1402.392 +0.501109398873e+1 +0.132952290781e+1 +0.156059257041e+0 ...
	   -0.550946843172e-1 -0.127562783426e-1 +0.128955756844e-3 ...
	   +0.635191613389e-2 0 +0.244998688441e-4 +0.221535969240e-3 ...
	   +0.968403156410e-4 0 0 0 -0.340597039004e-3 0 -0.159349479045e-5 ...
	   0 -0.883392332513e-8 0 0 0 -0.438031096213e-6 0 +0.485639620015e-5 ...
	   0 +0.265484716608e-7 0 -0.161674495909e-8 +0.522116437235e-9 0];
    % Here are those powers for your reference
    % 0 1 0 0 2 1 0 1 0 0 3 2 1 0 2 1 0 1 0 0 3 2 1 3 2 1 0 2 1 0 1 0
    % 0 0 1 0 0 1 2 0 1 0 0 1 2 3 0 1 2 0 1 0 1 2 3 0 1 2 3 0 1 2 0 1
    % 0 0 0 1 0 0 0 1 1 2 0 0 0 0 1 1 1 2 2 3 0 0 0 1 1 1 1 2 2 2 3 3
    
    % SOUND SPEED
    c=c_abc*TSPabc;
 case 5
  % Calculates the Del Grosso standard deviation via the delta method
  tsp=repmat([T S P],size(abc,1),1);
  % Take the power derivatives in the variables
  dcdT=abc(:,1).^2.*([T S P].*[abc(:,1)-1 abs(:,2)   abs(:,3)]  ).^2*DT;
  dcdS=abc(:,2).^2.*([T S P].*[abc(:,1)   abs(:,2)-1 abs(:,3)]  ).^2*DT;
  dcdP=abc(:,3).^2.*([T S P].*[abc(:,1)   abs(:,2)   abs(:,3)-1]).^2*DT;

  % SOUND SPEED STANDARD DEVIATION
  c=sqrt(sum(c_abc.^2*[dcdT dcdS dcdP]));
end
