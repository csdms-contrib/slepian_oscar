function varargout=swpressure(dorp,lat,dtop)
% pord=SWPRESSURE(dorp,lat,dtop)
% 
% Pressure/depth in seawater of a global ocean following
% Saunders (1981) "Practical conversion of pressure to depth"
% 10.1175/1520-0485(1981)011<0573:PCOPTD>2.0.CO;2
% Fofonoff (1983) "Algorithms for the computation of fundamental properties of seawater"
% 10.25607/OBP-1450
% 
% INPUT:
% 
% dorp     Depth(s), in positive meters down from the surface, OR:
%          Pressure(s), in decibar (=1e4 Pa)
% lat      Latitude(s), in decimal degrees
% dtop     1 Input is depth and output is pressure [default, Saunders]    
%          2 Input is pressure and output is depth [Saunders]
%          3 Input is depth and output is pressure [Fofonoff]
%
% OUTPUT:
%
% pord     Pressure, in decibar (=1e4 Pa), OR:
%          Depth(s), in positive meters down from the surface, OR:
%
% EXAMPLE:
%
% SWPRESSURE without input or output just makes a plot.
%
% x=rand(1)*1000; lat=rand(1)*180-90;
% diferm(swpressure(swpressure(x,lat,1),lat,2),x)
% diferm(swpressure(1e4,30,3),9712.653,4)
%
% SEE ALSO:
%
% RDGDEM3S.f by Michael Carnes, Naval Oceanographic Office (2002)
% SW_PRES.f by Phil Morgan, CSIRO (1993)
% CALPRESSURE.m by Yifeng Wang, Princeton (2010)
%
% Last modified by Thalia Gueroult, 05/10/2023
% Last modified by fjsimons-at-alum.mit.edu, 06/08/2023

if nargin>0 || nargout>0
    % Default - the result should be 7500 db give or take
    defval('dorp',7321.45)
    defval('dtop',1)
    defval('lat',30)
    
    % Note that both inputs must be equal sized or one of them scalar
    dorp=dorp(:);
    lat=lat(:);
    
    % The Saunders 1981 parameters c1 [m/db] and c2 [m/db^2]
    c1=(5.92+5.25*sin(abs(lat)*pi/180).^2)*1e-3;
    c2=2.21*1e-6;
    
    % The equation in m and decibar is the quadratic in 2]
    switch dtop
      case 1
        % Saunders 1981 depth to pressure via the quadratic equation solution
        pord=[(1-c1)-sqrt((1-c1).^2-4*c2*dorp)]/2/c2;
      case 2
        % Saunders 1981 pressure to depth as the inverse of case 1 
        pord=(1-c1).*dorp-c2*dorp.^2;
      case 3
        % Fofonoff 1983 DEPTH IN METERS FROM PRESSURE IN DBARS
        % First the effect of latitude and pressure on gravity, approximately
        g=9.780318*(1.0+(5.2788e-3+2.36e-5*sin(lat*pi/180)^2)*sin(lat*pi/180)^2)+1.092e-6*dorp;
        % And the effect of the equation of state, approximately
        pord=[(((-1.82e-15*dorp+2.279e-10).*dorp-2.2512e-5).*dorp+9.72659).*dorp]./g;
    end

    % Variable output
    varns={pord};
    varargout=varns(1:nargout);
else
    % CALIBRATION PLOTS
    clf
    depth=0:5000;
    s45=plot(depth,swpressure(depth,45,1)); hold on
    f45=plot(depth,swpressure(depth,45,3));
    s66=plot(depth,swpressure(depth,66,1));
    f66=plot(depth,swpressure(depth,66,3));
    s00=plot(depth,swpressure(depth,00,1));
    f00=plot(depth,swpressure(depth,00,3));
    hold off
    grid on
    axis image
    longticks(gca)
    l=legend([s45 f45 s00 f00 s66 f66],...
             'Saunders 45\circ','Fofonoff 45\circ',...
             'Saunders 0\circ','Fofonoff 0\circ',...
             'Saunders 66\circ','Fofonoff 66\circ',...
             'Location','NorthWest');
    xlabel('depth under seawater [m]')
    ylabel('pressure [dbar]')
    f45.LineStyle=':';
    f00.LineStyle=':';
    f66.LineStyle=':';
    xlim([min(depth) max(depth)])
    ylim([0 5200])
   
    % diagonal line
    hold on
    yls=ylim;
    xls=xlim;
    set(l,'autoupdate','off')
    g=plot(yls,xls,'Color',grey(8),'LineWidth',0.1,'LineStyle','-');
    hold off
    ugly=0;
    if ugly
        dx=get(gca,'DataAspectRatio') % uselss
        % Extra axis? Ugly. But anyway, 50 MPa
        yyaxis right
        xlim(xls)
        ylim(yls*1e4/1e6)
        ylabel('pressure [MPa]')
        set(gca,'DataAspectRatio',dx) % won't work
    end
    % suggest this
    disp('xlim([4000 5000])')
    disp('ylim([3900 5200])')
end
