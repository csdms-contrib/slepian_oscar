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
% Last modified by fjsimons-at-alum.mit.edu, 09/13/2017

% Location from SAC2SAC, check with header
lola=[-74.65475 40.34585];

ph=plot(linspace(HdrData.B,HdrData.E,HdrData.NPTS),SeisData);
tl=title(sprintf('recorded at Princeton University Guyot Hall %s (%7.3f%s,%7.3f%s)',deblank(HdrData.KSTNM),...
		 lola(1),176,lola(2),176));

yl=ylabel(sprintf('uncorrected %s component',...
		  HdrData.KCMPNM));
xl=xlabel(sprintf('time (s) since %4.4i (%3.3i) %2.2i:%2.2i:%2.2i.%3.3i',...
		  HdrData.NZYEAR,HdrData.NZJDAY,...
		  HdrData.NZHOUR,HdrData.NZMIN,HdrData.NZSEC,HdrData.NZMSEC));
axis tight

if ~isempty(varargin)
  setx(ph,varargin{:})
end 

longticks(gca,2)

% Optional output
varns={ph,tl,xl,yl};
varargout=varns(1:nargout);

