function varargout=stalta(sig,DT,BE,STA,LTA,TR,DTR,PEM,PET,PNL,ATL)
% [trigt,stav,ltav,ratio,tim1,tim2,tim3,trigs,dtrigs]=...
%   STALTA(sig,DT,BE,STA,LTA,TR,DTR,PEM,PET,PNL,ATL)
% 
% Triggering algorithm based on the ratio of the Short-Term
% Average absolute value to the Long-Term Average absolute value
% of a detrended signal. Everything is in standard units.
%
% INPUT:
%
% sig      Vector containing the signal
% DT       Sampling interval (s)
% BE       Beginning and end time of signal ([s s])
% STA      Short-term averaging window length (s)
% LTA      Long-term averaging window length (s)
% TR       Value of STA/LTA ratio that triggers
% DTR      Value of STA/LTA ratio that untriggers
% PEM      Time buffer added before triggering time (s)
% PET      Time-buffer added after detriggering time (s)
% PNL      Minimum window length of any triggered section (s)
% ATL      Time between trigger and detrigger that must be
%          exceeded in order for the triggered section to be reported (s)
%
% OUTPUT:
%
% trigt   Matrix with begin and end times of triggered sections (s)
% stav    Short-term average of absolute values of detrended signal
% ltav    Long-term average of absolute values of detrended signal
% ratio   Ratio of short-term to long-term average
% tim1    Time axis for 'ratio'
% tim2    Time axis for 'stav'
% tim3    Time axis for 'ltav'
% trigs   Vector with triggering points, in samples
% dtrigs  Vector with detriggering points, in samples
%
% EXAMPLE:
%
% stalta('demo')
% stalta('demo',3)
%
% Last modified by fjsimons-at-alum.mit.edu, 04/03/2021

if ~isstr(sig)

  % Default values
  defval('DT',1)

  %defval('BE',[0 1]) % But this is no good, really

  defval('STA',10)
  defval('LTA',100)
  defval('TR',2)
  defval('DTR',1)
  defval('PEM',100)
  defval('PET',100)
  defval('PNL',500)
  defval('ATL',20)
  
  % Figure out how many samples the windows encompass
  STAsmp=ceil(STA/DT);
  LTAsmp=ceil(LTA/DT);
  PEMsmp=ceil(PEM/DT);
  PETsmp=ceil(PET/DT);
  NPTS=length(sig);

  % Detrend the signal so DC value and trend don't play
  sig=ldetrend(sig);
  disp('Detrending... may not be appropriate for everyone')
  % Calculate long-term and short-term average and their ratio
  stav=moving(abs(sig),STAsmp);
  ltav=moving(abs(sig),LTAsmp);

  % If it's not possible, don't return anything
  if length(stav)==1 | length(ltav)==1
    [trigt,stav,ltav,ratio,tim1,tim2,tim3,trigs,dtrigs]=deal(NaN);
  else
    ratio=[repmat(stav(1),STAsmp-1,1) ; stav]...
	  ./[repmat(ltav(1),LTAsmp-1,1); ltav];
    % Simple solution to make last triggered point
    % automatically detriggered at the end of the section
    ratio(end)=0;

    % Calculate timing axes for all three variables
    tim1=linspace(BE(1),BE(2),NPTS);
    tim2=linspace(BE(1)+STA-DT,BE(2),NPTS-STAsmp+1);
    tim3=linspace(BE(1)+LTA-DT,BE(2),NPTS-LTAsmp+1);

    % Trigger when ratio exceeds TR
    trigi=find(ratio>TR);
    if ~isempty(trigi) 
      cnt=1;
      trigs(cnt,1)=trigi(1);
      % Detrigger when ratio drops below DTR after the trigger
      dtrgi=find(ratio(trigi(1):end)<DTR)+trigi(1)-1;
      dtrigs(cnt,1)=dtrgi(1);
      
      % First trigger times
      trigt=[tim1(trigi(1))-PEM tim1(dtrgi(1))+PET];
      % After that (not in real time) need to work on the remainder
      trigi=find(ratio(dtrgi(1)+PETsmp:end)>TR)+dtrgi(1)+PETsmp-1;
      while ~isempty(trigi)
	cnt=cnt+1;
	trigs(cnt,1)=trigi(1);
	dtrgi=find(ratio(trigi(1):end)<DTR)+trigi(1)-1;
	dtrigs(cnt,1)=dtrgi(1);
	if ~isempty(dtrgi)
	  trigt(cnt,:)=[tim1(trigi(1))-PEM tim1(dtrgi(1))+PET];
	  trigi=find(ratio(dtrgi(1)+PETsmp:end)>TR)+dtrgi(1)+PETsmp-1;      
	else % Terminate loop
	  trigi=[];
	end
      end
    else
      trigt=[];
      trigs=[];
      dtrigs=[];
    end
    
    % Verify that the time between the real trigger and the end is 
    % at least PNL seconds long; if not, update
    for index=1:length(trigs)
      if (trigt(index,2)-[BE(1)+trigs(index)*DT])<PNL
	trigt(index,2)=[BE(1)+trigs(index)*DT+PNL];
      end
    end

    % Make sure none of the values exceed the data length or beginning
    trigt(trigt>BE(2))=BE(2);
    % But don't let it start at exactly zero, ever
    trigt(trigt<BE(1))=BE(1)+DT;

    % Make sure the actual trigger length is at least ATL
    kept=ceil([dtrigs-trigs]*DT)>=ATL;
    trigt=trigt(kept,:);
    trigs=trigs(kept,:);
    dtrigs=dtrigs(kept,:);
  end
  
  % Provide output
  vars={trigt,stav,ltav,ratio,tim1,tim2,tim3,trigs,dtrigs};
  varargout=vars(1:nargout);
