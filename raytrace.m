function varargout=raytrace(rquake,p,c,r)
% [rr,del,s,alfa]=raytrace(rquake,p,c,r)
%
% Tracing of turning rays in a piecewise linear velocity model for a
% spherical earth, with discontinuities, vectorized analytic solution.
% This appears to work for Cartesian and spherical coordinates.
%
% INPUT:
%
% rquake    Radius of hypocenter [m]
% p         Spherical ray parameter [s/degrees]
% c         Wave speeds [m/s] specified at r
% r         Radial coordinate of the wavespeeds c
%
% OUTPUT:
%
% rr        Ray radius [m]
% del       Epicentral distance
% s         Ray length [m]
% alfa      Take-off angle, anticlockwise from the vertical, in radians
% t         Where is the time now! Need to calculate also!
%
% SEE ALSO:
%
% RAYPATH, RAYPATHPOL, SLOTNICK
%
% EXAMPLE:
%
% raytrace('demo1')
%
% Also doesn't quite match with the IRIS Web Service, does it
% https://service.iris.edu/irisws/traveltime/1/query?distdeg=80&evdepth=12.5&phases=P&model=ak135
%
% Written by Hrafnkell Karason, MIT, about 1998
% Last modified by fjsimons-at-alum.mit.edu, 06/02/2021

