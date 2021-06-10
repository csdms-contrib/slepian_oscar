function varargout=cylindric(r,toplola,botlola,R,xver)
% [xyZ,topS,botS]=CYLINDRIC(r,toplola,botlola,R,xver)
%
% Finds the interection of a cylinder of radius r with a sphere of radius R
%
% INPUT:
%
% r         Radius of the cylinder
% toplola   Geographic coordinates of its top
% botlola   Geographic coordinates of its bottom
% R         Radius of the sphere         
% xver      1 Extra verification by plotting
%           0 No extra verification or plotting
%
% OUTPUT:
%
% xyzS      A cell array with the intersection points
% topS      A matrix with a "top" patch, whether the domain is closed or not
% botS      A matrix with a "bottom" patch, closed or not
% 
% EXAMPLES:
%
%% A random worked example and a plot
% cylindric([],[],[],[],1)
%
%% Another example
% figure(1); [~,b,c]=cylindric([],[],[],[],1); 
% figure(2); plot3(b(1,:),b(2,:),b(3,:),'g'); hold on
%            plot3(c(1,:),c(2,:),c(3,:),'r'); hold off
%
%% A specific example and a plot example
% xyzS=cylindric(0.1,[],[],1);
% for index=1:length(xyzS)
%   for ondex=1:size(xyzS{index},2)
%       plot3(xyzS{index}(1,ondex),xyzS{index}(2,ondex),xyzS{index}(3,ondex),'k.')
%       hold on 
%     end
% end
% hold off; grid on ; axis([-1 1 -1 1 -1 1])
%
% SEE ALSO:
%
% POLECIRCLE, LINE3SPHERE, VIVIANI
%
% Last modified by fjsimons-at-alum.mit.edu, 05/06/2021

% Defaults
defval('toplola',rand(1,2).*[360 180]+[0 -90])
defval('botlola',rand(1,2).*[360 180]+[0 -90])
defval('r',0.1)
defval('R',1)
defval('xver',0)

% Convert axis of cylinder to coordinates on the target sphere
[xt,yt,zt]=sph2cart(toplola(1)*pi/180,toplola(2)*pi/180,R);
[xb,yb,zb]=sph2cart(botlola(1)*pi/180,botlola(2)*pi/180,R);
% Find center of cylinder
xc=xb+[xt-xb]/2;
yc=yb+[yt-yb]/2;
zc=zb+[zt-zb]/2;
% These change along the axis of the cylinder unless it goes through the center
[thc,phc]=cart2sph(xc,yc,zc);
% Calculate the circumference of the cylinder at the top
[th,ph]=cart2sph(xt-xc,yt-yc,zt-zc);
% Remember the empty argument sets the resolution
[xtc,ytc,ztc]=polecircle([th ph]*180/pi,[xt-xc yt-yc zt-zc r],[],-1);
xtc=xtc+xc; ytc=ytc+yc; ztc=ztc+zc;
% Calculate the circumference of the cylinder at the bottom
[th,ph]=cart2sph(xb-xc,yb-yc,zb-zc);
% Remember the empty argument sets the resolution
[xbc,ybc,zbc]=polecircle([th ph]*180/pi,[xb-xc yb-yc zb-zc r],[],-1);
% Need to flip since angles where measured in different direction
xbc=flipud(xbc+xc); ybc=flipud(ybc+yc); zbc=flipud(zbc+zc);

% Now I need to figure out where these "walls" intersect the sphere
% https://en.wikipedia.org/wiki/Line%E2%80%93sphere_intersection
for index=1:length(xbc)
  % Now find the intersections of the wall lines with the sphere
  xyzS{index}=line3sphere([xtc(index) ytc(index) ztc(index)],...
			  [xbc(index) ybc(index) zbc(index)],[0 0 0 R],...
			  0);
  % Count the number of returned points
  nS(index)=size(xyzS{index},2);
end

% Begin by finding any single returns and duplicating them so that you
% can assign them to both top and bottom
if any(nS==1)
  % You need to make "cat" work below, and then make two columns out of
  % it, by duplication the single points, of which I think there are at
  % most two. Leave for later
  keyboard
end
% Need a picture, but you always have the notion of a top and a bottom
topS=reshape(kindeks(cat(1,xyzS{:}),1),3,[]);
botS=reshape(kindeks(cat(1,xyzS{:}),2),3,[]);
% Still all could be empty and you'd have to deal with it

% Optional plotting
if xver==1 && R==1
  % Make a plot, viewed centered on the center
  [~,pe]=plotcont([],[],11,[],[],[thc*180/pi phc*180/pi]);
  hold on
  % Plot axis
  pa=plot3([xt xb],[yt yb],[zt zb],'b');
  % Plot center of axis
  pc=plot3(xc,yc,zc,'b+');
  % Plot top and bottom circles
  pt=plot3(xtc,ytc,ztc,'r');
  pb=plot3(xbc,ybc,zbc,'g');
  % Plot some connecting lines... just a subset
  for index=1:10:max(10,length(xbc))
    pl(index)=plot3([xtc(index) xbc(index)],[ytc(index) ybc(index)],...
		    [ztc(index) zbc(index)],'k');
  end
  % And all intersection points
  for index=1:max(10,length(xbc))
    for ondex=1:size(xyzS{index},2)
      plot3(xyzS{index}(1,ondex),xyzS{index}(2,ondex),xyzS{index}(3,ondex),'k.')
    end
  end
  hold off

  % Cosmetics
  xlabel('x')
  ylabel('y')
  zlabel('z')
  set([pa pb pt],'LineW',2)

  set(gca,'CameraViewAngle',9)
  
  % Last minute cleanup
  delete([pt pb pl])
  
  % Save the plot
  figdisp([],sprintf('%i_%i_%i_%i_%4.2f',round(toplola),round(botlola),r),[],0)
end

% Optional output
varns={xyzS,topS,botS};
varargout=varns(1:nargout);

