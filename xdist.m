function [x,lags]=xdist(a,b,lags)
% [x,lags]=XDIST(a,b,lags)
%
% Normalized cross-correlation between two vectors, e.g. time series,
% the "multiplicative" version of the "difference" signal similarity
% measure RDIST, normalized by the cross-correlation of the signal at
% zero lag in the area of overlap. One could think of normalizing
% using the zero-lagautocorrelation of either the first or the second
% signal, or in terms of the square root of the cross-correlation at
% zero lag, the latter of which is the only option supported here,
% making this measure at truly shifted correlation coefficient... Note
% that the signals are NOT demeaned, if you want that, that is your
% job, as it's a choice with consequences.
%
% INPUT:
%
% a,b         Two equal-length vectors (shortest will be zero-padded)
% lags        The lags at which the measure is to be computed (defaulted)
%
% OUTPUT:
%
% x The correlation coefficient between the timeseries shifted to the
%             lags in question, i.e. the cross-correlation normalized
%             by the square root of the cross-correlation between the
%             two signals at zero lag in the area of overlap
% lags        The lags at which the measure was computed [defaulted]
% 
% SEE ALSO: RDIST, XCORR, and OST
%
% Last modified by fjsimons-at-alum.mit.edu, 02/22/2023

% Only vectors, same length or zero-pad
a=a(:);
b=b(:);
if length(a)<length(b)
  a=[a ; zeros(length(b)-length(a),1)];
else
  b=[b ; zeros(length(a)-length(b),1)];
end
% Now they are the same
M=length(a);

% Defaults like in XCORR
maxlag=M-1;
defval('lags',-maxlag:maxlag);

% Initialize output
x=nan(length(lags),1);

% Do the computation, "for" loop might be slower but vectorization costs memory
i=0;
for l=lags
  i=i+1;
  x(i)=sum([b(1-l*[l<0]:end-l*[l>0]).*a(1+l*[l>0]:end+l*[l<0])])...
  /sqrt(sum(b(1-l*[l<0]:end-l*[l>0]).^2))...
  /sqrt(sum(a(1+l*[l>0]:end+l*[l<0]).^2));
end



