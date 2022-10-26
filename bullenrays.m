function bullenrays(polmol)
% BULLENRAYS(polmol)
%
% Makes a simple ray diagram in the BULLEN model
%
% INPUT
% 
% polmol      'bullen' [default] or 'linmod'
%
% EXAMPLE:
%
% figure(1); clf; bullenrays('bullen')
% figure(2); clf; bullenrays('linmod')
% figure(3); clf; munkrays
%
% SEE ALSO:
%
% GROUPRAYS, MUNKRAYS
%
% Last modified by fjsimons-at-alum.mit.edu, 06/09/2021

% Convert everything to km... 
mtokm=1000;

defval('polmol','bullen')

% Plot the velocity model on the side
clf 
ah(1)=subplot(2,4,1);
if strcmp(polmol,'bullen')
  plot([bullen([0     0],1) bullen([0 12000],1)]/mtokm,[    0 12000]/mtokm,'k'); hold on
  plot([bullen([0 12000],1) bullen([0 18000],1)]/mtokm,[12000 18000]/mtokm,'k')
  plot([bullen([0 18000],1) bullen([0 30000],1)]/mtokm,[18000 30000]/mtokm,'k')
elseif  strcmp(polmol,'linmod')
  plot([linmod([0    0],1) linmod([0 30000],1)]/mtokm,[    0 30000]/mtokm,'k'); hold on
end
axis ij; hold off

% Then plot the ray diagram to the right
ah(2)=subplot(2,4,2); set(ah(2),'Position',[getpos(ah(2),[1 2]) 4*getpos(ah(2),3) getpos(ah(2),4)])

% Source location in Cartesian coordinates
qxy=[0 14500];

% A FIRST SET-----------------------------------------------------------
alfa=[50:5:65]*pi/180;
maxt1=doit(qxy,alfa,mtokm,polmol);

% Here also try to use RAYTRACE out of the box

% A SECOND SET-----------------------------------------------------------
alfa=[70:2:120]*pi/180;
maxt2=doit(qxy,alfa,mtokm,polmol);

% Here also try to use RAYTRACE out of the box

% A THIRD SET-----------------------------------------------------------
alfa=[125:5:175]*pi/180;
maxt3=doit(qxy,alfa,mtokm,polmol);

% Here also try to use RAYTRACE out of the box

% Annotation and labeling and cosmetic adjustments
axes(ah(1))
grid on
longticks(ah(1))
ylabel('depth (km)')
xlabel('speed (km/s)')
set(ah(1),'XTick',[5:0.5:7]*1e3/mtokm)

axes(ah(2))
axis ij 
grid on
ylim([0 30e3]/mtokm)
xlims=[0 180e3]/mtokm'; xlim(xlims)
set(ah(2),'XTick',[xlims(1):30:xlims(2)]*1e3/mtokm)
longticks(ah(2),2)
set(ah(2),'YAxisLocation','right')
xlabel('distance (km)')
tl=title(sprintf('max(t)=%4.1f s',max([maxt1 maxt2 maxt3])));
movev(tl,-3)
set(tl,'FontWeight','normal')

% Common
set(ah,'YTick',[0 12e3 18e3 30e3]/mtokm)
movev(ah,-0.250)
moveh(ah,-0.035)

% Plot suggestion and execution
set(gcf,'Units','Inches','PaperPositionMode','Auto','PaperUnits','Inches',...
	'PaperSize',indeks(get(gcf,'Position'),[3 4]));
%set(gcf,'renderer','paint')
figdisp([],[],[],0)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxt=doit(qxy,alfa,mtokm,polmol)
maxt=[];
for index=1:length(alfa)
  [t,rxy,pxy]=raypath(qxy,alfa(index),polmol);
  plot(rxy(:,1)/mtokm,rxy(:,2)/mtokm); hold on
  maxt=max([maxt ; t]);
end
