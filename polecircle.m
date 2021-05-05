function varargout=polecircle(lonlatp,xyzR,th,method,rref,xver)
% [x,y,z,xp,yp,zp]=POLECIRCLE(lonlatp,xyzR,th,method,rref,xver)
%
% Finds (and plots) the Cartesian coordinates of the great circle slicing a
% three-dimensional sphere of a certain radius centered at a certain point,
% when viewed from a certain point on the unit sphere centered at the origin
% of the coordinate system. This amounts to finding the coordinates of a
% circle, the circumference of a disk, positioned with respect to a certain
% viewing POLE. When plotted and viewed looking from the outside out down
% along the pole, the graph indeed produces a circle. The view pole and the
% connecting vectors are also shown.
%
% INPUT:
%
% lonlatp      Coordinates of the viewing pole on the unit sphere [degrees]
% xyzR         Coordinates of the sphere that is the viewed target object
%              specified as [x0 y0 z0 R] for origin and radius, respectively
% th           Angles defining the segment that shall be drawn [degrees]
%              in the original xy plane counterclockwise from +x, i.e.
%              counterclockwise counting from six o'clock on the circle
%              [default: 100 points on an entire circle]
% method       1 One easy way to perform the procedure
%              2 Another, more complicated way that also works
%                If 'method' is negative, do not produce a plot
% rref         Radius of the viewing sphere (default: unit sphere, radius 1)
% xver         1 Extra verification with continental plotting!
%
% OUTPUT:
%
% x,y,z        Coordinates of the circle bounding the pole-perpendicular disk 
% xp,yp,zp     Coordinates of the tip of the viewing pole
%
% EXAMPLE:
%
% polecircle('demo1') % Step across longitudes for a pretty picture
% polecircle('demo2') % Step across longitudes for a pretty picture
% polecircle('demo3') % An example relevant to satellite geolocation
%
% Tested on 8.3.0.532 (R2014a) and 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 05/05/2021

% Random inputs for all variables
defval('lonlatp',[randi(360) 90-randi(180)])
defval('xyzR',[5*randn(2,1); 0 ; randi(5)])
defval('th',linspace(0,360,100))
defval('method',1)
defval('rref',1)
defval('xver',0)

if ~isstr(lonlatp)
  switch abs(method) 
   case 1
    % Here is an equator in the xy-plane, of the right radius
    [xe,ye,ze]=sph2cart(th/180*pi,0,xyzR(4));
    % Here is that appropriately rotated equator
    xyz=[rotz(-lonlatp(1)*pi/180)*roty(-[90-lonlatp(2)]*pi/180)*...
	 [xe ; ye ; repmat(ze,1,length(ye))]]';
    x=xyz(:,1);
    y=xyz(:,2);
    z=xyz(:,3);
   case 2
    % Find the set of points that goes through great circles at all aziumths
    % at epicentral angular distance of 90 degrees, itself a great circle
    [lon2,lat2]=grcazim(lonlatp,90,180+th,'unitsphere');
    % Convert that circle to a Cartesian coordinate system, with the right radius
    [x,y,z]=sph2cart(lon2*pi/180,lat2*pi/180,xyzR(4));
  end

  % Add the origin of the sphere you are looking at back in!
  x=x+xyzR(1);
  y=y+xyzR(2);
  z=z+xyzR(3);

  % In case you want the view pole also (which you could use with VIEW also!)
  [xp,yp,zp]=sph2cart(lonlatp(1)*pi/180,lonlatp(2)*pi/180,rref);

  % Make the plot
  if method>0
    p{1}=plot3(x,y,z);
    xlabel('x'); ylabel('y'); zlabel('z'); 
    grid on; axis image

    hold on
    if xver==1
      % Fancy continents which helped me find what to do
      [~,hc,XYZ,xyze]=plotcont([],[],11,[],[],lonlatp); hold on
      if rref~=1
	delete(hc)
	XYZ=XYZ*rref; xyze=xyze*rref;
	plot3(XYZ(:,1),XYZ(:,2),XYZ(:,3),'k')
	plot3(xyze(:,1),xyze(:,2),xyze(:,3),'k')
      end
    end

    % The vector from the origin of the coordinate system to the view point
    plot3(0,0,0,'ro');
    plot3([0 xp],[0 yp],[0 zp],'r-');
    plot3(xp,yp,zp,'o','MarkerFaceColor','b','MarkerEdgeColor','b')
    % The vector from the view point to the origin of the sphere
    plot3([xyzR(1) xp],[xyzR(2) yp],[xyzR(3) zp],'b--');
    % The origin of the viewed sphere
    plot3(xyzR(1),xyzR(2),xyzR(3),'v','MarkerFaceColor','r','MarkerEdgeColor','r')
    hold off

    % Matlab's VIEW is measured from the negative y axis... duh
    view(90+round(lonlatp(1)),round(lonlatp(2)));
    % In the view angle, we should see a circle
    % I did this for origin-centered spheres only
    axis(repmat([-1.1 1.1]*[max(abs(xyzR(1:3)))+xyzR(4)],1,3))
    axis tight
    % Perpendicularly to the view angle, we should see a line
  end

  % Produce output
  varns={x,y,z,xp,yp,zp};
  varargout=varns(1:nargout);

