function varargout=line3sphere(xyz1,xyz2,xyzR,xver)
% [xyzS,d]=LINE3SPHERE(xyz1,xyz2,xyzR,xver)
%
% Calculates the intersection of a line with a sphere
%
% INPUT:
%
% xyz1       Coordinates of a first point defining an infinite line
% xyz2       Coordinates of a second point defining an infinite line
% xyzR       Coordinates of center and radius of sphere
% xver       1 Extra verification by plotting 
%            0 No extra verification or plotting 
%
% OUTPUT:
%
% xyzS       Coordinates of line-sphere intersection point(s)
% d          Distance(s) from the line origin to the intersection points(s)
%
% EXAMPLE:
%
% line3sphere([],[],[],1)
%
% Last modified by fjsimons-at-alum.mit.edu, 05/05/2021

% https://en.wikipedia.org/wiki/Line%E2%80%93sphere_intersection#Calculation_using_vectors_in_3D

% Defaults
defval('xyz1',randn(1,3));
defval('xyz2',randn(1,3));
defval('xyzR',[randn(1,3) 10*rand(1)]);
defval('xver',0);

% Make all of them column vectors
xyz1=xyz1(:);
xyz2=xyz2(:);
xyzR=xyzR(:);

% Unit vector of line
uhat=[xyz2-xyz1]/norm(xyz2-xyz1);
% Offset between origin of line and center of sphere
ominc=xyz1-xyzR(1:3);
% Auxiliary variables from the quadratic formula
udomc=uhat'*ominc;
sdelt=sqrt(udomc^2-(norm(ominc)^2-xyzR(4)^2));

if isreal(sdelt)
  % Distance to the intersection point from the origin of the line
  d=unique(-udomc+[1 -1]*sdelt);
  % The actual intersection ponits
  xyzS=repmat(xyz1,1,length(d))+uhat*d;
else
  d=[];
  xyzS=[];
end

if xver==1
  % Plotting
  p1=plot3(xyz1(1),xyz1(2),xyz1(3),'^'); hold on
  p2=plot3(xyz2(1),xyz2(2),xyz2(3),'v');
  pc=plot3(xyzR(1),xyzR(2),xyzR(3),'o');
  pl=plot3([xyz1(1) xyz2(1)],[xyz1(2) xyz2(2)],[xyz1(3) xyz2(3)]); 
  for index=1:size(xyzS,2)
    % Plot the intersections, possible extensions of the line segment
    p(index)=plot3(xyzS(1,index),xyzS(2,index),xyzS(3,index),'+');
    % Plot the vectors joining the origin of the sphere to those two points
    pv(index)=plot3([xyzR(1) xyzS(1,index)],[xyzR(2) xyzS(2,index)],[xyzR(3) xyzS(3,index)]);
    % Report on the distances which should be R
    otoS=[xyzR(1)-xyzS(1,index) xyzR(2)-xyzS(2,index) xyzR(3)-xyzS(3,index)];
    % Mute check
    diferm(norm(otoS)-xyzR(4))
  end
  hold off

  % If could do POLECIRCLE or POLECIRCLE2 to make some fancier plots and
  % determine a nicer viewing angle, but never mind
  grid on
  xlabel('x')
  ylabel('y')
  zlabel('z')
  axis equal
  axis([-7 7 -7 7 -7 7])
  title(sprintf('radius %4.2f | %i intersection(s)',xyzR(4),length(d)))
end
  
% Optional output
varns={xyzS,d};
varargout=varns(1:nargout);
