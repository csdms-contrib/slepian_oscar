function varargout=ost(fname,tw,xcor,subts,xver,fmt)
% [c,o,s,t]=ost(fname,tw,xcor,subts,xver,fmt)
%
% Observation-synthetic-triplet. Reads in a binary file containing a
% triplet of variables, one independent followed by two independent
% ones in the order "observation" then "synthetic". Computes
% multiplicative and differential distance measures of the demeaned
% time series, and makes a revealing plot if explicitly instructed.
%
% INPUT:
%
% fname     A file name string containing binaries t, o, and s
%           ... or a matrix with Mx3 entries, used as input 
% tw        Beginning and end of the time window of interest
%           inclusive, in the same unit as the array input t
% xcor      1 option 'coeff' for XCORR [default]
%           2 option 'unbiased' for XCORR [bad plot axes...]
%           3 option 'biased' for XCORR [bad plot axes...]
%           4 option 'none' for XCORR [bad plot axes...]
%           5 using XDIST with individual demeaning [preferred]
%           6 using XDIST without individual demeaning
% subts     Subset in t units for XCORR/RMSE comparison (default: [central half])
%           and also used for options 5 and 6 to not pick the edges
% xver      1 Makes a plot [default]
%           0 does not
% fmt       The binary format of the data file (default: 'float32')
%
% OUTPUT:
%
% c         A structure with the comparisons, the measures XCORR and RDIST
% o         One dependent variable (observation)
% s         Another dependent variable (synthetic)
% t         The independent variable (time)
%
% EXAMPLE:
%
% ost % with no input - if you have the data file (see DATA) 
%
% tt=linspace(0,10,101); o=cos(2*pi/3*tt); s=3*cos(2*pi/3*[tt-0.3]);
% c=ost([tt' o' s'],[2 8],1,[-1 1],1);
%
% comp={'Z','R','T'} ;
% ddir='/data1/fjsimons/POSTDOCS/MathurinWamba/Polynesia/DATA/C201505191525A_90_250_surface_wave';
% ozrt=reshape(loadb(fullfile(ddir,'C201505191525A.IU.AFI.obs.ZRT.bin')),[],3);
% szrt=reshape(loadb(fullfile(ddir,'C201505191525A.IU.AFI.syn.ZRT.bin')),[],3);
% compi=2; delt=0.2;  % Work with the dt known from the outside
% c1=ost([[0:size(ozrt,1)-1]'*delt ozrt(:,compi) szrt(:,compi)],[1346.2 1966.0],1);
% c5=ost([[0:size(ozrt,1)-1]'*delt ozrt(:,compi) szrt(:,compi)],[1346.2 1966.0],5);
%
% ddir='/data1/fjsimons/POSTDOCS/MathurinWamba/Polynesia/DATA/C091496G_17_40_body_wave';
% ozrt=reshape(loadb(fullfile(ddir,'C091496G.XU.DOTA.obs.ZRT.bin')),[],3);
% szrt=reshape(loadb(fullfile(ddir,'C091496G.XU.DOTA.syn.ZRT.bin')),[],3);
% compi=2; delt=0.2;
% c1=ost([[0:size(ozrt,1)-1]'*delt ozrt(:,compi) szrt(:,compi)],[667.0 763.2],1);
% c5=ost([[0:size(ozrt,1)-1]'*delt ozrt(:,compi) szrt(:,compi)],[667.0 763.2,5);
% 
% ddir='/data1/fjsimons/POSTDOCS/MathurinWamba/Polynesia/DATA/C201407041500A_40_100#surface_wave';
% ozrt=reshape(loadb(fullfile(ddir,'C201407041500A.G.TAOE.obs.ZRT.bin')),[],3);
% szrt=reshape(loadb(fullfile(ddir,'C201407041500A.G.TAOE.syn.ZRT.bin')),[],3);
% compi=1; delt=0.2;
% c1=ost([[0:size(ozrt,1)-1]'*delt ozrt(:,compi) szrt(:,compi)],[1769.0 2108.8],1);
% c5=ost([[0:size(ozrt,1)-1]'*delt ozrt(:,compi) szrt(:,compi)],[1769.0 2108.8],5);
% 
% ddir='/data1/fjsimons/POSTDOCS/MathurinWamba/Polynesia/DATA/C201303102251A_40_100#body_wave';
% ozrt=reshape(loadb(fullfile(ddir,'C201303102251A.G.PPTF.obs.ZRT.bin')),[],3);
% szrt=reshape(loadb(fullfile(ddir,'C201303102251A.G.PPTF.syn.ZRT.bin')),[],3);
% compi=3; delt=0.2;
% c1=ost([[0:size(ozrt,1)-1]'*delt ozrt(:,compi) szrt(:,compi)],[1229.6 1028.2],1);
% c5=ost([[0:size(ozrt,1)-1]'*delt ozrt(:,compi) szrt(:,compi)],[1229.6 1028.2],5);

        
%% Check the example in XCORR and apply RDIST for comparison!
% 
% SEE ALSO: XCORR, XDIST, RDIST, and adist
%
% Written for 9.7.0.1190202 (R2019b)
% Last modified by fjsimons-at-alum.mit.edu, 03/17/2023

%% INPUT %%
% Defaults
defval('fname','IU.AFI_Z.bin')
defval('tw',[2275 2854])
defval('xver',1)
defval('xcor',1)
defval('subts',[-1 1]*[max(tw)-min(tw)]/2)
% Prepare for options
xco={'coeff','unbiased','biased','none','xdist','xdist nm'};

if isstr(fname)
  defval('fmt','float32')
  % Load it, it was just a straight bitwrite
  ost=loadb(fname,fmt);
  % Split it
  tt=ost(                1:  length(ost)/3);
  o=ost(  length(ost)/3+1:2*length(ost)/3);
  s=ost(2*length(ost)/3+1:  length(ost));
else
  % Take what's given as a data matrix
  tt=fname(:,1);
   o=fname(:,2);
   s=fname(:,3);
end

% Sampling step of these two signals in seconds
delt=tt(2)-tt(1);
% Talk about what it really is
if length(unique(tt))~=1
    disp(sprintf('dt = %4.2f ; mean %4.2e ; median %4.2e ; std %4.2e',...
                 delt,mean(diff(tt)),median(diff(tt)),std(diff(tt))))
end

%% CALCULATION %%

% The indices corresponding to the time window
tmi=min(find(tt>=min(tw)));
tma=max(find(tt<=max(tw)));

% Identify the segments and demean 
wt=tt(tmi:tma); 
ws= s(tmi:tma)-mean(s(tmi:tma));
wo= o(tmi:tma)-mean(o(tmi:tma));

%% Multiplicative distance using XCORR %%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the appropriate correlation
kb
if xcor<5
    % Using the MATLAB function out of the box!
    [x,t]=xcorr(wo,ws,xco{xcor}); t=t(:);
elseif xcor==5
    % Overlapping portions individually further demeaned
    % Only look at the central lags since the edges are off
    [x,t]=xdist(wo,ws,matranges(round(subts/delt)),1); t=t(:);
elseif xcor==6
    % Overlapping portions not individually further demeaned
    % Only look at the central lags since the edges are off
    [x,t]=xdist(wo,ws,matranges(round(subts/delt)),0); t=t(:);
end
% Find the (arg)maximum, negative offset means ws is delayed wrt wo
[xm,j]=max(x);
    txm=t(j);
% Convert tau to units using the sampling steps
    txms=delt*txm;

% The zero-lag cross-correlation... is at length(ws)=length(wo) for
% XCORR but could be anywhere for XDIST options 5 and 6
x0=x(find(t==0));

%% Difference distance using RDIST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The observation-normalized rmse at optimal CROSS-CORRELATION lag,
% i.e. shifted into alignment and taking care of the non-overlapping edges!
rtxm=rdist(wo,ws,txm); 

% The zero-lag normalized rmse
r0=sqrt(sum([ws-wo].^2)/sum(wo.^2));

% The normalized rmse at a subset around the XCORR/XDIST maximum
[r,ts]=rdist(wo,ws,txm+matranges(round(subts/delt))); ts=ts(:);

% The amplitude scaling at the the XCORR/XDIST maximum
[dlnA,DlnA]=adist(wo,ws,txm);

% The amplitude scaling without any shifting
[dlnA0,DlnA0]=adist(wo,ws,0); 

% Find the (arg)minimum, negative offset means ws is delayed wrt wo
[rm,j]=min(r);
    trm=ts(j);
% Convert ts to units
    trms=delt*trm;
% What is the XCORR/XDIST optimized at the optimal rmse lag
    xtrm=x(find(t==ts(j)));

% Make the output structure
% Cross-correlation option, lags, values
c.xco=xco{xcor};
c.t=t;
c.x=x;

% Relative rmse and lag subset
c.ts=ts;
c.r=r;

% The (arg)max of cross-correlation, in sample index and time
c.txm=txm;
c.txms=txms;
c.xm=xm;
% Value as presented at zero lag without any shifting
c.x0=x0;
% Cross-correlation at the rmse optimum (minimum)
c.xtrm=xtrm;

% The (arg)min of relative rmse, in sample index and time
c.trm=trm;
c.trms=trms;
c.rm=rm;
% Value as presented at zero lag without any shifting
c.r0=r0;
% rmse at the cross-correlation optimum (maximum)
c.rtxm=rtxm;

% The amplitude factors
c.dlnA=dlnA;
c.dlnA0=dlnA0;

% The beginning and start times in units
c.relbeg=min(tw);
c.relend=max(tw);
% The beginning and start times in samples
c.relbegs=round(min(tw)/delt);
c.relends=round(max(tw)/delt);

% Now make the plot if you like
if nargout==0 || xver==1
  % Here is the plot
  clf
  set(gcf,'defaultLegendAutoUpdate','off');
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plots the data and the analysis window

  subplot(311)
  % Plot the observations, i.e. the first time series
  plot(tt,o,'r','LineWidth',1); hold on               
  % Plot the synthetics, i.e. the second time series
  plot(tt,s,'b')
  axis tight
  yls1=ylim;
  % Plot the observation windows
  plot([wt(1)   wt(1)  ],yls1,'k')
  plot([wt(end) wt(end)],yls1,'k')   
  hold off
  grid on
  openup(gca,6,30)
  yls2=ylim;
  hold on
  th(1)=text(wt(1)+[wt(end)-wt(1)]/2,yls1(2)-[yls1(2)-yls2(2)]/2,...
       sprintf('X(0) = %4.2f X(%s) = %4.2f %s = %4.1f s X(%s) = %4.2f',...
	       x0,'\tau',...
	       xm,'\tau',txms,...
	       '\sigma',xtrm));
  th(2)=text(wt(1)+[wt(end)-wt(1)]/2,yls1(1)+[yls2(1)-yls1(1)]/2,...
       sprintf('R(0) = %i%s R(%s) = %i%s %s = %4.1f s R(%s) = %i%s',...
	       round(100*r0),'%','\sigma',...
	       round(100*rm),'%','\sigma',trms,...
	       '\tau',round(100*rtxm),'%'));
  hold off
  set(th,'HorizontalAlignment','center')
  longticks(gca,2)
  ylabel('traces')
  xlabel('time [s]')
  if isstr(fname)
    titi=title(nounder(fname));
  else
    titi=title('Signals input by user on command line');
  end
  movev(titi,range(yls2)/20)
  legend('observation','synthetic')

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plots a zoom of the analysis window

  subplot(312)
  % Observation
  plot(wt,wo,'r','LineWidth',1); hold on
  % Synthetic
  plot(wt,ws,'b')

  % Plot the synthetic after shifting by cross-correlation optimizer
  % and rescaling by the amplitude factor
  oof=exp(dlnA);

  if txm~=0
    pda=plot(tt(tmi+txm:tma+txm),oof*ws,'k--');
    if txm<0
        legend(pda,sprintf(...
            'synthetic advanced by %4.1f s\n%15sand scaled by %4.2f',...
            abs(txms),'',oof),'Location','NorthEast')
    elseif txm>0
        legend(pda,sprintf(...
            'synthetic delayed by %4.1f s\n%15sand scaled by %4.2f',...
            abs(txms),'',oof),'Location','NorthWest')
    end
  else
    disp(sprintf('%s\n%s','At this sampling, and with this window',...
		 'the two time series ARE optimally aligned with respect to XCORR/XDIST'))
  end
  axis tight
  yls1=ylim;
  % Plot the original and overlapping windows
  ma=plot([wt(end) wt(end)],yls1,'Color','k');
  mi=plot([wt(1) wt(1)],yls1,'Color','k');

  % Adjust windows to show where you're really normalizing the rmse
  if txm<0
    delete(ma)
    plot([wt(end)+txms wt(end)+txms],yls1,'Color',grey)
  elseif txm>0
    delete(mi)
    plot([wt(1)+txms wt(1)+txms],yls1,'Color',grey)
  end
        
  hold off
  openup(gca,6,20)
  % The horizontal limits widened a bit
  xlim([wt(1) wt(end)]+[wt(end)-wt(1)]/10*[-1 1])
  grid on
  longticks(gca,2)

  ylabel('segments')
  xlabel('time [s]')
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plots the correlation coefficient and the rescaled rmse
  
  subplot(325)
  plot(t*delt,x,'m','LineWidth',1)
  hold on
  % If you want to see what the other one is
  plot(ts*delt,scale(-r,[-1 1]),'Color',grey)
  grid on
  legend('x','r''')
  % Mark the maximum of the cross-correlation coefficient
  plot(txms,xm,'^','MarkerFaceColor','m','MarkerEdgeColor','m')
  axis tight
  ylim([-1.15 1.15])
  xlabel('lag [s]')
  ylabel(sprintf('x | %s cross-correl',xco{xcor}))
  % The horizontal axis are all possible lags
  xls=xlim;
  hold on
  text(xls(1)+[xls(2)-xls(1)]/20, 1,sprintf('%s = %4.2f','X(\tau)',xm))
  text(xls(1)+[xls(2)-xls(1)]/20,-1,sprintf('%s = %4.2f','dlnA',dlnA))
  hold off
  longticks(gca)
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plots the rmse and the rescaled correlation coefficient
  
  subplot(326)
  plot(ts*delt,r*100,'Color',grey,'LineWidth',1)
  xlim(xls)
  grid on
  hold on
  % If you want to see what the other one is
  plot(t*delt,scale(-x,minmax(r*100)),'m')

  % Mark the minimum of the relative root-mean-squared error
  plot(trms,rm*100,'v','MarkerFaceColor',grey,'MarkerEdgeColor',grey)
  grid on
  legend('r','x''','Location','SouthEast')

  yls=ylim;
  ylim([-yls(2)/15 yls(2)])
  xlabel('lag [s]')
  ylabel(sprintf('r | relative rmse (%s)','%'))
  xls=xlim;
  hold on
  text(xls(1)+[xls(2)-xls(1)]/20,0,sprintf('%s = %4.2f','R(\sigma)',rm))
  hold off
  
  set(gca,'YAxisLocation','r')
  
  longticks(gca)
end

% Optional output
varns={c,o,s,tt};
varargout=varns(1:nargout);
