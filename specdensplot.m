function [p,xl,yl]=specdensplot(x,nfft,Fs,lwin,olap)
% Plots spectral density of some data contained in vector x.
%
% x        Signal
% nfft     Number of FFT points
% Fs       Sampling frequency
% lwin     Window length
% wolap    Window overlap
%
% Used by SIGNALS and SIGNALS2; using PCHAVE; see also
% TIMDOMPLOT, TIMSPECPLOT
%
% Last modified by fjsimons-at-alum.mit.edu, 18.11.2004

[SD,F,Ulog,Llog]=pchave(x,lwin,olap,nfft,Fs);
p(2)=semilogx(F,10*log10(Ulog)); hold on
p(3)=semilogx(F,10*log10(Llog)); 
p(1)=semilogx(F,10*log10(SD)); 
p(4)=semilogx(F(1:10),10*log10(SD(1:10)),'+'); hold off
xlim([F(1) F(end)]);

% Note that \Delta F is the first frequency to actually show up in the plot
xl=xlabel(sprintf('%s ; %i s window','Frequency (Hz)',ceil(lwin/Fs)));
yl=ylabel(sprintf('%s %5.2f',...
		     'Spectral Density (Energy/Hz) ; \Delta\itf=',...
		     Fs/nfft));
mima=[F(2) F(end)];
poslab=10.^[-3:3];
set(gca,'Xtick',poslab(poslab>=mima(1) & poslab<=mima(2)));
