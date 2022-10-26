function munkrays(sx,sz)
% MUNKRAYS(sx,sz)
%
% Makes a simple ray diagram in the Munk profile
%
% INPUT:
%
% sx    Source distance in positive meters
% sz    Source depth in positive meters
%
% SEE ALSO:
%
% GROUPRAYS, BULLENRAYS
%
% Last modified by fjsimons-at-alum.mit.edu, 06/09/2021

% Default values
defval('sx',1000)
defval('sz',3900)

% Convert everything to km... 
mtokm=1000;

% Plot the velocity model on the side
clf 
ah(1)=subplot(2,4,1);
[cz,z]=munk([],[],1); plot(cz,z);
axis ij; hold off; grid on

% Then plot the ray diagram to the right
ah(2)=subplot(2,4,2); set(ah(2),'Position',[getpos(ah(2),[1 2]) 4*getpos(ah(2),3) getpos(ah(2),4)])

% Source location in Cartesian coordinates
qxy=[sx sz];

% A FIRST SET-----------------------------------------------------------
alfa=[90:3:100]*pi/180; %alfa=alfa([1:3:end])
maxt1=doit(qxy,alfa,mtokm,max(z));

% Here also try to use RAYTRACE out of the box

% A SECOND SET-----------------------------------------------------------
%alfa=[70:5:120]*pi/180; %alfa=alfa([1:3:end])
%maxt2=doit(qxy,alfa,mtokm,max(z));
maxt2=0;

% Here also try to use RAYTRACE out of the box

% A THIRD SET-----------------------------------------------------------
%alfa=[125:5:275]*pi/180; %alfa=alfa([1:3:end])
%maxt3=doit(qxy,alfa,mtokm,max(z));
maxt3=0;

% Here also try to use RAYTRACE out of the box

% Annotation and labeling and cosmetic adjustments
axes(ah(1))
grid on
longticks(ah(1))
ylabel('depth (m)')
xlabel('speed (m/s)')
xlims=[1475 1575]; xlim(xlims)
set(ah(1),'XTick',[xlims(1):25:xlims(2)])

axes(ah(2))
axis ij 
grid on
ylim([0 max(z)])
xlims=[0 45e3]/mtokm; xlim(xlims)
set(ah(2),'XTick',[xlims(1):15:xlims(2)]*1e3/mtokm)
longticks(ah(2),2)
set(ah(2),'YAxisLocation','right')
xlabel('distance (km)')
tl=title(sprintf('max(t)=%4.1f s',max([maxt1 maxt2 maxt3])));
movev(tl,-3)
set(tl,'FontWeight','normal')

% Common
movev(ah,-0.250)
moveh(ah,-0.035)

% Plot suggestion and execution
set(gcf,'Units','Inches','PaperPositionMode','Auto','PaperUnits','Inches',...
	'PaperSize',indeks(get(gcf,'Position'),[3 4]));
%set(gcf,'renderer','paint')
%figdisp([],[],[],2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxt=doit(qxy,alfa,mtokm,ymax)
maxt=[];
for index=1:length(alfa)
  [t,rxy,pxy]=raypath(qxy,alfa(index),'munk',[0 30 100],0,ymax);
  plot(rxy(:,1)/mtokm,rxy(:,2)); hold on
  maxt=max([maxt ; t]);
end

