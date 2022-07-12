function [r,lags]=rdist(a,b,lags)
% [r,lags]=RDIST(a,b,lags)
%
% Relative root-mean-squared difference between two time series, the
% difference version of the multiplicative signal similarity measure XCORR,
% normalized by the rmse of the first signal in the area of overlap. Note
% that the signals are NOT demeaned, if you want that, that is your job.
%
% INPUT:
%
% a,b         Two equal-length vectors (shortest zero-padded)
% lags        The lags at which the measure is to be computed
%
% OUTPUT:
%
% r           The root-mean-squared difference between the timeseries
%             shifted to the lags in question, normalized by the
%             root-mean-squared value of the FIRST input time series in
%             the area of overlap
% lags        The lags at which the measure was computed [defaulted]
% 
% SEE ALSO: XCORR and OST
%
% Last modified by fjsimons-at-alum.mit.edu, 07/12/2022

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

% Do the computation, for loop might be slower but vectorization costs memory
i=0;
for l=lags
  i=i+1;
  r(i)=sqrt(sum([b(1-l*[l<0]:end-l*[l>0])-a(1+l*[l>0]:end+l*[l<0])].^2)...
       /sum(a(1+l*[l>0]:end+l*[l<0]).^2));
end



