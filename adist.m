function [dlnA,DlnA,lags]=adist(a,b,lags)
% [dlnA,DlnA,lags]=ADIST(a,b,lags)
%
% Lagged relative amplitude ratio between two vectors, e.g. time
% series, i.e. the "logarithmic" "integrated" "ratio" version of the
% "multiplicative" signal similarity measure XDIST/XCORR or the
% "difference" similarity RDIST, i.e. the log ratio of the rms
% amplitudes of two vectors, in the area of overlap. Note that the
% signals are NOT demeaned, if you want that, that is your job, as
% it's a choice with consequences. See
% 10.1111/j.1365-246X.2009.04099.x eq. (11).
%
% INPUT:
%
% a,b         Two equal-length vectors (shortest will be zero-padded)
% lags        The lags at which the measure is to be computed (defaulted)
%
% OUTPUT:
%
% dlnA        The log amplitude ratio between the timeseries
%             shifted to the lags in question, the numerator is the
%             FIRST and the denominator is the SECOND input time
%             series in the area of overlap
% DlnA        The first-order discrete approximation, the
%             difference in amplitude betwee the FIRST and the
%             SECOND, normalized by the amplitude of the SECOND
% lags        The lags at which the measure was computed [defaulted]
% 
% SEE ALSO: XCORR and OST, and XDIST
%
% Last modified by fjsimons-at-alum.mit.edu, 03/16/2023

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
    % The index into b of the interval of overlap
    blap=1-l*[l<0]:M-l*[l>0];
    % The index into a of the interval of overlap
    alap=1+l*[l>0]:M+l*[l<0];

    % b-normalized Alessia Maggi's definition
    dlnA(i)=1/2*(log(sum(a(alap).^2)./sum(b(blap).^2))); 
    % b-normalized Dahlen and Baig's definition, poor approximation
    DlnA(i)=[sqrt(sum(a(alap)).^2)-sqrt(sum(b(blap).^2))]...
            /sqrt(sum(b(blap).^2));
end
