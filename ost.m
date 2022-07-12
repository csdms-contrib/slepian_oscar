function varargout=ost(fname,tw,delt,xver,xcor,subsi,fmt)
% [c,o,s,t]=ost(fname,tw,delt,xver,xcor,subsi,fmt)
%
% Observation-synthetic-triplet. Reads in a binary file containing a triplet
% of variables, one independent followed by two independent
% ones. Computes multiplicative and differential distance measures and
% makes a revealing plot if explicitly instructed.
%
% INPUT:
%
% fname     A file name string containing binaries t, o, and s
%           ... or a matrix with Mx3 entries
% tw        Beginning and end of the time window (inclusive)
% xver      1 Makes a plot 
%           0 does not
% xcor      1 option 'coeff' for XCORR [default]
%           2 option 'unbiased' for XCORR
%           3 option 'biased' for XCORR
%           4 option 'none' for XCORR
% subsi     Subset in seconds for XCORR/RMSE comparison (default: [-200:200])
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
% 
%
% SEE ALSO: XCORR and RDIST
%
% Written for 8.3.0.532 (R2014a)
% Last modified by fjsimons-at-alum.mit.edu, 07/11/2022

%% INPUT %%
% Defaults
defval('fname','IU.AFI_Z.dat')
defval('tw',[2275 2854])
defval('delt',0.2)
defval('xver',1)
defval('xcor',1)
defval('subsi',[-300:300])
defval('fmt','float64')
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
[r,ts]=rdist(wo,ws,txm+round(subsi/delt)); ts=ts(:);

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

% Now make the plot if you like
if nargout==0 || xver==1
  % Here is the plot
  clf

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
  title(nounder(fname))
  legend('observation','synthetic')

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plots a zoom of the analysis window

  subplot(312)
  % Observation
  plot(wt,wo,'r','LineWidth',1); hold on
  % Synthetic
  plot(wt,ws,'b')
  % Plot the synthetic after shifting by cross-correlation optimizer
  if txm~=0
    pda=plot(tt(tmi+txm:tma+txm),ws,'k-');
    if txm<0
      legend(pda,sprintf('synthetic advanced by %4.1f s',abs(txms)))
    elseif txm>0
      legend(pda,sprintf('synthetic delayed by %4.1f s',abs(txms)))
    end
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
  elseif tm>0
    delete(mi)
    plot([wt(1)+txms wt(1)+txms],yls1,'Color',grey)
  end
        
  hold off
  openup(gca,6,20)
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
  xls=xlim;
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
  
  set(gca,'YAxisLocation','r')
  
  longticks(gca)
end

% Optional output
varns={c,o,s,tt};
varargout=varns(1:nargout);

