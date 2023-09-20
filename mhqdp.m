function mhqdp(dirname,fname,evpars,vitdat,vitlat,vitlon)
% MHQDP(dirname,fname,evpars,vitdat,vitlat,vitlon)
%
% Takes a sac file written by the Mermaid python routine, uses
% information from the vit file, and outside information about an
% earthquake to make a quick and dirty plot of a seismogram.
%
% INPUT:
%
% dirname    A directory string [default: where you keep the data]
% fname      A sac filename string [default: 'm1.sac']
% evpars     Event parameter vector with the following information:
%              1    2    3    4    5    6    7    8    9   10 
%            [evyr evmo evdy evhh evmn evsc EVMG EVLO EVLA EVDP]
% vitdat     A string from the *.vit file with the last known time:
%            e.g. 2018-04-13T00:14:35
% vitlat     A string from the *.vit file with the last known latitude:
%   	     e.g. N33deg35.126mn
% vitlon     A string from the *.vit file with the last known longitude:
%            e.g. E134deg57.367mn
%
% Last modified by fjsimons-at-alum.mit.edu, 09/20/2023

% Default values 
defval('dirname','/u/fjsimons/MERMAID/KobeShip2/')
defval('fname','m1.sac')
defval('evpars',[2018 04 12 13 37 39.83 5.2 141.87 38.37 56])
defval('vitdat','2018-04-13T00:14:35')
defval('vitlat','N33deg35.126mn')
defval('vitlon','E134deg57.367mn')

% Read in the data (and if second input is 1, plots the seismogram right away)
[s,h,~,~,tims]=readsac(fullfile(dirname,fname),1);

% Event parameters, time, magnitude, lola and depth
evyr=evpars(1);
evmo=evpars(2);
evdy=evpars(3);
evhh=evpars(4);
evmn=evpars(5);
evsc=evpars(6);
EVMG=evpars(7);
EVLO=evpars(8);
EVLA=evpars(9);
EVDP=evpars(10);

% Earthquake date-time class variable
eqdt=datetime(evyr,evmo,evdy,evhh,evmn,evsc);

% Seismogram date-time class variable
smmdy=doy2dat(h.NZYEAR,h.NZJDAY);
% It's in UTC, by the way
smdt=datetime(...
    h.NZYEAR,smmdy(1),smmdy(2),h.NZHOUR,h.NZMIN,h.NZSEC,h.NZMSEC,...
    'TimeZone','UTC');

% Station last-known location-time date-time class variable
% Station last-known location decimal latitude and longitude
[stdt,STLA,STLO]=vit2loc(vitdat,vitlat,vitlon);

% Calculated parameters by me
[~,delta]=grcdist([EVLO EVLA],[STLO STLA]);

% Use setvar.pl and getvar.pl to put into header, then inspect SAC's GCARC

% Expected travel time from TTIMES since the earthquake
tP=h.T0-seconds(smdt-eqdt);

% Now make the plot pretty
f1=2;
f2=4;
af=bandpass(s.*length(s),1/h.DELTA,f1,f2);

% Plot again, now the filteed version
clf
plot(tims,af);
xl=xlabel(sprintf('time [s] since %4.4i (%3.3i) %2.2i:%2.2i:%2.2i.%i',...
			h.NZYEAR,h.NZJDAY,h.NZHOUR,h.NZMIN,h.NZSEC,h.NZMSEC));
xlim([5 h.E])
ylims=halverange(af,15);
ylim(ylims)
hold on
plot([tP tP],ylims)

c=title(sprintf('mag %3.1f event at %i km depth and %4.2f%s distance, filtered %g-%g Hz',...
		     EVMG,EVDP,delta,str2mat(176),f1,f2));
set(c,'FontSize',14)
movev(c,range(ylims)/7.5)

longticks(gca,2)
grid on
shrink(gca,1,2)


% Print figure
print('-dpdf','kobequake','-bestfit')

