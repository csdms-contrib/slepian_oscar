function varargout=polecircle2(xyzE,xyzR,thr,th,method,rref,xver)
% varargout=POLECIRCLE2(xyzE,xyzR,thr,th,method,rref,xver)
%
% Finds (and plots) the Cartesian coordinates of great circle slicing a
% three-dimensional sphere of a certain radius centered at a certain
% point. This circle lies in a PLANE that contains the axis connecting the
% two points (hence, their distance could be a suitable choice for the
% radius of the plotted circle), rotated by an angle measured
% counterclockwise from six o'clock when viewing a pole circle down the
% joining angle.
%
% INPUT:
%
% xyzE        Coordinates of a special point in three dimensions
%             specified as the three-vector [xE yE zE]
% xyzR        Coordinates of the sphere that is the target of our viewing
%             specified as [x0 y0 z0 R] for origin and radius, respectively
% thr         Rotation angle of the circle about the axis joining the
%             points [xE yE zE] and [x0 y0 z0]
% th          Angles defining the segment that shall be drawn [degrees]
%             in the original xy plane counterclockwise from +x, i.e.
%             counterclockwise counting from six o'clock on the circle
%             [default: 100 points on an entire circle]
% method      1 One easy way to perform the procedure
%             2 Another, more complicated way that also works
%               If 'method' is negative, do not produce a plot
% rref        Radius of the viewing sphere [default: unit sphere, radius 1]
% xver        1 Extra verification with continental plotting!
%             0 No verification by continental plotting! [default]
% 
% EXAMPLE:
%
% polecircle2('demo1',32)
% polecircle2('demo2')
% polecircle2('demo3')
% polecircle2('demo4')
%
% Tested on 8.3.0.532 (R2014a) and 9.0.0.341360 (R2016a)
% 
% Last modified by fjsimons-at-alum.mit.edu, 05/05/2021

com.mathworks.services.Prefs.setBooleanPref('EditorGraphicalDebugging',false)

% Default inputs for all variables
defval('xyzE',[0.2017 -0.735 0.647])
defval('thr',0)
defval('th',linspace(0,360,100))
defval('method',1)
defval('rref',1)
defval('xver',0)

if ~isstr(xyzE)
  defval('xyzR',[5*randn(3,1) ; randi(5)])
  
  % Define the joining axis between the two points
  [lonr,latr]=cart2sph(xyzE(1)-xyzR(1),xyzE(2)-xyzR(2),xyzE(3)-xyzR(3));
  lonlatr=[lonr latr]*180/pi;

  % Define the requested pole point in this framework
  [xv,yv,zv]=polecircle(lonlatr,xyzR,thr,-abs(method),rref); hold on
  % Of course, don't forget it is with respect to the sphere center!
  [lonv,latv]=cart2sph(xv-xyzR(1),yv-xyzR(2),zv-xyzR(3));
  lonlatv=[lonv latv]*180/pi;
  
  % And then do what we actually set out to do!
  [x,y,z]=polecircle(lonlatv,xyzR,th,-abs(method),rref); hold on

  % Leave all the plotting until here
  if method>0
    p{1}=plot3(x,y,z,'-');
    xlabel('x'); ylabel('y'); zlabel('z'); 
    grid on; axis image
    hold on
    % The vector from the origin of the coordinate system to the view point
    plot3(0,0,0,'ro');
    plot3([0 xyzE(1)],[0 xyzE(2)],[0 xyzE(3)],'r-');
    plot3(xyzE(1),xyzE(2),xyzE(3),'o','MarkerFaceColor','b','MarkerEdgeColor','b')
    % The vector from the view point to the origin of the sphere
    plot3([xyzR(1) xyzE(1)],[xyzR(2) xyzE(2)],[xyzR(3) xyzE(3)],'b-');
    % The origin of the viewed sphere
    plot3(xyzR(1),xyzR(2),xyzR(3),'v','MarkerFaceColor','r','MarkerEdgeColor','r')
    hold off
    view(3)
    if xver==1
      hold on
      % Fancy continents which helped me find what to do
      [lonp,latp]=cart2sph(xyzE(1),xyzE(2),xyzE(3));
      lonlatp=[lonp latp]*180/pi;
      [~,hc,XYZ,xyze]=plotcont([],[],11,[],[],lonlatp); hold on
      if rref~=1
	delete(hc)
	XYZ=XYZ*rref; xyze=xyze*rref;
	plot3(XYZ(:,1),XYZ(:,2),XYZ(:,3),'k')
	plot3(xyze(:,1),xyze(:,2),xyze(:,3),'k')
      end
      hold off
    end
  end

  % Produce output
  varns={x,y,z,xv,yv,zv};
  varargout=varns(1:nargout);

