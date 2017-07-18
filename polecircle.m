function [x,y,z]=polecircle(lonlatp,xyzR,N,method)
% [x,y,z]=POLECIRCLE(lonlatp,xyzR,N,method)
%
% Finds the Cartesian coordinates of the great circle slicing a
% three-dimensional sphere of a certain radius centered at a certain point,
% when viewed from a certain point on the unit sphere centered at the
% origin. This amounts to finding the coordinates of a circle, the
% circumference of a disk, positioned with respect to a certain pole.
%
% INPUT:
%
% lonlatp      Coordinates of the viewing pole [degrees]
% xyzR         Coordinates of the sphere
% N            Number of points defining the circle
% method       1 One easy way
%              2 Another, more complicated way
%
% OUTPUT:
%
% x,y,z     Coordinates of the circle bounding the pole-perpendicular disk 
%
% EXAMPLE:
%
% Four spheres which should intersect at the right location!
% 
%% Guyot Hall in lon/lat and on the unit sphere
% lonlatp=[-74.65475 40.34585];
% [xp,yp,zp]=sph2cart(lonlatp(1)*pi/180,lonlatp(2)*pi/180,1); 
%% Four random satellite positions...
% xyzR=100*randn(4,3);
%% at the exact right (because: computed) distance...
% xyzR(:,4)=sqrt([xyzR(:,1)-xp].^2+[xyzR(:,2)-yp].^2+[xyzR(:,3)-zp].^2);
%% Plot those positions
% plot3(xp,yp,zp,'bs'); hold on; plot3(xyzR(:,1),xyzR(:,2),xyzR(:,3),'+')
%% Add the continents if you wish, to make sure it's right
% plotcont([],[],11,[],[],lonlatp)
%% Now let's look at all of those from a common view angle 
%% In which case we still need to adjust for the difference in angle
% between the look angle and the view point
% for index=1:size(xyzR,1)
%  hold on; polecircle(lonlatp,xyzR(index,:),N); hold on
% end
%% Them circles all better go through Guyot Hall!
%
% Last modified by fjsimons-at-alum.mit.edu, 07/18/2017

% Random inputs for all variables
defval('lonlatp',[randi(360) 90-randi(180)])
defval('xyzR',[50*randn(3,1) ; randi(5)])
defval('N',100)
defval('method',1)

switch method 
 case 1
  % Here is an equator in the plane, at the right radius
  [xe,ye,ze]=sph2cart(linspace(0,2*pi,N),0,xyzR(4));
  % Here is that appropriately rotated equator
  xyz=deal([rotz(-lonlatp(1)*pi/180)*roty(-[90-lonlatp(2)]*pi/180)*...
	     [xe ; ye ; repmat(ze,1,length(ye))]]');
  x=xyz(:,1);
  y=xyz(:,2);
  z=xyz(:,3);
 case 2
   % Find the set of points that goes through great circles at all aziumths
   % at epicentral angular distance of 90 degrees, itself a great circle
   [lon2,lat2]=grcazim(lonlatp,90,linspace(0,360,N),'unitsphere');
   % Convert that circle to a Cartesian coordinate system, with the right radius
   [x,y,z]=sph2cart(lon2*pi/180,lat2*pi/180,xyzR(4));
end

% Add the origin of the sphere you are looking at back in!
x=x+xyzR(1);
y=y+xyzR(2);
z=z+xyzR(3);

% Plot, this is how I got there, by looking
plot3(x,y,z); 
xlabel('x'); ylabel('y'); zlabel('z'); 
grid on; axis image

% Fancy continents which helped me find what to do
% hold on ; plotcont([],[],11,[],[],lonlatp); hold on

% In case you want the pole also (which you could use with VIEW also!
% I did this for origin-centered spheres only
%[xp,yp,zp]=sph2cart(lonlatp(1)*pi/180,lonlatp(2)*pi/180,1);
%hold on; plot3([xyzR(1) xp],[xyzR(2) yp],[xyzR(3) zp],'b+-'); hold off

% Matlab's VIEW is measured from the negative y axis... duh
view(90+round(lonlatp(1)),round(lonlatp(2)));
% In the view angle, we should see a circle
% I did this for origin-centered spheres only
%axis(repmat([-1.1 1.1]*xyzR(4),1,3))
% Perpedicularly to the view angle, we should see a line

