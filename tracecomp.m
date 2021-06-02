function tracecomp(fname,nxi,scal,cols,fd,prop)
% TRACECOMP(fname,nxi,scal,fd,prop)
%
% Compares traces of a shot gather and makes an annotated plot
%
% INPUT:
%
% fname      Full path and file name to data file containing
%               data_init, data_obs, and data_inv
% nxi        The trace skip [default: every 5]
% scal       The trace scaling [default: 1]
% cols       A color string sequence [default: 'kbg'] for
%               initial, observed, final
% fd         1 Time runs down [default]
%            2 Time runs across
% prop       1 Displays maximum absolute normalized correlation
%            2 Displays time delay at maximum absolute normalized correlation
%
% OUTPUT:
%
% po,pi,pf   Handles to the observations, initial fits, and final fits
%
% Last modified by fjsimons-at-alum.mit.edu, 06/01/2021

% Default values
defval('fname','/u/fjsimons/POSTDOCS/ZhaolunLiu/DATA/data_shot33')
defval('nxi',5)
defval('scal',1)
defval('cols','kbr')
defval('fd',1)
defval('prop',1)

% Figure out the line number from the data, unless you save it
[~,fn]=fileparts(fname);
is=str2num(fn(fn>48 & fn<65));

% Load data, which contains data_init, data_inv, and data_obs
load(fname)

% Zhaolun, dt should be a variable saved in the *.mat file, as should
% other metadata, such as what instrument, what component, what
% filtering, and information relating to the initial and final fits
dt=5e-4;
t=[0:size(data_obs,1)-1]*dt;

% Easy indexing
enxi=1:nxi:size(data_obs,2);

% Figure out the pairwise metrics
% Could do all, or just the ones plotted...
for index=1:length(enxi)
  % disp(sprintf('Comparing trace %i',enxi(index)))
  [moi(index),loi(index)]=max(abs(...
      xcorr(data_obs(:,enxi(index)),data_init(:,enxi(index)),'coeff')));
  [mof(index),lof(index)]=max(abs(...
      xcorr(data_obs(:,enxi(index)),data_inv(:,enxi(index)),'coeff')));
  if prop==1
    % Percentage correlation
    propi(index)=round(100*moi(index));
    propf(index)=round(100*mof(index));
  elseif prop==2
    % Time delay
    propi(index)=loi(index)*dt;
    propf(index)=lof(index)*dt;
  end
end

% Start the plot
clf
ah=gca;

% Plot the initial model synthetics
[pis,thi]=plotit(t,data_init(:,enxi),scal,rindeks(getcol(cols),1),fd,91,propi,prop);

% Plot the observed synthetics
hold on
pos=plotit(t,data_obs(:,enxi),scal,rindeks(getcol(cols),2),fd);

% Plot the final model synthetics
hold on
[pfs,thf]=plotit(t,data_inv(:,enxi),scal,rindeks(getcol(cols),3),fd,95,propf,prop);

% Cosmetics
axis ij
tl=title(sprintf('shot %i',is));
movev(tl,-range(ylim)/30)
longticks(gca,2)

% Make all the initial fits grey and thin etc, 
set(pos,'LineWidth',0.5)
set(pfs,'LineWidth',0.25)
set(pis,'Color',grey,'LineWidth',0.25)
set(thi(isgraphics(thi)),'Color',grey)
set(thi(isgraphics(thi)),'FontSize',4)
set(thf(isgraphics(thi)),'FontSize',4)

% If the final is better than the initial set it to boldface
for index=1:length(thi)
  if isgraphics(thi(index)) & isgraphics(thf(index))
    if prop==1
      if str2num(get(thf(index),'string')) > str2num(get(thi(index),'string'))
	set(thf(index),'FontWeight','bold')
      end
    elseif prop==2
      if abs(str2num(get(thf(index),'string'))) < abs(str2num(get(thi(index),'string')))
	set(thf(index),'FontWeight','bold')
      end      
    end
  end
end

% Maybe change order with UISTACK

if fd==1
  lb(1)=ylabel('time [s]');
  lb(2)=xlabel('receiver');
  axis tight
  ylim([0 round(max(t))])
  xlim(xpand(xlim,5))
  shrink(ah,1,1.5)
  set(ah,'XTick',1:nxi:length(enxi),'XTickLabel',enxi(1:nxi:end))
elseif fd==2
  lb(1)=xlabel('time [s]');
  lb(2)=ylabel('receiver');
  axis tight
  xlim([0 round(max(t))])
  ylim(xpand(ylim,5))
  shrink(ah,1.5,1)
  set(ah,'YTick',1:nxi:length(enxi),'YTickLabel',enxi(1:nxi:end))
end

% Plot suggestion and execution
set(gcf,'Units','Inches','PaperPositionMode','Auto','PaperUnits','Inches',...
	'PaperSize',indeks(get(gcf,'Position'),[3 4]));
set(gcf,'renderer','paint')
figdisp(fn,sprintf('%i_%i',fd,prop),[],2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunction with the wiggle plot - individually scaled and centered
function [ph,th]=plotit(t,data,scal,col,fd,varargin)

% Initialize handles
ph=nan(size(data,2),1);

% Determine offsets when none are given
x=1:size(data,2);
% Determine offset spacing when none are given
dx=diff(x); dx=[dx dx(end)]/2*scal;

% Individual traces
for index=1:size(data,2)
  % Determine the scaled data while preserving the center
  sdata=indeks(...
      scale([data(:,index) ; max(abs(data(:,index)))],[-1 1]*dx(index)),...
      '1:end-1');
  
   % Do the actual plotting
  if fd==1  
    ph(index)=plot(x(index)+sdata-median(sdata),t,'Color',col);
  elseif fd==2
    ph(index)=plot(t,x(index)+sdata-median(sdata),'Color',col);
  end
  
  % The extra arguments are for metrics - first a location, next a value
  if nargin>5 & ~isnan(varargin{2}(index))
    if fd==1
      % Time is down
      if varargin{3}==1
	% Correlation percentage
	th(index)=text(x(index)+dx(index)/4,varargin{1}*max(t)/100,...
		       num2str(varargin{2}(index)),'Color',col);
      elseif varargin{3}==2
	% Time delay
	th(index)=text(x(index)+dx(index)/4,varargin{1}*max(t)/100,...
		       sprintf('%3.1f',varargin{2}(index)),'Color',col);
      end
    elseif fd==2
      % Time is across
      if varargin{3}==1
	% Correlation percentage
	th(index)=text(varargin{1}*max(t)/100,x(index)+dx(index),...
		       num2str(varargin{2}(index)),'Color',col);
      elseif varargin{3}==2
	% Time delay
	th(index)=text(varargin{1}*max(t)/100,x(index)+dx(index),...
		       sprintf('%3.1f',varargin{2}(index)),'Color',col);
      end
    end
  end
  hold on
end
hold off