elseif strcmp(lonlatp,'demo1')
  % Guyot Hall in lon/lat and on the unit sphere
  lonlatp=[-74.65475 40.34585]; 
  % View some other point from there
  xyzR=[0.8 0.7 0.9 0.3];
  % Step across the LONGITUDES and see what you get
  for index=0:36
    polecircle(lonlatp+[index*10 0],xyzR); hold on
    pause
  end
  hold off
  view(3)
elseif strcmp(lonlatp,'demo2')
  % Guyot Hall in lon/lat and on the unit sphere
  lonlatp=[-74.65475 40.34585]; 
  % View some other point from there
  xyzR=[0.8 0.7 0.9 0.3];
  % Step across the LATITUDES and see what you get
  for index=0:36
    polecircle(lonlatp+[0 index*10],xyzR); hold on
    pause
  end
  hold off
  view(3)
elseif strcmp(lonlatp,'demo3')
  % Guyot Hall in lon/lat and on the unit sphere
  lonlatp=[-74.65475 40.34585]; 
  % Where that is, in three-dimensional space
  [xp,yp,zp]=sph2cart(lonlatp(1)*pi/180,lonlatp(2)*pi/180,1); 
  % Now random satellite positions...
  xyzR=[randn(4,3) nan(4,1)];
  % This is the distance between the sphere center and the pole POINT
  dpo=sqrt([xyzR(:,1)-xp].^2+[xyzR(:,2)-yp].^2+[xyzR(:,3)-zp].^2);

  % But we rather want the perpendicular distance to the pole AXIS...
  dpp=point3line(0,xp,0,yp,0,zp,xyzR(:,1),xyzR(:,2),xyzR(:,3));
  % ... and that is the radius we could be plotting (in projection!)
  xyzR(:,4)=dpp;

  % Now plot the spherical surface when looking straight down into Guyot
  for index=1:size(xyzR,1)
    [~,~,~,xp,yp,zp]=polecircle(lonlatp,xyzR(index,:)); hold on; pause
  end
  hold off

  % You might zoom in to the pole tip and be reminded of the view angle
  title(sprintf('[x_p,y_p,z_p]=[%6.3f,%6.3f,%6.3f]',xp,yp,zp))
  disp(sprintf('[x_p,y_p,z_p]=[%6.3f,%6.3f,%6.3f]',xp,yp,zp))

  % All circles all better go touch Guyot Hall when viewed downpole!
  % Nevertheless, this is not what I wanted to show. See POLECIRCLE2.
end    
