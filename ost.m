function varargout=ost(fname,tw,delt,xver,xcor,subts,fmt)
% [c,o,s,t]=ost(fname,tw,delt,xver,xcor,subts,fmt)
%
% Observation-synthetic-triplet. Reads in a binary file containing a triplet
% of variables, one independent followed by two independent ones. Computes
% multiplicative and differential distance measures of the demeaned time
% series, and makes a revealing plot if explicitly instructed.
%
% INPUT:
%
% fname     A file name string containing binaries t, o, and s
%           ... or a matrix with Mx3 entries, used as input 
% tw        Beginning and end of the time window of interest
%           inclusive, in the same unit as the array input t
% delt      Sampling step of these two signals in seconds
% xver      1 Makes a plot 
%           0 does not
% xcor      1 option 'coeff' for XCORR [default]
%           2 option 'unbiased' for XCORR
%           3 option 'biased' for XCORR
%           4 option 'none' for XCORR
% subts     Subset in t units for XCORR/RMSE comparison (default: [-200 200])
% fmt       The binary format of the data file (default: 'float64')
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
% tt=linspace(0,10,101); o=cos(2*pi/3*tt); s=3*cos(2*pi/3*[tt-0.2]);
% c=ost([tt' o' s'],[3 7],tt(2)-tt(1),1,1,[-1 1]);
%
% ozrt=reshape(loadb('C201505191525A.IU.AFI.obs.ZRT.bin'),[],3);
% szrt=reshape(loadb('C201505191525A.IU.AFI.syn.ZRT.bin'),[],3);
% comp='R'; % Work in samples
% ost([[1:size(ozrt,1)]' ozrt(:,2) szrt(:,2)],[6731 9830])
% 
%% Check the example in XCORR and apply RDIST for comparison!
% 
% SEE ALSO: XCORR and RDIST
%
% Written for 8.3.0.532 (R2014a)
% Last modified by fjsimons-at-alum.mit.edu, 07/12/2022

%% INPUT %%
% Defaults
defval('fname','IU.AFI_Z.bin')
defval('tw',[2275 2854])
defval('delt',0.2)
defval('xver',1)
defval('xcor',1)
defval('subts',[-200 200])
defval('fmt','float32')
% Prepare for options
xco={'coeff','unbiased','biased','none'};

if isstr(fname)
  % Load it, it was just a straight bitwrite
  ost=loadb(fname,fmt);
  % Split it
  tt=ost(                1:  length(ost)/3);
  o=ost(  length(ost)/3+1:2*length(ost)/3);
  s=ost(2*length(ost)/3+1:  length(ost));
else
  tt=fname(:,1);
   o=fname(:,2);
   s=fname(:,3);
end

%% CALCULATION %%

% The indices corresponding to the time window
tmi=min(find(tt>=tw(1)));
tma=max(find(tt<=tw(2)));

% Identify the segments and demean 
wt=tt(tmi:tma); 
ws= s(tmi:tma)-mean(s(tmi:tma));
wo= o(tmi:tma)-mean(o(tmi:tma));

%% Multiplicative distance using XCORR %%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the appropriate correlation 
[x,t]=xcorr(wo,ws,xco{xcor}); t=t(:);
% Find the (arg)maximum, negative offset means ws is delayed wrt wo
[xm,j]=max(x);
    txm=t(j);
% Convert tau to units
    txms=delt*txm;

% The zero-lag cross-correlation... is at length(ws)=length(wo) 
x0=x(length(ws));

%% Difference distance using RDIST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The observation-normalized rmse at optimal CROSS-CORRELATION lag,
% i.e. shifted into alignment and taking care of the non-overlapping edges!
rtxm=rdist(wo,ws,txm); 

% The zero-lag normalized rmse
r0=sqrt(sum([ws-wo].^2)/sum(wo.^2));

% The normalized rmse at a subset around the cross-correlation maximum
[r,ts]=rdist(wo,ws,txm+matranges(round(subts/delt))); ts=ts(:);

% The amplitude scaling at the the cross-correlation maximum
[dlnA,DlnA]=adist(wo,ws,txm); 
% The amplitude scaling without any shifting
[dlnA0,DlnA0]=adist(wo,ws,0); 

% Find the (arg)minimum, negative offset means ws is delayed wrt wo
[rm,j]=min(r);
    trm=ts(j);
% Convert ts to units
    trms=delt*trm;

% What is the cross-correlation optimized at the optimal rmse lag
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
% rmse optimum at the cross-correlation optimum (maximum)
c.rtxm=rtxm;

% The amplitude factors
c.dlnA=dlnA;
c.dlnA0=dlnA0;

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
  xlabel('time [samples]')
  if isstr(fname)
    title(nounder(fname))
  else
    title('Signals input by user on command line')
  end
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
		 'the two time series are optimally aligned with respect to XCORR'))
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
  xlim([wt(1) wt(end)]+[wt(end)-wt(1)]/10*[-1 1])
  grid on
  longticks(gca,2)

  ylabel('segments')
  xlabel('time [samples]')
  
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
  xlabel('lag [samples]')
  ylabel(sprintf('x | %s cross-correl',xco{xcor}))
  xls=xlim;
  hold on
  text(xls(1)+[xls(2)-xls(1)]/20, 1,sprintf('%s = %4.2f','\tau',xm))
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
  xlabel('lag [samples]')
  ylabel(sprintf('r | relative rmse (%s)','%'))
  xls=xlim;
  hold on
  text(xls(1)+[xls(2)-xls(1)]/20,0,sprintf('%s = %4.2f','\sigma',rm))
  hold off
  
  set(gca,'YAxisLocation','r')
  
  longticks(gca)
end

% Optional output
varns={c,o,s,tt};
varargout=varns(1:nargout);

