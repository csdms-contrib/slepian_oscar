function c=swspeed(P,T,S,meth)
% c=SWSPEED(P,T,S,meth)
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
    dcds=0;
    % From Yifeng
    error('Needs to be reviewed and document')
    C1=3.1464e-9;
    C2=-1.478e-6-(6.1185e-10).*pres+(1.0405e-12).*pres.^2;
    C3=(-2.5335e-10).*pres.^2+(1.3621e-7).*pres+3.342e-4;
    C4=(-2.3643e-12).*pres.^3+(2.5974e-8).*pres.^2-(8.1788e-6).*pres-5.8055e-2-(2.59e-8).*pres.^2+(1.4e-5).*pres;
    C5=(3.8504e-10).*pres.^3-(1.7107e-6).*pres.^2+(6.8982e-4).*pres+5.03711+(3.47e-7).*pres.^2-(2.19e-4).*pres;
    % Temperature derivative of the constants?
    dcdt=5*temp.^4.*C1+4*temp.^3.*C2+3*temp.^2.*C3+2*temp.*C4+temp.*C5;

    A1=-3.389e-13.*temp.^2+6.649e-12.*temp+1.1e-10;
    A2=7.988e-12.*temp.^3-1.6002e-10.*temp.^2+9.1041e-8.*temp-3.9064e-7;
    A3=-2.0122e-10.*temp.^4+1.0507e-8.*temp.^3-6.4885e-8.*temp.^2-1.258e-5.*temp+9.4742e-5;
    A4=-3.21e-8*temp.^4+2.006e-6*temp.^3+7.164e-5*temp.^2-1.262e-2*temp+1.389;
    % Pressure derivative of the salinity constants?
    dasalds=A1.*pres.^3+A2.*pres.^2+A3.*pres+A4;

    A5=-2.0122e-10*pres-3.21e-8;
    A6=7.988e-12*pres.^2+1.0507e-8.*pres+2.006e-6;
    A7=-3.389e-13.*pres.^3-1.6002e-10.*pres.^2-6.4885e-8*pres+7.184e-15;
    A8=6.649e-12*pres.^3+9.1041e-8*pres.^2-1.258e-5*pres-1.262e-2;
    % Temperature derivative of the salinity constants?
    dasaldt=sal.*(4*temp.^3.*A5+3*temp.^2.*A6+2*temp.*A7+A8);

    B=-1.922e-2-4.42e-5*temp+(7.3637e-5+1.7945e-7*temp).*pres;
    dbsalds=3/2*sqrt(abs(sal)).*B;
    % Temperature derivative of the salinity constants?
    dbsaldt=sal.*sqrt(abs(sal)).*(-4.42e-5+1.7945e-7*pres);

    D=1.727e-3-7.9836e-6*pres;
    ddsalds=2*sal.*D;
    ddsaldt=0;

    % Temperature and salinity derivatives of the sound speed
    dspeeddt=sqrt(dasaldt.^2+dbsaldt.^2+dcdt.^2+ddsaldt.^2);
    dspeedds=sqrt(dasalds.^2+dbsalds.^2+dcds.^2+ddsalds.^2);

    % SOUND SPEED STANDARD DEVIATION
    c=sqrt((tempSD.*dspeeddt).^2+(salSD.*dspeedds).^2);
end
