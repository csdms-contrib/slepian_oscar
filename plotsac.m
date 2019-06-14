function varargout=plotsac(SeisData,HdrData,varargin)
% [ph,xl,yl]=PLOTSAC(SeisData,HdrData,'Property','Value')
%
% INPUT
%
% SeisData        The numbers vector (e.g. from READSAC)
% HdrData         The header structure array (e.g. from READSAC)
% 'Property'      Some plot handle property
% 'Value'         Some plot handle value
%                 ... You can input any number of pairs of these two
%
% OUTPUT
%
% ph              The plot handle or object
% tl              The title handle
% xl              The x-label handle
% yl              The y-label handle
%
% SEE ALSO
%
% READSAC, WRITESAC, MCM2SMAT
%
% Last modified by fjsimons-at-alum.mit.edu, 06/14/2019

% Guyot Hall STLO and STLA, check with SAC2SAC, check with HdrData
lola=guyotphysics(0);

% Plot the trace
ph=plot(linspace(HdrData.B,HdrData.E,HdrData.NPTS),SeisData);

% Cosmetics and annotation
tl=title(sprintf('recorded at Princeton University Guyot Hall %s (%10.5f%s,%10.5f%s)',deblank(HdrData.KSTNM),...
		 lola(1),176,lola(2),176),...
	         'FontWeight','Normal');
yl=ylabel(sprintf('uncorrected %s component',...
		  HdrData.KCMPNM));
xl=xlabel(sprintf('time (s) since %4.4i (%3.3i) %2.2i:%2.2i:%2.2i.%3.3i',...
		  HdrData.NZYEAR,HdrData.NZJDAY,...
		  HdrData.NZHOUR,HdrData.NZMIN,HdrData.NZSEC,HdrData.NZMSEC));
axis tight
longticks(gca,2)

% Touch up, if requested
if ~isempty(varargin)
  setx(ph,varargin{:})
end 

% Optional output
varns={ph,tl,xl,yl};
varargout=varns(1:nargout);

