function [p,xl,yl,bm,Bl10,F,T]=timspecplot(x,h,nfft,Fs,wlen,wolap,beg,unt)
% [p,xl,yl,bm,Bl10,F,T]=TIMSPECPLOT(x,h,nfft,Fs,wlen,wolap,beg,unt)
%
% Plots spectrogram of data using the SPECTROGRAM algorithm and maybe,
% performs an analysis of it using BFT.  
%
% INPUT:
% 
% x        Signal - the actual data, e.g. from READSAC
% h        Header - the variables, e.g. from READSAC
% nfft     Number of FFT points [default: wlen]
% Fs       Sampling frequency
% wlen     Window length, in samples [default: 256]
% wolap    Window overlap, as a fraction [default: 0.7]
% beg      Signal beginning - actually, can get this from h
% unt      String with the unit name [default: s]
%
% OUTPUT:
%
% p,xl,yl  Various axis handles
% bm       A quality label from BFT, if so requested
% Bl10     What's plotted, 10*log10(Ba2) with Ba2 the spectral density
% F        Frequency axis (1/unt, which is Hz by default)
% T        Time axis (unt), starting from zero
%
% Used by SIGNALS and SIGNALS2, see also
% TIMDOMPLOT, SPECDENSPLOT
%
% Last modified by fjsimons-at-alum.mit.edu, 08/02/2012

defval('beg',0)
defval('wlen',256)
defval('nfft',wlen)
defval('wolap',0.7)
defval('unt','s')

% This is the calculation; the rest is plotting
[Ba2,F,T,Bl10]=spectrogram(x,nfft,Fs,wlen,ceil(wolap*wlen),unt);

% Conform to PCHAVE, SPECTRAL DENSITY, NOT POWER
p=imagesc(beg+wlen/Fs/2+T,F,Bl10);
axis xy; colormap(jet)    

% Labeling
xfreq=sprintf('time (%s)',unt);

if strcmp(unt,'s')
  yfreq='frequency (Hz)';
  tlabs='spectral density (energy/Hz)';
else
  yfreq=sprintf('frequency (%s^{-1})',unt);
  tlabs=sprintf('spectral density (energy %s %s)','\times',unt);
end

xlabs=sprintf('%s ; %g %s window',xfreq,wlen/Fs,unt);
ylabs=sprintf('%s ; fN %5.1f ; fR %6.2e',yfreq,...
	    Fs/2,Fs/wlen);

% Analysis; cut this out altogether if this isn't relevant
ifisayso=0;
if ifisayso==1 &&  h.T0~=-12345 && h.T1~=-12345
  hold on
  yli=ylim;
  pt01=plot(repmat([h.T0 h.T1],2,1),[yli(1) yli(2)],'k--');
  hold off
  % Also now do the analysis on the window
  [bm,SN]=bft(Bl10,F,h.B+wlen/Fs/2+T,h.T0,h.T1);
  xlabs=sprintf('%s ; %3.1f s window, SN %5.1f','Time (s)',...
		wlen/Fs,SN(1));
else
  bm=[];
end

% Put the labels on
xl=xlabel(xlabs);
yl=ylabel(ylabs);
tl=title(sprintf('%s ; window size %g %s ; overlap %g %s ',...
	tlabs,wlen/Fs,unt,ceil(wolap*wlen)/Fs,unt));
