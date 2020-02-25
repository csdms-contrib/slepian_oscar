function sac2psd(diro,num)
% SAC2PSD(diro,num)
%
% Calculate a power spectral density estimate for SAC seismograms
%
% INPUT
%
% diro     A string with a data directory
% num      1 using 'HHX'
%          2 using 'HHY'
%          3 using 'HHZ'
%
% Tested on 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 06/22/2017

% Where do you put the plots?
dirp='/data1/seismometer/PDF';

% Where are the data kept?
defval('diro','/data1/seismometer/2017/02/25');

% What component is the default?
defval('num',1)

% Switch components
switch num
 case 1
  cmp='HHX';
 case 2
  cmp='HHY';
 case 3
  cmp='HHZ';
end

% What SAC seismograms are in there?
ss=ls2cell(fullfile(diro,sprintf('*%s*SAC',cmp)));

% We want this length, for uniformity
nfft=360000;

% Initialize to find power maxima and minima
minS=Inf; minF=-Inf;
maxS=-Inf; maxF=Inf;

% Just do them all first
for index=1:length(ss)
  % Calculate a power-spectral density estimate
  [S,fax]=psdest(diro,ss{index},nfft);
  % Collect WIDEST range of the y axis
  minS=min(minS,min(S));
  maxS=max(maxS,max(S));
  % Collect NARROWEST range of the x axis, disregard 0
  minF=max(minF,fax(2));
  maxF=min(maxF,fax(end));
end

% Maybe you still want to override these choices here (nonzero!)
minF=1e-3;
maxF=30.1;
minS=maxS/1e12;
%maxS=1e15;

% Close all figures for a really fresh start
% close all
fh=figure(1);

% Then we'll plot things
% Just do them all first
for index=1:length(ss)
  % (Re-)calculate a power-spectral density estimate
  [S,fax]=psdest(diro,ss{index},nfft);

  % Prepare the figure
  clf; ah=gca; shrink(ah,1,1.75)
  % Actually plot what we've calculated
  loglog(fax,S,'linew',0.5);
  % Annotate and label
  grid off
  xlabel('frequency (1/s)');
  ylabel(sprintf('variance(%s)%s s',cmp,'\times'))

  % Fix the axis to something common to ALL records
  xlim([minF maxF])
  ylim([minS maxS])

  % Be VERY specific about what you want to label
  xlr=log10(xlim); xlr=[ceil(xlr(1)) floor(xlr(2))];
  ylr=log10(ylim); ylr=[ceil(ylr(1)) floor(ylr(2))];
  ah.XTick=10.^[xlr(1):xlr(2)];
  ah.YTick=10.^[ylr(1):3:ylr(2)];
  
  % Put the name of the seismogram as the title
  tn=ss{index};
  t=title(sprintf('%s',tn));
  % Move title
  t.Position=t.Position.*[1 10^round(log10([maxS-minS])/3.5) 1];

  % More further cosmetic adjustments
  longticks(ah,2)
  
  % Put on major tie line^s
  ah.XGrid='on'; ah.XMinorGrid='off';
  ah.YGrid='on'; ah.YMinorGrid='off';
  % Create a top axis at these labeled points
  xlabs=get(gca,'xtick');
  xlims=get(gca,'xlim');
  [ax,xl5,yl5]=xtraxis(gca,1./xlabs,1./xlabs,'period (s)');
  % Make sure the tick marks are reversed and axis ranges preserved
  set(ax,'xdir','rev','xlim',sort(1./xlims))
  longticks(ax,2)

  % Fiddle wit the name to create the PDF
  tn(find(abs(tn==46)))='-';
  % Annotate and print the plot
  print('-dpdf',fullfile(dirp,sprintf('%s',tn)))

  % Wait a moment
  pause(0.2)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [S,fax]=psdest(diro,ss,nfft)
% Read the seismogram
[s,h]=readsac(fullfile(diro,ss),0);
% Make a frequency axis
% Length in samples
if nfft==length(s);
  % Half of it is relevant because signals are real
  selekt=1:floor(nfft/2)+1;
  % Construct a proper frequency axis
  fax=(selekt-1)'/[h.E-h.B]*(length(s)-1)/nfft;
  % Compute a Hanning-modified periodogram as a spectral estimate
  S=abs(fft(hanning(length(s)).*[s-mean(s)],nfft)).^2;
  % Return the good half
  S=S(selekt);
else
  S=NaN;
end

