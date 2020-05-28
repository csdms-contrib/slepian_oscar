function varargout=pchave(X,lwin,olap,nfft,Fs,dval,winfun,winopt,clev) 
% [SD,F,Ulog,Llog,Ulin,Llin,Snon,Qnon,Qrob,Qchi]=...
%     PCHAVE(X,lwin,olap,nfft,Fs,dval,winfun,winopt,clev)
%
% Computation of SPECTRAL DENSITY (UNIT^2/HZ) with the method of CHAVE (1987).
%
% INPUT:
%
% X        Cell array with data SECTIONS, each of which will be SEGMENTed
% lwin     Length of windowed segment, in samples [default: 256]
% olap     Overlap of data segments, in percent [default: 70]
% nfft     Number of frequencies [default: 256]
% Fs       Sampling frequency (Hz) [default: 1]
% dval     'MAD' for Mean Absolute Deviation scale estimate (Chave Eq. 20)
%          'IQ'  for InterQuartile scale estimate (Chave Eq. 21)
% winfun   Window function name (string) [default: 'DPSS']
% winopt   Window function parameter, such as the time-bandwidth product
%            for DPSS [Default: NW=4 and only first taper used]
% clev     Is the confidence level in percent for the uncertainties
%            under the jackknifing error estimation [default: 95]
%
% OUTPUT: 
%
% SD       Robust estimate of SPECTRAL DENSITY (UNIT^2/Hz) [abs(fft(X).^2)]
% F        Frequency axis, goes from Fs/lwin to Fs/2 in nfft steps
% Ulog     Upper confidence limit for use in logscale
% Llog     Lower confidence limit for use in logscale
% Ulin     Upper confidence limit for use on linear scale
% Llin     Lower confidence limit for use on linear scale
% Snon     Non-robust estimate for comparison only
% Qnon     Order statistic for the non-robust spectral density
% Qrob     Order statistic for the robust spectral density
% Qchi     Order statistic for the chi2(2) distribution
%
% Returns ROBUST and NONROBUST spectral estimates and FREQUENCIES
% for REAL signals contained in a cell array. Assumed is all cells
% are from the same stochastic process. Each SECTION will be SEGMENTED
% in overlapping windows and TAPERED with a DPSS. Starting from an 
% initial LOCATION and SCALE estimate, iterations are performed to 
% come up with more ROBUST estimates for the ensemble over all SEGMENTS
% and SECTIONS. The NONROBUST spectral average is just the mean.
%
% See also: SPECTROGRAM

% Reference: 
%
% @Article{Chave+87,
%  author = 	 "Alan D. Chave and David J. Thomson and Mark E. Ander",
%  title = 	 "On the robust estimation of power spectra,
%		  coherences, and transfer functions",
%  journal =	 JGR,
%  year =	 1987,
%  volume =	 92,
%  number =	 "B1",
%  pages =	 "633--648"
% }
%
% Last modified by fjsimons-at-alum.mit.edu, 12/18/2013


% The program, not the demo (see at the end)
if ~isstr(X)
defval('lwin',256)
defval('olap',70)
defval('nfft',256)
defval('Fs',1)
defval('winfun','dpss')
defval('dval','MAD')
defval('clev',95)

if ~iscell(X)
  y=X;
  clear X
  X{1}=y;  
end

if nfft>lwin
  warning('PCHAVE: NFFT is larger than window length')
end

% PART  I: WELCH OVERLAPPING SEGMENT ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Overlap in samples
olap=floor(olap/100*lwin);
% Compute window; if 'DPSS' use option or default option,
% and want only one taper
if strcmp(winfun,'dpss')
  defval('winopt',4)
  dwin=feval(winfun,lwin,winopt,1);
else % If not, only at most one option allowed or needed
  if exist('winopt')
    dwin=feval(winfun,lwin,winopt);
  else
    dwin=feval(winfun,lwin);
  end
end