elseif strcmp(xyzE,'demo1')
  % Grab the input past the first entry, reassign
  defval('xyzR',30)
  
  % THIRD INPUT: A VIEWING ANGLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  thr=xyzR; clear xyzR
  % FIRST INPUT: E.G., A POINT ON EARTH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Guyot Hall in lon/lat and on the unit sphere
  lonlatp=[-74.65475 40.34585]; 
  % Where that is, in three-dimensional space
  [xp,yp,zp]=sph2cart(lonlatp(1)*pi/180,lonlatp(2)*pi/180,rref);

  % SECOND INPUT: E.G., A SATELLITE LOCATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % This is the center of the sphere that we are contemplating
  xyzR=[0.8 0.7 0.9 NaN];
  % Radius is the distance between the sphere center and the special point
  xyzR(:,4)=sqrt([xyzR(:,1)-xp].^2+[xyzR(:,2)-yp].^2+[xyzR(:,3)-zp].^2)/2;

  % The vector from the origin of the coordinate system to the special point
  plot3(0,0,0,'o','MarkerFaceColor','w','MarkerEdgeColor','r'); 
  hold on
  plot3([0 xp],[0 yp],[0 zp],'b-')
  plot3(xp,yp,zp,'o','MarkerFaceColor','b','MarkerEdgeColor','b')

  % The origin of the viewed sphere
  plot3(xyzR(1),xyzR(2),xyzR(3),'v','MarkerFaceColor','r','MarkerEdgeColor','r')

  % The vector from xyzE to xyzR, e.g., joining Earth point to satellite
  plot3([xyzR(1) xp],[xyzR(2) yp],[xyzR(3) zp],'g--');
  % This is the rotation axis that we will be exploring
  [lonr,latr]=cart2sph(xp-xyzR(1),yp-xyzR(2),zp-xyzR(3));
  lonlatr=[lonr latr]*180/pi;

  % Now we draw a circle in a plane containing the joining line, for
  % which we start by using POLECIRCLE using the pole that is the
  % cross product perpendicular to the plane containing the two lines
  xyzV=cross([xp ; yp; zp],xyzR(1:3)); 
  xyzV=xyzV/norm(xyzV)/3;
  [lonv,latv]=cart2sph(xyzV(1),xyzV(2),xyzV(3));
  lonlatv=[lonv latv]*180/pi;
  % Should we want to design a thr for that same axis, we would do
  % thr=270-lonlatv(2);

  % This is the unrotated slice through the satellite sphere
  [xv,yv,zv]=polecircle(lonlatv,xyzR,[],-abs(method),rref);
  hold on
  plot3(xv,yv,zv,'m:')

  % Maybe plot lonlatv right where you think it should go!
  plot3(xyzR(1)+[0 xyzV(1)],xyzR(2)+[0 xyzV(2)],xyzR(3)+[0 xyzV(3)],'k')
  % Maybe also a little version centered on the origin?
  % plot3([0 xyzV(1)],[0 xyzV(2)],[0 xyzV(3)],'k')

  % And now I can turn THAT point to somewhere else on the unit
  % sphere as long as I stay on the great circle perpendicular to the
  % joining axis of the point to the sphere center. Take a look:
  [xr,yr,zr]=polecircle(lonlatr,xyzR,[],-abs(method),rref); hold on
  plot3(xr,yr,zr,'k--')
  % Plot the point that we are actually picking, measure
  % anticlockwise from six o'clock when looking down the joining line
  [xt,yt,zt]=polecircle(lonlatr,xyzR,thr,-abs(method),rref); hold on
  plot3(xt,yt,zt,'ko')
  % Now you invoke POLECIRCLE2 to tilt the satellite radius the right way
  xyzE=[xp ; yp ; zp];
  [x,y,z,xv,yv,zv]=polecircle2(xyzE,xyzR,thr,[],method,rref); hold on
  % xv,yv,zv should plot on top of the xt,yt,zt also just defined above
  plot3(xv,yv,zv,'k+')

  % Beautification
  xlabel('x'); ylabel('y'); zlabel('z');
  grid on; axis image
  hold off

  view(3)
elseif strcmp(xyzE,'demo2')
  thr=linspace(0,180,36);
  for in=1:length(thr); hold on; polecircle2('demo1',thr(in)); pause; end
elseif strcmp(xyzE,'demo3')
  thr=0
  % Guyot Hall in lon/lat and on the unit sphere
  lonlatp=[-74.65475 40.34585]; 
  % Where that is, in three-dimensional space
  [xp,yp,zp]=sph2cart(lonlatp(1)*pi/180,lonlatp(2)*pi/180,1); 
  % Now random satellite positions...
  xyzR=[randn(4,3) nan(4,1)];
  xyzR(:,3)=2;

  % This is the distance between the sphere center and the pole POINT
  xyzR(:,4)=sqrt([xyzR(:,1)-xp].^2+[xyzR(:,2)-yp].^2+[xyzR(:,3)-zp].^2);

  % Now plot the spherical surface when looking straight down into Guyot
  for index=1:size(xyzR,1)
    [~,~,~,xv,yv,zv]=polecircle2([xp yp zp],xyzR(index,:),thr); hold on; pause
  end
  hold off

  % You might zoom in to the (last?)! pole tip and be reminded of the view angle
  title(sprintf('[x_p,y_p,z_p]=[%6.3f,%6.3f,%6.3f]',xp,yp,zp))
  disp(sprintf('[x_p,y_p,z_p]=[%6.3f,%6.3f,%6.3f]',xp,yp,zp))

  % All circles all better go touch Guyot Hall when viewed downpole!
elseif strcmp(xyzE,'demo4')
  lonlatp=[-74.65475 40.34585]; 
  rref=6371;
  [x,y,z]=sph2cart(lonlatp(1)*pi/180,lonlatp(2)*pi/180,rref);
  xyzR=[7000 8000 9000 3000];
  
  clf
  % Looked at head on
  ah(1)=subplot(121);
  polecircle(lonlatp,xyzR,[],[],rref,1)
  title('POLECIRCLE')

  % Try these
  view(-71,-4)
  % This view is looking down the viewing pole
  view([x y z])
  
  % Looked at in the plane of the joining vectors
  xyzV=cross([x ; y; z],xyzR(1:3));
  xyzV=xyzV/norm(xyzV);
  [lonv,latv]=cart2sph(xyzV(1),xyzV(2),xyzV(3));
  lonlatv=[lonv latv]*180/pi;
  % Maybe should return this more easily?
  thr=270-lonlatv(2);

  ah(2)=subplot(122);
  polecircle2([x y z],xyzR,thr,[],[],rref,1)
  title('POLECIRCLE2')

  % Try these
  view(-71,-4)
  % This view is looking down the viewing pole
  view([x y z])
end