else
  % Demo
  defval('DT',[])
  % Maybe you want to supply the specific number in the array fname
  tipe=DT;
  % Or else just take the default, the first one
  defval('tipe',1)

  % The directory where the sac data are kept 
  ddir= '/u/fjsimons/MERMAID/SIGNALS/';
  % I now keep them in $IFILES/MATLABDEMOS/staltademo.zip

  % The names of the seismograms
  fname= {'CE_19990951108.sac'...
	  'evt037SE.mar4.sac' ...
	  '16n049w_2.sac' ...
	  '32n035w_1.sac' ...
	  '16n043w_1.sac' ...
	  '16n043w_2.sac'};

  % Same parameters as in STALTAS
  STA=10;
  LTA=100;
  TR=2;
  DTR=1;

  PEM=100;
  PET=100;
  PNL=500;
  ATL=20;

  clf
  ah=krijetem(subnum(4,1));
 
  % Plot original signal (22 Hz)------------------------------
  axes(ah(1))
  [sig,hdr,t,p1]=readsac(fullfile(ddir,fname{tipe}),1,'l'); axis tight
  delete(get(ah(1),'XLabel'))
  yl(1)=ylabel('Signal');

  % Plot low-passed signal (2 Hz)-----------------------------
  axes(ah(2))
  sig=lowpass(sig,1/hdr.DELTA,2,2,2,'butter');
  p2=plot(linspace(hdr.B,hdr.E,hdr.NPTS),sig); axis tight
  [trigt,stav,ltav,ratio,tim1,tim2,tim3,trigs,dtrigs]=...
      stalta(sig,hdr.DELTA,[hdr.B hdr.E]); 
  yl(2)=ylabel('Signal, Filtered 2 Hz');
  for tndex=1:size(trigt,1)
    hold on
    a(tndex)=fillbox([trigt(tndex,:) fliplr(ylim)],grey(7));
    top(p2,ah(2))
    hold off
  end    
  if ~isempty(trigs)
    hold on
    plot(hdr.B+trigs*hdr.DELTA,0,'o','MarkerE','k','MarkerF','w')
    hold off
  end

  % Plot short-term and long-term averages--------------------
  axes(ah(3))
  psta=plot(tim2,stav); xlim([hdr.B hdr.E])
  yl(3)=ylabel(sprintf('STA %i, LTA %i (s)',STA,LTA));
  hold on
  plta=plot(tim3,ltav);
  axis tight
  xlim([hdr.B hdr.E]) 
  grid on

  set(psta,'Color','r')
  set(plta,'Color','b')
  set([p1(1) p2],'Color','k')

  % Plot ratios of short-term to long-term--------------------
  axes(ah(4))
  esp=0.1;
  dtrbx=fillbox([hdr.B hdr.E 5 1]+[-esp esp esp 0],grey(9)); hold on
  trbox=fillbox([hdr.B hdr.E 5 2]+[-esp esp esp 0],grey(7));
  set([dtrbx trbox],'EdgeC',[1 1 1])
  prat=plot(tim1,ratio);
  yl(4)=ylabel(sprintf('RATIO'));
  hold on
  if ~isempty(trigs)
    plot(hdr.B+trigs*hdr.DELTA,2,'o','MarkerE','k','MarkerF','w')
  end
  if ~isempty(dtrigs)
    plot(hdr.B+dtrigs*hdr.DELTA,1,'o','MarkerE','k','MarkerF','w')
  end
  ylim([0 5])
  grid on
  xlim([hdr.B hdr.E])
  hold off
  xl(1)=xlabel('Time (s)');
  nolabels(ah(1:3),1)

  fig2print(gcf,'landscape')
  figdisp(sprintf('stalta_ill_%3.3i',tipe))
end
