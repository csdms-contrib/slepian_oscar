function [B,F,T]=spectrogram(x,nfft,Fs,wlen,olap);
% [B,F,T]=spectrogram(x,nfft,Fs,wlen,olap);
%
% Computation of TIME-DEPENDENT SPECTRAL DENSITY (UNIT^2/HZ)
% by Welch's overlapping segment analysis with a Hanning window.
%
% INPUT:
%
% 'x'        Signal to be analyzed
% 'nfft'     Number of frequencies calculated
% 'Fs'       Sampling frequency (Hz) used only for output scaling
% 'wlen'     Length of windowed segment, in samples, which must be
%            smaller than or equal to 'nfft' and larger than 'olap'
% 'olap'     Overlap of data segments, in samples
%
% OUTPUT: 
%
% 'B'        Each column of B contains an estimate of the short-term, 
%            time-localized spectral density of the signal. (Units^2/Hz)
%            Time increases linearly across the columns of B, from left to
%            right. Frequency increases linearly down the rows, starting
%            at 0. B is a real matrix with k columns, where
%            k = floor((length(x)-olap)/(wlen-olap)), and a number of rows
%            equal to nfft/2+1 if 'x' is real and 'nfft' even, 
%            and (nfft+1)/2 for 'x' is real and 'nfft' odd.
%            You'll want to investigate 10*log10(B).
%            Note that our B is abs(B.^2) of Matlab's usual convention.
% 'F'        Frequency axis (Hz)
% 'T'        Time axis (s)
%
% See also PCHAVE
%
% Last modified by fjsimons@alum.mit.edu, March 21th, 2003.

defval('wlen',256)
defval('olap',70)
defval('nfft',256)
defval('Fs',1)

if nfft>wlen
  disp('NFFT is larger than window length')
end
if nfft<wlen
  error('NFFT is smaller than window length')
end
if olap>=wlen,
  error('Overlap must be strictly smaller than window length')
end

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
xsdb=xsd/sqrt(wlen);

% Calculate POWER SPECTRAL DENSITY (power per frequency)
B=abs(fft(xsdw,nfft,1)).^2;
% Next thing is the SPECTRAL DENSITY (energy per frequency) thus
% in UNITS^2/HZ or UNITS^2*SECOND
B=B/Fs;

% Collect frequency information and select output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate frequency vector for real signals
% and get rid of periodicity in spectrum
if rem(nfft,2);
  selekt = [1:(nfft+1)/2];
else
  selekt = [1:nfft/2+1]; 
end
F=(selekt-1)'*Fs/nfft;

% Calculate time axis
T=cols(:)/Fs;

% Need to scale frequencies except 0 and Nyquist by a factor of two
% if you only take half of the spectrum (for real signals)
% Compute one-sided spectrum (Bendat and Piersol Eq. 5.33 and page 424.)
B=B(selekt,:);
B=[B(1,:); 2*B(2:end-1,:); B(end,:)]; 

