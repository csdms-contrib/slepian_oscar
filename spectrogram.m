function [Ba2,F,T,Bl10]=spectrogram(x,nfft,Fs,wlen,olap);
% [Ba2,F,T,Bl10]=spectrogram(x,nfft,Fs,wlen,olap);
%
% Computation of TIME-DEPENDENT SPECTRAL DENSITY (UNIT^2/HZ)
% by Welch's overlapping segment analysis with a Hanning window.
%
% INPUT:
%
% x        Real-valued signal to be analyzed
% nfft     Number of frequencies calculated (default: 256)
% Fs       Sampling frequency (Hz) used only for output scaling (default: 1)
% wlen     Length of windowed segment, in samples, which must be
%          smaller than or equal to 'nfft' and larger than 'olap'
%          (default: 256)
% olap     Overlap of data segments, in samples (default: 70)
%
% OUTPUT: 
%
% Ba2      Each column of Ba2 contains an estimate of the short-term, 
%          time-localized spectral density of the signal. (UNITS^2/HZ)
%          Time increases linearly across the columns of Ba2, from left to
%          right. Frequency increases linearly down the rows, starting
%          at 0. Ba2 is a real matrix with k columns, where
%          k = floor((length(x)-olap)/(wlen-olap)), and a number of rows
%          equal to nfft/2+1 if 'x' is real and 'nfft' even, 
%          and (nfft+1)/2 for 'x' is real and 'nfft' odd.
%          Note that our Ba2 is abs(fft(x).^2)/Fs.
% F        Frequency axis (Hz)
% T        Time axis (s), starting from zero
% Bl10     10*log10(Ba2)
%
% See also PCHAVE
%
% EXAMPLE:
%
% Plot the results with, e.g.: 
%
% IMAGESC(h1.B+wlen/Fs/2+T,F,Bl10);
%
% BUT WATCH THE TIME IN CASE THE SIGNAL DOES NOT START AT ZERO!
%
% Last modified by fjsimons-at-alum.mit.edu, 09/25/2007

defval('wlen',256)
defval('olap',70)
defval('nfft',256)
defval('Fs',1)

if nfft>wlen
  disp(sprintf('SPECTROGRAM: NFFT of %i is larger than window length of %i',...
	       nfft,wlen))
end
if nfft<wlen
  error('SPECTROGRAM: NFFT is smaller than window length; increase resolution?')
end
if olap>=wlen,
  error('Overlap must be strictly smaller than window length')
end

disp(sprintf('Window size for spectrogram:    %8.1f s',wlen/Fs))

% WELCH OVERLAPPING SEGMENT ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute Hanning window
dwin=fhanning(wlen);

% Normalize window so the sum of squares is unity (PW 208a)
dwin=dwin/sqrt(dwin'*dwin);

% Determine window parameters and truncation of data set
npts=length(x);
eflen=wlen-olap;
checkit=(npts-olap)/eflen;
nwin=floor(checkit);
disp(sprintf('Number of overlapping data segments: %i',nwin))   
if nwin~=checkit
  disp(sprintf(...
      'Number of  segments is not  integer: %i / %i points truncated',...
      npts-(nwin*eflen+olap),npts))
end
if nwin<=0; error('Data sequence not long enough'); end
  
% Make matrix out of suitably repeated windowed segments 
% of the data 'xsdw' is x segmented THEN detrended THEN 
% windowed with normalized window
rows=[1:wlen];
cols=[0:(nwin-1)]*eflen;
xsd=detrend(...
    x(repmat(rows(:),1,nwin)+...
      repmat(cols,wlen,1)));
xsdw=xsd.*repmat(dwin,1,nwin);
% This in case it's a boxcar window!
% xsdb=xsd/sqrt(wlen);

% Calculate POWER SPECTRAL DENSITY (power per frequency)
Ba2=abs(fft(xsdw,nfft,1)).^2;
% Next thing is the SPECTRAL DENSITY (energy per frequency) thus
% in UNITS^2/HZ or UNITS^2*SECOND
Ba2=Ba2/Fs;

% Collect frequency information and select output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate frequency vector for REAL signals
% and get rid of periodicity in spectrum
if rem(nfft,2);
  selekt = [1:(nfft+1)/2];
else
  selekt = [1:nfft/2+1]; 
end
F=(selekt-1)'*Fs/nfft;

% Calculate time axis; cols is the sample number
T=cols(:)/Fs;

% Need to scale frequencies except 0 and Nyquist by a factor of two
% if you only take half of the spectrum (for real signals)
% Compute one-sided spectrum (Bendat and Piersol Eq. 5.33 and page 424.)
Ba2=Ba2(selekt,:);
Ba2=[Ba2(1,:); 2*Ba2(2:end-1,:); Ba2(end,:)]; 
Bl10=10*log10(Ba2);