% Normalize window so the sum of squares is unity (PW 208a)
dwin=dwin/sqrt(dwin'*dwin);

% Start of the loop over the elements of cell X
% Initialize Power Spectral Density matrix with window 
Pw=[];
for index=1:length(X)
  x=X{index}(:);
  npts=length(x);
  % If npts equals lwin any amount of overlap still only produces one
  % window 
  checkit=(npts-olap)/(lwin-olap);
  nwin=floor(checkit);

  disp(sprintf('Window size for spectral density: %8.1f',lwin/Fs))

  disp(sprintf('Number of overlapping data segments: %i',nwin))   
  if nwin~=checkit
    disp(sprintf(...
	'Number of  segments is not  integer: %i / %i points truncated',...
	 npts-(nwin*(lwin-olap)+olap),npts))
  end
  if nwin<=1; error('Data sequence not long enough'); end
  
  % Make matrix out of suitably repeated windowed segments 
  % of the data 'xsdw' is x segmented THEN detrended THEN 
  % windowed with normalized window
   xsd=detrend(...
      x(repmat([1:lwin]',1,nwin)+...
	repmat([0:(nwin-1)]*(lwin-olap),lwin,1)));
  xsdw=xsd.*repmat(dwin,1,nwin);
  % Check segmented THEN detrended THEN windowed 
  % with normalized boxcar window  
  xsdb=xsd/sqrt(lwin);
  % Fill power matrix up progressively - initialization would speed this up
  Pw=[Pw (abs(fft(xsdw,nfft,1)).^2)];
  % For this cell section, compare with the boxcar version
  Pb=abs(fft(xsdb,nfft,1)).^2;
  % You can verify Percival and Walden (Eq. 134):
  % $\var\{x\}=\int_{-f_N}^{f_N}S(f)\,df$ by checking var(x) against
  % sum(mean(Pb,2))*(Fs/nfft) which equals mean(mean(Pb,2))*Fs
  % or of course mean(mean(Pb,2)) - if you've used a boxcar.
  % This checks how closely the total variance of x is captured
  % by the overlapping detrended boxcar windowing scheme.
  % Variations are due to taper forms, overlap, etc.
  % This is why you better don't compare absolute values of the 
  % spectral density, but normalize them on a decibel scale
  %  disp(sprintf(...
  %      'Parseval check: %8.3e (time) vs %8.3e (frequency)',...
  %      var(x(1:nwin*(lwin-olap)+olap)),mean(Pb(:))))
end

% Total number of estimates available
nwint=size(Pw,2);

% P is the POWER SPECTRAL DENSITY or the ENERGY/SECOND/FREQUENCY
% Units of ENERGY thus UNIT^2
% S=P*Dt=P/Fs is the SPECTRAL DENSITY or ENERGY/FREQUENCY
% So that its integral over all frequencies int(S(f)df) equals variance
% Units are UNIT^2/HZ or UNITS^2*SECOND
% Note that the area in frequency space is given by 2*fN, which is 1/Dt
Sw=Pw/Fs;
% PART II: Chave's method of making the estimate robust (PW p 294)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End up with a bunch of modified periodograms per segment and per 
% section in the cell array. Now Chave tells us how to average these.

% First start with the median as an initial robust LOCATION estimate
% The non-robust is just the unweighted average (the mean)
Snon=mean(Sw,2);
Sloc=median(Sw,2);
SD=zeros(size(Sloc));

% I'm doing the iteration for all frequencies at the same time
% Could rewrite this for every frequency at once
% Convergence criterion for all frequencies at once based on
% relative difference wrt previous iteration in percent
relperc=1;
iter=0;
while any(abs(SD-Sloc)./Sloc*100>relperc) & iter<=499
  disp(sprintf('Iteration %3.3i mandated by %3.3i / %3.3i frequencies',...
	       iter+1,sum(abs(SD-Sloc)./Sloc*100>relperc),length(SD)))
  if iter>0; Sloc=SD; end
  iter=iter+1;  
  % Now come up with a "practical" but "lower efficiency" SCALE estimate
  % Calculate residuals from the location estimate
  Sres=Sw-repmat(Sloc,1,size(Sw,2));
  if strcmp(upper(dval),'MAD')
    % Scale estimate is median absolute deviation of residual from
    % the median over value expected for a chi-squared distribution
    % with 2 degrees of freedom (Chave Eq. 20 and Eq. 30)
    % This is because power spectra are the sums of squares of almost
    % normally distributed variates, and hence distributed as
    % chi-squared. The number of degrees of freedom is 2 at each
    % frequency, except for the DC and Nyquist components, which have
    % only 1 degree of freedom. The chi-squared 2-distribution is
    % equivalent to the exponential distribution and thus easy to
    % calculate. We compare the scale estimates to the chi-squared
    % 2-distribution and use this as our estimate of scale.
    Sscale=median(abs(Sres),2)/(2*asinh(1/2));
  elseif strcmp(upper(dval),'IQ')
    % Scale estimate is interquartile range of residuals over expected
    % value for chi-squared distribution with 2 degrees of freedom
    % (Chave Eq. 21 and Eq. 30)
    for index=1:nfft
      Sscale(index,1)=iqr(Sres(index,:))/(2*log(3));
    end
  end

  % Now iterate with Huber weights (Chave Eq. 26)
  % How far out are the residuals in multiples of the scale estimate?
  % Use these to construct weights - far out values are downweighted
  % This number is given by Huber and assures the efficiency of the estimate
  k=1.5;
  Wght=Sres./repmat(Sscale,1,nwint);
  buv=Wght>k;
  blo=Wght<=k;
  Wght(buv)=sqrt(k*sign(Wght(buv))./Wght(buv));
  Wght(blo)=1;

  % Construct robust estimate as weighted average of segments - in one go
  % This is the new LOCATION estimate
  SD=sum(Wght.*Sw,2)./sum(Wght,2);
  %  plot(abs(SD-Sloc)./Sloc*100); pause
end

% Part III: QUALITY CONTROL ON THE WEIGHTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If the weighting has been performed correctly, then the final
% quantile-quantile plot of the weighted spectral estimates ('wse')
% (except those with zero weights - but this doesn't happen with the
% Huber weights ) against the chi-square quantiles. Also calculate the
% same statistic for the unweighted (nonrobust) spectral estimates 
% ('use'). Return their rank.
[use,user]=sort((Wght.*Sw)./repmat(sum(Wght,2),1,nwint),2);
[wse,wser]=sort(Sw,2);

% Scale to have sum of squares of 8, which is the expected raw second
% moment of a chi2(2) variate.  
Qnon=use.*repmat(sqrt(8./sum(use.^2,2)),1,nwint)*sqrt(nwint);
Qrob=wse.*repmat(sqrt(8./sum(wse.^2,2)),1,nwint)*sqrt(nwint);

% Compare with the quantiles of the chi2(2) distribution
% You think with the reweighting your measures should follow this
% distribution and if they do their order statistics would plot on a
% straight line compared to Qchi.
Qchi=2*log(nwint./(nwint-[1:nwint]+0.5));

% PART  IV: JACKKNIFE STATISTICS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See Efron and Stein, 1981
% Note that BOOTSTRAP is apparently even more efficient
% See also Efron, 1979
% Loop over frequencies

% Get number of standard deviations out to attain confidence level
% Start with some precomputed values
switch clev
 case 99
  kcon=2.5759;
 case 95
  kcon=1.96;
 case 68
  kcon=0.9945;
 otherwise
  kcon=norminv(1-(1-clev/100)/2,0,1);
end
disp(sprintf('Error bounds reflect confidence level of %5.1f%s',...
	     (1-2*(1-normcdf(kcon,0,1)))*100,str2mat(37)))

for index=1:nfft
  % Work with Sw and Wght
  S=Sw(index,:);
  W=Wght(index,:);
  % Make jackknifing sampler
  J=jackknife(nwint);
  % Compute S(i) in Efron's notation:
  % Now it's like you have more than one estimation of SD
  Si=sum(S(J).*W(J),2)./sum(W(J),2);
  % Compute S(.) in Efron's notation
  % It's like taking the mean of your new estimates
  Sdot=mean(Si);
  % Compute Efron's jackknifing variance
  % This is like the variance of the mean of the new estimates
  % "perhaps more appropriately" so - but we think of it as the 
  % variance on the estimate SD itself; adjusted for sample size
  varjkS=(nwint-1)/nwint*sum((Si-Sdot).^2);
  % Jackknife standard deviation of the estimate SD
  stdjkS=sqrt(varjkS);
  % Then you assume that you've obtained the value under a normal
  % distribution and hence
  % clev in percent falls within +/- kcon times the stdev
  errlin(index,1)=kcon*(stdjkS);
  % Also make errors for natural logscale
  Silog=log(Si);
  Sdotlog=mean(Silog);
  varjkSlog=(nwint-1)/nwint*sum((Silog-Sdotlog).^2);
  errlog(index,1)=exp(kcon*sqrt(varjkSlog));
end

% Note that:
% decibel(Ulog)-decibel(SD) is equal to decibel(SD)-decibel(Llog)
% whereas
% Ulin-SD is equal to SD-Llin
Ulin=SD+errlin;
Llin=SD-errlin;
Ulog=SD.*errlog;
Llog=SD./errlog;

% PART  V: Collect frequency information and select output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate frequency vector for real signals
% and get rid of periodicity in spectrum
selekt=[1:floor(nfft/2)+1];
F=(selekt-1)'*Fs/nfft;

Snon=Snon(selekt);
SD=SD(selekt);
Ulin=Ulin(selekt);
Llin=Llin(selekt);
Ulog=Ulog(selekt);
Llog=Llog(selekt);

% Need to scale frequencies except 0 and Nyquist by a factor of two
% if you only take half of the spectrum (for real signals)
% Compute one-sided spectrum (Bendat and Piersol Eq. 5.33 and page 424.)
Snon=[Snon(1); 2*Snon(2:end-1); Snon(end)]; 
SD=[SD(1); 2*SD(2:end-1); SD(end)]; 
Ulin=[Ulin(1); 2*Ulin(2:end-1); Ulin(end)]; 
Llin=[Llin(1); 2*Llin(2:end-1); Llin(end)];
Ulog=[Ulog(1); 2*Ulog(2:end-1); Ulog(end)]; 
Llog=[Llog(1); 2*Llog(2:end-1); Llog(end)];

% Provide output
vars={SD,F,Ulog,Llog,Ulin,Llin,Snon,Qnon,Qrob,Qchi};
varargout=vars(1:nargout);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demos
elseif isstr(X)
  pchavedemo(X);
end
