function [r,lags]=rdist(a,b,lags)
% [r,lags]=RDIST(a,b,lags)
%
% Lagged relative root-mean-squared difference between two vectors,
% e.g. time series, i.e. the "difference" version of the
% "multiplicative" signal similarity measure XCORR, i.e. the rms of
% the difference between two vectors normalized by the rms of the
% first one, in the area of overlap. One could think of normalizing
% using either the first or the second signal, or in terms of the
% square root of the products of the rms of both, but only normalizing
% by the first input is supported here. Note that the signals are NOT
% demeaned, if you want that, that is your job, as it's a choice with
% consequences.
%
% INPUT:
%
% a,b         Two equal-length vectors (shortest will be zero-padded)
% lags        The lags at which the measure is to be computed (defaulted)
%
% OUTPUT:
%
% r           The root-mean-squared difference between the timeseries
%             shifted to the lags in question, normalized by the
%             root-mean-squared value of the FIRST input time series in
%             the area of overlap
% lags        The lags at which the measure was computed [defaulted]
% 
% SEE ALSO: XCORR and OST, and XDIST
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
r=nan(length(lags),1);

% Do the computation, "for" loop might be slower but vectorization costs memory
i=0;
for l=lags
  i=i+1;
  r(i)=sqrt(...
            sum([b(1-l*[l<0]:end-l*[l>0])-a(1+l*[l>0]:end+l*[l<0])].^2)...
                                     /sum(a(1+l*[l>0]:end+l*[l<0]).^2)...
            );
end



