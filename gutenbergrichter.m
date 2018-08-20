function A=gutenbergrichter(Mb,Del,T)
% A=GUTENBERGRICHTER(Mb,Del,T)
%
% Calculates the "amplitude" of a "seismic wave".
%
% Use this for shallow teleseismic events. 
%
% Note this is the vertical-component P-wave amplitude. 
% See NMSOP and Udias for more. For shallow sources.
%
% INPUT
%
% Mb       Body-wave magnitude
% Del      Epicentral distance (in degrees)
% T        Dominant period [default: 1 s]
%
% OUTPUT
%
% A        Ground displacement amplitude, in micrometers (10^-6 m)
%
% See also: REID, WOODANDERSON
%
% Last modified by fjsimons-at-alum.mit.edu, 06/24/2008

defval('T',1)

% Load the table of correction values
load(fullfile(getenv('IFILES'),'VARIOUS','GutenbergRichter'))

% Convert epicentral distance from degrees to kilometers
dkm=Del*fralmanac('DegDis')/1000;

if dkm<600
  disp('Epicentral distance too small to be valid - use WOODANDERSON')
end

% Guard against the endpoints
mind=min(GutenbergRichter(:,1));
maxd=max(GutenbergRichter(:,1));
minQ=min(GutenbergRichter(:,2));
maxQ=max(GutenbergRichter(:,2));

if Del>maxd
  disp(sprintf(...
      'Input exceeds table range by %3.1f - highest value Q = %3.1f supplied',...
      Del-maxd,maxQ))
  Q=maxQ;
elseif Del<mind
  disp(sprintf(...
      'Input exceeds table range by %3.1f - lowest value Q = %3.1f supplied',...
      mind-Del,minQ))
  Q=minQ;
else
  % Look up the correction value
  Q=interp1(GutenbergRichter(:,1),GutenbergRichter(:,2),...
	    Del,'nearest');
end

display(sprintf('Using correction factor Q of %3.1f',Q))

% See NMSOP
A=10^(Mb-Q)*T;