if ~strcmp(rquake,'demo1')
  % Must begin with a sorted set or it is no good
  [r,i]=sort(r(:)); c=c(i(:));

  % Convert ray parameter from s/deg to s/rad
  p=p*180/pi;

  % Model preparation: reduce model to layer shells specified by top and
  % bottom radii, and then make a linear model for the wavespeed which you
  % represent as an approximate discrete radial derivative dc/dr, and then
  % project that c(r) model onto the intersection with zero radius. 

  % Radii and velocity of top of shells being linearly modeled
  rb=r(1:end-1); vb=c(1:end-1);
  % Radii and velocity of bottom of shells
  rt=r(2:end); vt=c(2:end);
  % Take out the discontinuities since you now have a stack of interfaces
  s=find(rb==rt); rb(s)=[]; rt(s)=[]; vb(s)=[]; vt(s)=[];
  % The velocity slope (vt-vb)/(rt-rb)
  h=(vt-vb)./(rt-rb);
  % The velocity intercept at zero radius, vt-h*rt
  k=vt-h.*rt;

  % How many layers specified?
  l=length(rb);

  % So the model is v(r)=k+h*r locally and the ray parameter is p=r*sin(th)/v
  % and therefore at the turning point p=r/v=r/(k+hr) hence r=pk/(1-ph)
  % Prepare to calculate bottoming depth
  rmins=p*k./(1-p*h);
  % ...which must be contained within the boundaries of this model...
  rmins=rmins(find(rb<rmins & rmins<rt));

  % ... in which case do proceed
  if  ~isempty(rmins)
    % And this is the one bottoming depth / turning point
    rmin=rmins(end);
    % The ray exists but now make sure the earthquake is right for it
    % The discretization of the solution is in radius
    if rquake>=rmin
      % Find the largest radius that is below the turning point
      a=max(find(rb<rmin));
      % Find the tops of all the layers from the turning point up
      rttmp=rt(a:l);
      % Find the bottoms of all the layers from the turning point up
      rbtmp=[rmin; rb(a+1:l)];
      % Find the local velocity slope h and intercept k
      htmp=h(a:l);
      ktmp=k(a:l);
      % Find the largest radius that is below the hypocenter
      b=max(find(rbtmp<rquake));
      % Local top and bottom radii with the eartquake inserted as an extra point
      rbtmp=[rbtmp(1:b);   rquake ; rbtmp(b+1:end)];
      rttmp=[rttmp(1:b-1); rquake ; rttmp(b  :end)];
      % Calculate takeoff angle in degrees to within two digits
      alfa=round(100*asin([ktmp(b)+rquake*htmp(b)]*p/rquake)*180/pi)/100;
      % Local slopes h and intercepts l with the point for the earthquake inserted
      htmp=htmp([  1:b        b          b+1:end]');
      ktmp=ktmp([  1:b        b          b+1:end]');
      % Set up intermediate variables for the necessary expressions
      % The term in [1-p^2*(h+kr)^2] that expands in r^2
      A=-ktmp.^2*p^2;
      % The term in [1-p^2*(h+kr)^2] that expands in r^1
      B=-2*htmp.*ktmp*p^2;
      % The term in [1-p^2*(h+kr)^2] that expands in r^0
      C=1-htmp.^2*p^2;
      % sqrt([1-p^2*(h+kr)^2]) expanded in powers of r for both top and bottom
      Et=sqrt(C.*rttmp.^2+B.*rttmp+A);
      Eb=sqrt(C.*rbtmp.^2+B.*rbtmp+A);
      % The above was a quadratic equation and below is the negative determinant
      Q=4*A.*C-B.^2;
      
      % Check and report on real/imag etc
      
      % Should I know that asinh(x)=log(x+sqrt(1+x^2)) or is that irrelevant here??
      % Looks like the key is that you're going to co-solve for at which
      % time that arrive at z and where they are at x as a way to avoid
      % having to discretize x a priori. That's how it compares to
      % RAYPATHPOL.
      % Check real/imaginary here, wonder what it needs to be, maybe use REALIZE
      F=log((2*sqrt(C).*Et+2*C.*rttmp+B)./...
	    (2*sqrt(C).*Eb+2*C.*rbtmp+B));
      % The discretized form of x(p)=int(pv/sqrt(1-p^2v^2))dz is:
      %          Sum over k interfaces [p*vk]/sqrt(1-p^2vk^2)deltazk
      % Calculate epicentral distance for the downgoing leg on the radial discretization
      del=flipud(realize([0; cumsum(flipud(p*(htmp./sqrt(C).*F...
					   -(asinh((B.*rttmp+2*A)./(rttmp.*sqrt(Q)))...
					     -asinh((B.*rbtmp+2*A)./(rbtmp.*sqrt(Q)))).*ktmp./sqrt(A))))]));
      % Calculate ray length - is that the actual segment between the
      % points or the linear stretch?
      s=flipud(real([0; cumsum(flipud((Et-Eb)./C-B/2./C.^(3/2).*F))]));
      % The discretized form of t(p)=int([1/vz]/sqrt(1-p^2v^2))dz is:
      %           sum over k interfaces [1/vk]/sqrt(1-p^2v^2)deltazk

      % Prepare output
      rr=[rbtmp ; rttmp(end)];
      % You have the whole ray but you only need to start at the earthquake
      u=find(rr<=rquake);
      % Symmetrize from the turning point - Change from HK the one
      % subtracted term at the end of the next two
      del=[flipud(del(u))-del(u(end)) ; 2*max(del)-del(2:end)-del(u(end))];
      s  =[flipud(  s(u))-  s(u(end)) ;   2*max(s)-s(2:end)-s(u(end))];
      rr=[flipud( rr(u))              ;             rr(2:end)];
    else
      disp(['Ray parameter ' num2str(p/180*pi) ' doesn''t exist at this depth'])
      del=[ NaN];
      rr=nan;
      s=nan;
    end
  else
    disp(['Ray parameter ' num2str(p/180*pi) ' doesn''t exist in this Earth model']) 
    del=[ NaN];
    rr=nan;
    s=nan;
  end
  
  % Variable output
  varns={rr,del,s,alfa};
  varargout=varns(1:nargout);
elseif strcmp(rquake,'demo1')
  defval('ddir','/u/fjsimons/IFILES/EARTHMODELS/MATFILES/')
  load(fullfile(ddir,'ak135s')); 

  % Pick depth and some ray parameter
  qdepth=randi(670e3);
  p=rand*20;

  % Some special cases
  spec=2;
  switch spec
    case 1
     qdepth=481e3;
     p=19.37;
    case 2
     qdepth=200e3;
     p=4;
  end

  % Some issues remaining since eikonal doesn't handle discontinuities well
  polmol='ak135s';
  % Switch at random, watch the graph annotation
  if round(rand(1))
    % Working beautifully - as it should
    polmol='linmodpol';
    psd(:,1)=linmodpol(0,1,1)+linmodpol(0,1,2)*radius;
  else
    % Working beautifully - as it should
    polmol='bullenpol';
    psd(:,1)=bullenpol(0,1,1)+bullenpol(0,1,2)*radius;
  end
  
  clf
  % Method I
  try
    [rr,del,s,alfa]=raytrace([max(radius)-qdepth],p,psd(:,1),radius); 
    pk=plot(del*180/pi,[max(radius)-rr]/1000,'+-','LineWidth',2); hold on
    rtdist=max(del)*180/pi;
    
    % Method II
    [t,rxy,rrtha]=raypathpol([max(radius)-qdepth 0],alfa*pi/180,polmol);
    pf=plot(rrtha(:,2)*180/pi,[max(radius)-rrtha(:,1)]/1000,'-+'); hold off
    % Remember that we fiddled with the end
    rpdist=max(rrtha(:,2))*180/pi;
    
    % Check the alpha's that come out here...

    legend('RAYTRACE','RAYPATHPOL','Location','SouthEast')
    disp(sprintf('\nRAYPATHPOL (truncated?) travel time %4.2f s\n',max(t)))
    
    if strcmp(polmol,'ak135')
      % Simple version of IrisFetch
      ws='https://service.iris.edu/irisws/traveltime/1/query';
      parampairs={'distdeg',rpdist,'evdepth',round(qdepth/1000),'model','ak135','phases','P'};
      wq=sprintf('distdeg=%5.2f&evdepth=%i&phases=P&model=ak135',rtdist,round(qdepth/1000));
      try
	[s,~]=urlread(ws,'get',parampairs);
      catch
	disp(sprintf('%s?%s',ws,wq))
      end
    end

    axes(gca)
    axis ij
    grid on
    % You'll see that RAYPATH hits the specified radii exactly whereas
    % RAYPATHPOL follows time increments - and yet other methods would
    % discretize the range variable first
    %set(gca,'YTick',unique([max(radius)-radius]/1000)')
    xlabel(sprintf('epicentral distance [%s]',str2mat(176)))
    ylabel('depth (km)')
    axis tight
    axis(xpand(axis))
    %  axis([-10 180 -100 6000])
    %  axis([-10 30 -100 700])
    %  axis([7 12 500 530])
    shrink(gca,1,1.1)
    
    tt=title(sprintf('RAYTRACE vs RAYPATHPOL | %s=%4.2f%s | depth %i km | p=%4.2f s/%s | %s=%4.2f%s | %s',...
		     '\Delta',rtdist,str2mat(176),...
		     round(qdepth/1000),p,'deg','\alpha',alfa,str2mat(176),upper(polmol)),'interpreter','tex');
    % This depends on the screen resolution etc, very annoying
    movev(tt,-10)
  end
end
