function varargout=surfacewin(tminmax,dt,x,u1u2,son,sful)
% [Wtx,t,x]=SURFACEWIN(tminmax,dt,x,u1u2,son,sful)
%
% Makes a "surface-wave" selective time-window set, simply: returns a
% "time-distance" mask of ones and zeros bounded by two "group" speeds.
% Minimum sample lengths apply as to what constitues a "valid" window.
%
% INPUT:
%
% tminmax    Minimum/maximum time (default: [0 100])
% dt         Time step [default: 1]
% x          Space coordinates [default: 0:100]
% u1u2       Group velocity bounds in whatever space/units time apply [defaulted]
%            and note that 0 and Inf are allowed for one-sided windows
% son        1 "surface waves" are on
%            0 "surface waves" are off [default]
% sful       0 returns a full matrix of the right full size
%            1 returns a sparse matrix of the right full size [default]
%            2 returns a full matrix of the minimal size
%            3 returns a sparse matrix of the minimal size
%
% OUTPUT:
%
% Wtx        A (time,space) matrix with ones and zeros
% t          Time coordinates
% x          Space coordinates
%
% EXAMPLES:
%
% surfacewin('demo1')
% spy(surfacewin([],[],[0:10 40:60 80:100],[2 8],[],1))
%
% TESTED ON:
%
% 8.3.0.532 (R2014a) and 9.0.0.341360 (R2016a)
%  
% Last modified by fjsimons-at-alum.mit.edu, 07/28/2020

% Specify defaults
defval('tminmax',[0 100])

if ~isstr(tminmax)
  defval('dt',1)
  defval('x',0:100)
  defval('u1u2',[4 6])
  defval('son',0)
  defval('sful',1)

  % Group velocities will be sorted
  % if u1>u2; [u2,u1]=deal(u1,u2); end
  u1=min(u1u2);
  u2=max(u1u2);
  
  % Delimit the time samples inside the speed cone
  Wfst= ceil([x/u2-tminmax(1)]/dt)+1;
  Wslo=floor([x/u1-tminmax(1)]/dt)+1;

  % This really only makes sense if the SEPARATION is at least  WO dt, so
  % you can enumerate a TWO-SAMPLE window, and you want to only start at
  % the point where you never drop BELOW that threshold should you hit nodes
  xof=max(find((Wslo-Wfst)<2)+1);
  if ~isempty(xof)
    xof=min(xof,length(x));
  else
    xof=1;
  end

  Wfst=min(Wfst,range(tminmax)/dt+1);
  Wslo=min(Wslo,range(tminmax)/dt+1);  

  Wfst=Wfst(xof:min(length(Wfst),length(x)));
  Wslo=Wslo(xof:min(length(Wslo),length(x)));

  % You should never drop below TWO samples here except below the
  % diagonal if truncated
  checkit=(Wslo-Wfst)<2;
  if any(checkit)
    disp('You were having some singleton windows presumed in the tail')
    % Definitely cut those tails off --- below we do assume they are tails!
    Wslo=Wslo(~checkit);
    Wfst=Wfst(~checkit);
  end

  if ~isempty(Wfst) &&  ~isempty(Wslo) 
    % And mask it on or off
    switch sful
     case {2 3}
      Wtx=sparse(matranges([Wfst ; Wslo]),gamini(xof:length(x)-sum(checkit),Wslo-Wfst+1),1);
     case {0 1}
      Wtx=sparse(matranges([Wfst ; Wslo]),gamini(xof:length(x)-sum(checkit),Wslo-Wfst+1),1,...
		 range(tminmax)/dt+1,length(x(:)));
    end
    switch sful
     case {0 2}
      Wtx=full(Wtx);
    end
    if son==0
      Wtx=~Wtx;
    end
  else
    Wtx=0;
  end

    % If only one velocity given, treats it like the slower one and adds
  % infinty as the faster one
  if isinf(u2) && son==0
    Wtx(1,2:end)=0;
  end

  if nargout>1
    % Note that you may not reach the maximum time if the step is off
    t=tminmax(1):dt:tminmax(2);
  else
    t=[];
  end
elseif strcmp(tminmax,'demo1')
  % Just some random values
  if (-1)^randi(2)-1
    u1u2=sort(randi(10,1,2));
  else
    u1u2=sort(rand(1,2)*5);
  end
  if prod(size(unique(u1u2)))==1; clf ; error('Try again'); end
  % Be explicit about t and x such that the plot works
  [Wtx,t,x]=surfacewin([0 100],1,[0:100],u1u2,[],1);
  if prod(size(Wtx))==1
    Wtx=zeros(length(t),length(x));
  end
  clf
  % When using spy, see adjustments below!
  spy(Wtx)
  hold on
  u1=min(u1u2);
  u2=max(u1u2);
  % The group velocity bounds are plotted in PHYSICAL space 
  dt=[t(2)-t(1)];
  pu(2)=plot(x,[x/u2-min(t)]/dt,'r');
  pu(1)=plot(x,[x/u1-min(t)]/dt,'g');
  lg=legend(pu,sprintf('U_1 = %3.1f',u1u2(1)),sprintf('U_2 = %3.1f',u1u2(2)),...
	    'Location','SouthWest');
  hold off

  % Cosmetics and labeling
  dots=findobj('Marker','.');
  set(dots,'MarkerSize',3)
  longticks(gca)
  set(pu,'LineWidth',0.75)
  tl(1)=title(sprintf('group speeds %3.1f and %3.1f [space/time], nnz %i', ...
		u1u2(1),u1u2(2),nnz(Wtx)));
  xl(1)=xlabel('space');
  yl(1)=ylabel('time');

  if ~verLessThan('matlab','9')
    % R2016a stuff
    shrink(gca,1.2,1.2)
    set(tl,'FontWeight','normal')
    movev(tl,-5)
    % When using spy it's using SAMPLE indices, I want to start them at 0
    % to maximize the chances at looking good IN THIS EXAMPLE where the
    % time and the space samplings are both 0
    dots.XData=dots.XData-1;
    dots.YData=dots.YData-1;
    uistack(dots,'top')
  end

  xel=get(gca,'XLim'); yel=get(gca,'YLim');
  xlim(minmax(xel)+[-1 1]*range(xel)/50)
  ylim(minmax(yel)+[-1 1]*range(yel)/50)
  
  % Also make a nice picture
%  figdisp([],'demo1',[],2)
end
  
% Allocate outputs
varns={Wtx,t,x};
varargout=varns(1:nargout);

% Make a plot
