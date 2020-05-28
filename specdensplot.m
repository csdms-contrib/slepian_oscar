function [p,xl,yl,F]=specdensplot(x,nfft,Fs,lwin,olap,sfax)
% [p,xl,yl,F]=SPECDENSPLOT(x,nfft,Fs,lwin,olap,sfax)
%
% Plots spectral density of data using the PCHAVE algorithm
%
% INPUT:
% 
% x        Signal
% nfft     Number of FFT points
% Fs       Sampling frequency
% lwin     Window length
% wolap    Window overlap
% sfax     Scaling factor [default: 10]
%
% OUTPUT:
%
% p        The axis handles to the various lines plotted
%          1 the spectral density as a line
%          2 the upper uncertainty interval
%          3 the lower uncertainty interval
%          4 the spectral density, i.e. the first set of 10 points
% xl       The handle to the x-label
% yl       The handle to the y-label
% F        The frequencies being plotted
%
% Used by SIGNALS and SIGNALS2
% See also TIMDOMPLOT, TIMSPECPLOT
%
% Last modified by fjsimons-at-alum.mit.edu, 10/03/2007

defval('sfax',10)
defval('lwin',256)
defval('olap',70)

% This is the calculation
[SD,F,Ulog,Llog]=pchave(x,lwin,olap,nfft,Fs);

% The rest is simply for plotting cosmetically
p(2)=semilogx(F,sfax*log10(Ulog)); hold on
p(3)=semilogx(F,sfax*log10(Llog)); 
p(1)=semilogx(F,sfax*log10(SD)); 
p(4)=semilogx(F(1:10),sfax*log10(SD(1:10)),'+'); hold off
xlim([F(1) F(end)]);

% Note that F(0) isn't really zero but rather something like the data
% length itself - SD(1) is not shown but sort of a logical extension of
% the plot, nothing funny should happen...

% Note that \Delta F is the first frequency to actually show up in the plot
xl=xlabel(sprintf('%s ; %i s window','Frequency (Hz)',ceil(lwin/Fs)));
yl=ylabel(sprintf('%s %5.2f',...
		     'Spectral Density (Energy/Hz) ; \Delta\itf=',...
		     Fs/nfft));
mima=[F(2) F(end)];
poslab=10.^[-3:3];
set(gca,'Xtick',poslab(poslab>=mima(1) & poslab<=mima(2)));
