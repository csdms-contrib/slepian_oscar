function [x,lags]=xdist(a,b,lags,nm)
% [x,lags]=XDIST(a,b,lags,nm)
%
% Lagged normalized cross-correlation between two vectors, e.g. time
% series, i.e. the "multiplicative" version of the "difference" signal
% similarity measure RDIST, i.e. the cross-correlation between two
% vectors normalized by their cross-correlation at zero lag, in the
% area of overlap, which is demeaned. One could think of normalizing
% using the zero-lag autocorrelation of either the first or the second
% signal, or in terms of square root of the products of these
% autocorrelations at zero lag, the latter of which is the only option
% supported here, making this measure a truly shifted correlation
% coefficient. The difference with XCORR option 'corr' is that the
% normalization there is NOT recomputed in the area of overlap, and
% the segments are not demeaned, but calculated once at the start,
% which is appropriate for stationary zero-mean signals. See also CORR
% and CORRCOEF.
%
% INPUT:
%
% a,b         Two equal-length vectors (shortest will be zero-padded)
% lags        The lags at which the measure is to be computed (defaulted)
% nm          1 overlapped portions are individually demeaned [default]
%             0 overrides the demeaning
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
% Last modified by fjsimons-at-alum.mit.edu, 03/16/2023

% If 1, which should be default, individually sequentially demeaned
defval('nm',1)

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
    % The index into b of the interval of overlap
    blap=1-l*[l<0]:M-l*[l>0];
    % The index into a of the interval of overlap
    alap=1+l*[l>0]:M+l*[l<0];
    % Demean the individual segments, maybe overridden
    bm=mean(b(blap))*nm; am=mean(a(alap))*nm;
    % The ab-sqrt-normalized cross-correlation
    x(i)=sum([b(blap)-bm].*[a(alap)-am])...
         /sqrt(sum([b(blap)-bm].^2))/sqrt(sum([a(alap)-am].^2));
end
