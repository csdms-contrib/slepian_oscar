function varargout=polecircle2(xyzE,xyzR,thr,th,method)
% varargout=POLECIRCLE2(xyzE,xyzR,thr,th,method)
%
% Finds (and plots) the Cartesian coordinates of great circle slicing a
% three-dimensional sphere of a certain radius centered at a certain
% point. This circle lies in a plane that contains the axis connecting
% the two points (hence, their distance could be a suitable choice for
% the radius of the plotted circle), rotated by an angle measured
% counterclockwise from six o'clock when viewing a pole circle down
% the joining angle.
%
% INPUT:
%
% xyzE        Coordinates of a special point in three dimensions
% xyzR        Coordinates of the sphere that is the target of our viewing
% thr         Rotation angle of the circle about the axis joing both points
% th          Angles defining the segment that shall be drawn [degrees]
%             in the original xy plane counterclockwise from +x, i.e.
%             counterclockwise counting from six o'clock on the circle
% method      0 do not make a plot
% 
% EXAMPLE:
%
% polecircle2('demo1',32)
% polecircle2('demo2')
%
% Last modified by fjsimons-at-alum.mit.edu, 07/21/2017

com.mathworks.services.Prefs.setBooleanPref('EditorGraphicalDebugging',false)

% Default inputs for all variables
defval('xyzE',[0.2017 -0.735 0.647])
defval('thr',0)
defval('th',linspace(0,360,100))
defval('method',-1)


if ~isstr(xyzE)
   defval('xyzR',[5*randn(3,1) ; randi(5)])
   
   % Define the joining axis between the two points
   [lonr,latr]=cart2sph(xyzE(1)-xyzR(1),xyzE(2)-xyzR(2),xyzE(3)-xyzR(3));
   lonlatr=[lonr latr]*180/pi;

   % Define the requested pole point in this framework
   [xv,yv,zv]=polecircle(lonlatr,xyzR,thr,-1);
   % Of course, don't forget it is with respect to the sphere center!
   [lonv,latv]=cart2sph(xv-xyzR(1),yv-xyzR(2),zv-xyzR(3));
   lonlatv=[lonv latv]*180/pi;
   
   % And then do what we actually set out to do!
   [x,y,z]=polecircle(lonlatv,xyzR,th,-1); hold on; 

   if method~=0
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
      hold off
      view(3)
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
   [xp,yp,zp]=sph2cart(lonlatp(1)*pi/180,lonlatp(2)*pi/180,1);

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
   [xv,yv,zv]=polecircle(lonlatv,xyzR,[],-1); hold on
   plot3(xv,yv,zv,'m:')

   % Maybe plot lonlatv right where you think it should go!
   plot3(xyzR(1)+[0 xyzV(1)],xyzR(2)+[0 xyzV(2)],xyzR(3)+[0 xyzV(3)],'k')
   % Maybe also a little version centered on the origin?
   % plot3([0 xyzV(1)],[0 xyzV(2)],[0 xyzV(3)],'k')

   % And now I can turn THAT point to somewhere else on the unit
   % sphere as long as I stay on the great circle perpendicular to the
   % joining axis of the point to the sphere center. Take a look:
   [xr,yr,zr]=polecircle(lonlatr,xyzR,[],-1); hold on
   plot3(xr,yr,zr,'k--')
   % Plot the point that we are actually picking, measure
   % anticlockwise from six o'clock when looking down the joining line
   [xt,yt,zt]=polecircle(lonlatr,xyzR,thr,-1); hold on
   plot3(xt,yt,zt,'ko')

   % Now you invoke POLECIRCLE2 to tilt the satellite radius the right way
   xyzE=[xp ; yp ; zp];
   [x,y,z,xv,yv,zv]=polecircle2(xyzE,xyzR,thr,[]); hold on
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
end


