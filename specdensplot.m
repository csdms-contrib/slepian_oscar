function varargout=specdensplot(x,nfft,Fs,lwin,olap,sfax,unt)
% [p,xl,yl,F,SD,Ulog,Llog]=SPECDENSPLOT(x,nfft,Fs,lwin,olap,sfax,unt)
%
% Plots spectral density of data calculated using the PCHAVE algorithm.
%
% INPUT:
% 
% x        Signal
% nfft     Number of FFT points [default: lwin]
% Fs       Sampling frequency
% lwin     Window length, in samples [default: 256]
% olap     Window overlap, in percent [default: 70]
% sfax     Y-axis scaling factor [default: 10]
% unt      String with the unit name [default: s]
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
% SD       The power spectral density being plotted
% Ulog     The upper uncertainty range being plotted
% Llog     The lower uncertainty range being plotted
%
% SEE ALSO:
% 
% SIGNALS, SIGNALS2, TIMDOMPLOT, TIMSPECPLOT
%
% Last modified by fjsimons-at-alum.mit.edu, 08/02/2012

defval('lwin',256)
defval('nfft',lwin)
defval('olap',70)
defval('sfax',10)
defval('unt','s')

% This is the calculation; the rest is plotting
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
if strcmp(unt,'s')
  xfreq='frequency (Hz)';
  yfreq='spectral density (energy/Hz)';
else
  xfreq=sprintf('frequency (%s^{-1})',unt);
  yfreq=sprintf('spectral density (energy %s %s)','\times',unt);
end
xl=xlabel(sprintf('%s ; %g %s window',xfreq,lwin/Fs,unt));
yl=ylabel(sprintf('%s ; %s = %5.2f',yfreq,'\Delta\itf',Fs/nfft));
mima=[F(2) F(end)];
poslab=10.^[-3:3];
set(gca,'Xtick',poslab(poslab>=mima(1) & poslab<=mima(2)));

% Provide output of what's being plotted exactly
vars={p,xl,yl,F,sfax*log10(SD),sfax*log10(Ulog),sfax*log10(Llog)};
varargout=vars(1:nargout);
