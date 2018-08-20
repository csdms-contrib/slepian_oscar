function varargout=reid(mag,MlMb,Del,f,phi,alphar,betar,alphaw,rhow,P0)
% [P,theta]=REID(mag,MlMb,Del,f,phi,alphar,betar,alphaw,rhow,P0)
%
% Calculates the pressure of an earthquake of a given magnitude
%
% INPUT:
%
% mag         'Mb' for body-wave teleseismic magnitude (GUTENBERGRICHTER)
%             'Ml' for local magnitude (WOODANDERSON)
% MlMb        Relevant magnitude of the event
% Del         Epicentral distance (in degrees)
% f           Frequency of the incoming wave, in Hz [defaults: 1 or 5]
% phi         Incidence angles with the normal [degrees, defaults: 90 90 or horizontal]
% alphar      P-wave speed in the rock in m/s [default: 5800 m/s for IASP91]
% betar       S-wave speed in the rock in m/s [default: 3360 m/s for IASP91]
% alphaw      P-wave speed in water in m/s [default: 1500 m/s]
% rhow        Density of the water in kg/m^3 [default: 1000 kg/m3]
% P0          Reference pressure (cruising pressure, in dbar, default 700)
%
% OUTPUT:
%
% P(1)        Pressure of the incoming wave P-wave, in Pa (=10 mubar)
% P(2)        Pressure of the incoming wave S-wave, in Pa (=10 mubar)
% theta(1)    Outgoing angle of the incoming P-wave, in degrees
% theta(2)    Outgoing angle of the incoming S-wave, in degrees
%
% EXAMPLE:
%
% "Refute" the likely "error" of Reid (1973).
%
% reid('Ml',0,10/fralmanac('DegDis')*1000,20)
%
% SEE ALSO: WOODANDERSON, GUTENBERGRICHTER 
% 
% Last modified by fjsimons-at-alum.mit.edu, 07/07/2008
% After Reid, GJRAS 1973, correcting a typo on their page 367, and
% noticing other errors.

defval('MlMb',0)
defval('Del',10/fralmanac('DegDis')*1000)
defval('dispo',1)

if Del*fralmanac('DegDis')/1000<600
  defval('mag','Ml')
else
  defval('mag','Mb')
end

defval('alphar',5800) % Reid has 6000
defval('phi',[90 90])
defval('betar',3360) % Reid has alphar/sqrt(3) for Poisson solid
defval('alphaw',1500)
defval('rhow',1000)
defval('P0',700)

if dispo==1
  clc
end

% Rough ground motion amplitude for these parameters, in m
switch mag
 case 'Mb'
  defval('f',1)
  A=gutenbergrichter(MlMb,Del,1/f)/1e6;
  if dispo==1
    disp(sprintf('d= %i km ; Using GUTENBERGRICHTER displacement amplitude',...
		 round(Del*fralmanac('DegDis')/1000)))
  end
 case 'Ml'
   defval('f',5)
   A=woodanderson(MlMb,Del)/1e6;
   if dispo==1
     disp(sprintf('d= %i km ;  using WOODANDERSON for displacement amplitude',...
		  round(Del*fralmanac('DegDis')/1000)))
   end
end

if dispo==1
  disp(sprintf('Incidence angles are %5.3f and %5.3f degrees',phi(1),phi(2)));
end

% Convert incidence angle to radians
phi=phi*pi/180;

% Now we have the predicted "amplitude" but certainly need to modify this
% to take into account the incidence angle
A=A*cos(phi);

if dispo==1
  % Display frequency
  disp(sprintf('Frequency is %3.1f Hz',f))
  
  % Display amplitude
  disp(sprintf('Ground motion amplitude for P is %3.2e m or %5.3f micrometer or %i nm (millimicron)',...
	       A(1),A(1)*1e6,round(A(1)*1e9)))
  disp(sprintf('Ground motion amplitude for S is %3.2e m or %5.3f micrometer or %i nm (millimicron)',...
	       A(2),A(2)*1e6,round(A(2)*1e9)))
end

% Angular frequency
omega=2*pi*f;

% Snells's law sits in here to calculate the upcoming angles in the water
theta=asin(alphaw./[alphar betar].*sin(phi));

if dispo==1
  % Display theta
  disp(sprintf(...
      'The takeoff angles in the water are %4.1f and %4.1f degrees for P and S',...
      theta*180/pi));
end

% Pressure amplification of the amplitude of the incoming pulse
P=rhow*alphaw*omega./cos(theta);

% And this is pressure in Pa=10^{-5} bars=10^{-4} dbar=10^{-2} mbar= 10 microbar
P=P.*A;

% Convert to degrees
theta=theta*180/pi;

% Convert cruising pressure to Pa from dbar, 1 Pa = 1e-4 dbar
P0=P0*1e4;

% Display cruising/reference depth in m
d=P0/rhow/fralmanac('GravAcc');
if dispo==1
  display(sprintf('Cruising (reference) depth is %8.3f m',d))
end

% Now realize we actually get the pressure in decibar and that 1 decibar
% equals about one meter, and 1 decibar equals 10^4 Pa. 

% And the ratios of both pressures.
Prat=P/P0;

if dispo==1
  % Display results
  display(sprintf('Pressure of P and S %8.3f and %8.3f mm(H20)',P/10))
  display(sprintf('                    %8.3f and %8.3f Pa',P))
  display(sprintf('                    %8.3f and %8.3f microbar',P*10))
  display(sprintf('Cruising pressure  P0  %7.2e Pa or %5.1f dbar',P0,P0/1e4))
  display(sprintf('Pressure ratios to P0  %3.1e and %3.1e',Prat))
  display(sprintf('Pressure ratios to P0  %i    and %i dB re P0',...
		  round(20*log10(Prat/P0))))
  disp(' ')
end

% But really, what matters, is the Pa with respect to the self-noise
% level or the bobbing about.

% Optional output
varns={P,theta};
varargout=varns(1:nargout);

% NOW PUT IN THE RIGHT RAY PARAMETER !! AND CHECK THAT THE UNITS OF
% DISPLACEMENT ... ARE REMOTELY RIGHT ... E.G. CROSS CHECK WITH WU AND
% ZHAO. 

%pause

