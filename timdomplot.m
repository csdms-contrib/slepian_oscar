function [x,h,Fs,p,xl,yl,tl,pt01,xf]=timdomplot(filenam1,dec,fname,varargin)
% [x,h,Fs,p,xl,yl,tl,pt01,xf]=TIMDOMPLOT(filenam1,dec,fname,opts)
%
% Plots the data contained in the filename in the time domain 
%
% INPUT:
%
% filenam1  The file name to be read by READSAC
% dec       0 Reads in filename and plots raw data
%           1 Reads in filename and plots raw data
%           2 Reads in filename and plots filtered data
% fname     Filter name: 'lowpass', 'highpass', 'bandpass'
% opts      A comma-separated list of filter options:
%             Corner frequency (Hz)
%             Number of poles
%             Number of passes
%             Filter name (e.g. 'butter')
% 
% OUTPUT:
%
% x         The record being plotted (the original version)
% h         Record header
% Fs        Sampling frequency of the signal
% p         Handle to the plotted line
% xl        Handle to the xlabel
% yl        Handle to the ylabel
% tl        Handle to the title
% pt01      Handle to the plotted dashed lines
% xf        The filtered record, if indeed it was filtered
%
% Used by SIGNALS and SIGNALS2; using LOWPASS 
% see also TIMSPECPLOT, SPECDENSPLOT
%
% Last modified by fjsimons-at-alum.mit.edu, 07/24/2014

defval('dec',0)
  
% If the filter arguments are empty but a filter is wanted anyway
if nargin==2 | isempty(varargin) | isempty([varargin{:}])
  defval('fname','lowpass')
% varargin=[{0.05} {2} {2} {'butter'}]; % For EVENTS
% varargin=[{1} {2} {2} {'butter'}];  % For SIGNALPLOTS
end

switch dec
 case {0,1}
  [x,h,tl,p]=readsac(filenam1,1,'l');
  yl=ylabel('Amplitude');
  xf=NaN;
 case 2
  [x,h,tl,p(1)]=readsac(filenam1,0,'l');
  % Perform the required filtering
  if iscell(varargin{1})
    [xf,co,npo,npa,fnm]=feval(fname,x,1/h.DELTA,varargin{1}{:});
  else
    [xf,co,npo,npa,fnm]=feval(fname,x,1/h.DELTA,varargin{:});
  end
  % Plot the filtered data - remember this also centers around zero
  p(1)=plot(linspace(h.B,h.E,h.NPTS),xf);
  tl=title(tl);
  axis tight
  p(2)=xlabel(sprintf('Time (s)'));
  axis tight
  if length(co)==1
    yl=ylabel(sprintf('Filtered Amplitude, %4.2f Hz',co));
  else
    yl=ylabel(sprintf('Filtered Amplitude, %4.2f-%4.2f Hz',co(1),co(2)));
  end
end
Fs=1/h.DELTA;

xl=p(2);
p=p(1);
if h.T0~=-12345 & h.T1~=-12345
  hold on
  yli=ylim;
  pt01=plot(repmat([h.T0 h.T1],2,1),[yli(1) yli(2)],'k--');
  set(xl,'string',sprintf('%s ; %i s selected',...
		      'Time (s)',ceil(h.T1-h.T0)));
  hold off
else 
  pt01=NaN;
end


