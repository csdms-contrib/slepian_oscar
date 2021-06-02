function earthmodel(ddir)
% EARTHMODEL(ddir)
%
% Simply plots Earth models iasp91, ak135 and isotropic prem from a set
% pretreated to remove discontinuities by averaging.
%
% INPUT:
%
% ddir    Data directory [defaulted]
%
% TESTED ON:
%
% 8.3.0.532 (R2014a)
% 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 06/2/2021

% Specify where you keep them
defval('ddir',fullfile(getenv('IFILES'),'EARTHMODELS','MATFILES'))

% Load data
ak135=load(fullfile(ddir,'ak135'));
iasp91=load(fullfile(ddir,'iasp91'));
premiso=load(fullfile(ddir,'premiso'));

% Unit conversion
mtokm=1000;

% Start the graphics!
[ah,ha]=krijetem(subnum(2,3));

% Plot P-wave speed
axes(ah(1))
p(1)=plot(ak135.psd(:,1)/mtokm,(ak135.radius(end)-ak135.radius)/mtokm,'k-'); hold on
p(2)=plot(iasp91.psd(:,1)/mtokm,(iasp91.radius(end)-iasp91.radius)/mtokm,'k-');
p(3)=plot(premiso.psd(:,1)/mtokm,(premiso.radius(end)-premiso.radius)/mtokm,'k-');
xl(1)=xlabel('P-speed (km/s)');
yl(1)=ylabel('depth (km)');

% Plot S-wave speed
axes(ah(2))
s(1)=plot(ak135.psd(:,2)/mtokm,(ak135.radius(end)-ak135.radius)/mtokm,'k-'); hold on
s(2)=plot(iasp91.psd(:,2)/mtokm,(iasp91.radius(end)-iasp91.radius)/mtokm,'k-');
s(3)=plot(premiso.psd(:,2)/mtokm,(premiso.radius(end)-premiso.radius)/mtokm,'k-');
xl(2)=xlabel('S-speed (km/s)');

% Plot density
axes(ah(3))
d(1)=plot(ak135.psd(:,3)/mtokm,(ak135.radius(end)-ak135.radius)/mtokm,'k-'); hold on
d(2)=plot(iasp91.psd(:,3)/mtokm,(iasp91.radius(end)-iasp91.radius)/mtokm,'k-');
d(3)=plot(premiso.psd(:,3)/mtokm,(premiso.radius(end)-premiso.radius)/mtokm,'k-');
xl(3)=xlabel('density (g/cm^3)');

% Cosmetics
set(ah,'ylim',[-10 700],'Ydir','Rev','FontSize',15,...
       'Xgrid','on','Ygrid','on')
longticks(ah)
set([xl yl],'FontSize',15)
nolabels(ah(2:3),2)
set([p s d],'LineW',1)
set([p(1) s(1) d(1)],'Color','y','LineW',2)
set([p(2) s(2) d(2)],'Color','r')
set([p(3) s(3) d(3)],'Color','b')
set(ah(1),'xlim',[2 12])
set(ah(2),'xlim',[-0.5 7]) 
set(ah(3),'xlim',[2 5])  
shrink(ah,0.9,1)
axes(ah(1))
if verLessThan('matlab', '8.4')
  l=legend('ak135','prem-iso','iasp91',3);
else
  l=legend('ak135','prem-iso','iasp91','Location','SouthWest');
end
set(ah,'ytick',[0 220 410 670 2895 5150])

% Now the rest
axes(ah(4))
p(1)=plot(ak135.psd(:,1)/mtokm,(ak135.radius(end)-ak135.radius)/mtokm,'k-'); hold on
p(2)=plot(iasp91.psd(:,1)/mtokm,(iasp91.radius(end)-iasp91.radius)/mtokm,'k-');
p(3)=plot(premiso.psd(:,1)/mtokm,(premiso.radius(end)-premiso.radius)/mtokm,'k-');
xl(1)=xlabel('P-speed (km/s)');
yl(1)=ylabel('depth (km)');

% Plot S-wave speed
axes(ah(5))
s(1)=plot(ak135.psd(:,2)/mtokm,(ak135.radius(end)-ak135.radius)/mtokm,'k-'); hold on
s(2)=plot(iasp91.psd(:,2)/mtokm,(iasp91.radius(end)-iasp91.radius)/mtokm,'k-');
s(3)=plot(premiso.psd(:,2)/mtokm,(premiso.radius(end)-premiso.radius)/mtokm,'k-');
xl(2)=xlabel('S-speed (km/s)');

% Plot density
axes(ah(6))
d(1)=plot(ak135.psd(:,3)/mtokm,(ak135.radius(end)-ak135.radius)/mtokm,'k-'); hold on
d(2)=plot(iasp91.psd(:,3)/mtokm,(iasp91.radius(end)-iasp91.radius)/mtokm,'k-');
d(3)=plot(premiso.psd(:,3)/mtokm,(premiso.radius(end)-premiso.radius)/mtokm,'k-');
xl(3)=xlabel('density (g/cm^3)');

set(ah(4:6),'ytick',[0 220 410 670 2895 5150],'ylim',[700 6371],...
	    'Xgrid','on','Ygrid','on','Ydir','rev')
set(ah(4),'xlim',[2 14])
set(ah(5),'xlim',[-0.5 8]) 
set(ah(6),'xlim',[2 14])  

set([p s d],'LineW',1)
set([p(1) s(1) d(1)],'Color','y','LineW',2)
set([p(2) s(2) d(2)],'Color','r')
set([p(3) s(3) d(3)],'Color','b')

serre(ha(1:2),1/3,'down')
serre(ha(3:4),1/3,'down')
serre(ha(5:6),1/3,'down')

nolabels(ah(5:6),2)

set(ah,'Color',grey(9))
set(gcf,'Color','w','Invert','off')

fig2print(gcf,'landscape')
figdisp

