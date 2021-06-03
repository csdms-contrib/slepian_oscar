function grouprays
% GROUPRAYS
%
% Makes a diagram of multiply reflected waves as published by
% Simons et al., Lithos 1999, Figure 3b... 
%
% Last modified by fjsimons-at-alum.mit.edu, 06/02/2021

% Create sensible axes
clf 
axes('position',[0.2484 0.09 0.5382 0.22])

% Source location in polar coordinates
qrth=[6370999 pi/2-pi/19];

% S --------------------------------------------------
alfa=pi/5+pi/210;
% Calculate the first and only leg
[t,rxy,rrtha]=raypathpol(qrth,alfa,'linmodpol',[],qrth(1));
% Plot the first and only leg
plot(rxy(:,1),rxy(:,2)); hold on
% Calculate the epicentral distance
epidis=range(rrtha(:,2))*180/pi;
% Plot a pentagram at the END - to mask any small mismatches...
pk=plot(rxy(end,1),rxy(end,2),'kp','markerfacecolor',[0 0 0 ],'markersize',20);

%SS--------------------------------------------------
try
  alfa=tryit(qrth,linspace(0.9,1,100),2,epidis,qrth(1));
catch
  alfa=0.999; disp(sprintf('Using my own value alfa %4.3f',alfa))
end
% Calculate the first leg
[t,rxy,rrtha]=raypathpol(qrth,alfa,'linmodpol',[],qrth(1));
% Plot the first leg
plot(rxy(:,1),rxy(:,2)); 
% Calculate and plot the second leg
[rxy(:,1),rxy(:,2)]=pol2cart(rrtha(:,2)+range(rrtha(:,2)),rrtha(:,1));
plot(rxy(:,1),rxy(:,2)); 

% SSS--------------------------------------------------
try
  alfa=tryit(qrth,linspace(1.16,1.17,100),3,epidis,qrth(1));
catch
  alfa=1.165; disp(sprintf('Using my own value alfa %4.3f',alfa))
end
% Calculate the first leg
[t,rxy,rrtha]=raypathpol(qrth,alfa,'linmodpol',[],qrth(1));  
% Plot the first leg
plot(rxy(:,1),rxy(:,2));
% Calculate and plot the second leg
[rxy(:,1),rxy(:,2)]=pol2cart(rrtha(:,2)+range(rrtha(:,2)),rrtha(:,1));
plot(rxy(:,1),rxy(:,2)); 
% Calculate and plot the third leg
[rxy(:,1),rxy(:,2)]=pol2cart(rrtha(:,2)+2*range(rrtha(:,2)),rrtha(:,1));
plot(rxy(:,1),rxy(:,2)); 

% Cosmetics
set(findobj('color',[0 0 1]),'color',[0 0 0 ],'linewidth',2)
axis off
fs=20; ft='times'; fa='italic';
a=text(-0.4109e6,6.5304e6,'SSS');
b=text(0.1142e6,6.1262e6,'SS');
c=text(0.7915e6,5.9513e6,'S');
set([a b c],'FontSize',fs,'FontName',ft,'FontAngle',fa)
top(pk,gca)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is how you try things before committing
function alfa=tryit(qrth,alfas,mult,epidis,rmax)
% Try to find the takeoff angle that ends at the right epicentral distance

for index=1:length(alfas)
  [t,rxy,rrtha]=raypathpol(qrth,alfas(index),'linmodpol',[],rmax);
  % What epicentral distance did we reach
  epi=range(rrtha(:,2))*180/pi;
  % Are we close enough?
  if abs(mult*epi-epidis) < 0.2
    alfa=alfas(index);
    break
  end
end	
