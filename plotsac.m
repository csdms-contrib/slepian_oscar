function varargout=plotsac(SeisData,HdrData,varargin)
% PLOTSAC(SeisData,HdrData,'Property','Value')
% handle=PLOTSAC(SeisData,HdrData,'Property','Value')
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
% handle          The plot handle or object
%
% SEE ALSO
%
% READSAC, WRITESAC, MCM2SMAT
%
% Last modified by fjsimons-at-alum.mit.edu, 07/01/2016

ph=plot(linspace(HdrData.B,HdrData.E,HdrData.NPTS),SeisData);
xlabel([ 'time (s)'])
axis tight

if ~isempty(varargin)
  setx(ph,varargin{:})
end 

% Optional output
varns={ph};
varargout=varns(1:nargout);

