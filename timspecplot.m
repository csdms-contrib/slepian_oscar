function [p,xl,yl,bm,Bl10,F,T]=timspecplot(x,h,nfft,Fs,wlen,wolap,beg)
% [p,xl,yl,bm,Bl10,F,T]=TIMSPECPLOT(x,h,nfft,Fs,wlen,wolap,beg)
%
% Plots spectrogram of data using the SPECTROGRAM algorithm
%
% INPUT:
% 
% x        Signal - the actual data, e.g. from readsac
% h        Header - the variables, e.g. from readsac
% nfft     Number of FFT points
% Fs       Sampling frequency
% wlen     Window length
% wolap    Window overlap
% beg      Signal beginning - actually, can get this from h
%
% Used by SIGNALS and SIGNALS2, see also
% TIMDOMPLOT, SPECDENSPLOT
%
% Last modified by fjsimons-at-alum.mit.edu, 25.11.2004

% This is the calculation; the rest is plotting
[Ba2,F,T,Bl10]=spectrogram(x,nfft,Fs,wlen,ceil(wolap*wlen));

% Conform to PCHAVE, SPECTRAL DENSITY, NOT POWER
p=imagesc(beg+wlen/Fs/2+T,F,Bl10);
axis xy; colormap(jet)    
xlabs=sprintf('%s ; %3.1f s window','Time (s)',wlen/Fs);
yl=ylabel(sprintf(...
    '%s ; fN %5.1f ; fR %6.2e','Frequency (Hz)',...
    Fs/2,Fs/wlen));

ifisayso=0;
if h.T0~=-12345 & h.T1~=-12345 & ifisayso==1
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
xl=xlabel(xlabs);

