function varargout=mhpsd(diro,index,ah,xver)
% [xl,yl,axx]=MHPSD(diro,index,ah,xver)
%
% A wrapper around READMHPSD to make a nice figure
%
% INPUT:
%
% diro      Directory name
% index     A file index
% ah        The axis handle
% xver      1 Prints the figure
%
% OUTPUT:
%
% xl,yl     Handles to the axis labels
% axx       Handle to the period axis
%
% Last modified by fjsimons-at-alum.mit.edu, 02/11/2024

defval('diro','/data1/fjsimons/MERMAID/processed-stanford/465.152-R-0001/20211012-11h58m55s')

% Find all the files
files=ls2cell(fullfile(diro,'*mhpsd'),1);
% Pick just one of them
defval('index',round(rand*length(files)))
% Work out the name of what you are plotting
zname=pref(suf(files{index},'/'));
% Pick out the right axis
defval('ah',gca)
% Print or not
defval('xver',0)

% Load and plot
[hdr,psd]=readmhpsd(files{index});

axes(ah)
p(1)=semilogx(psd.freq,psd.perc50);
hold on
p(2)=semilogx(psd.freq,psd.perc95);
hold off
grid on


xl1=xlabel(sprintf('%s | frequency (Hz)',zname));
yl1=ylabel('power (Hz)');

% Cut off
set(ah,'xlim',[1/floor(1/psd.freq(2)) 10])
set(ah,'ylim',[-120 -40],'ytick',[-120 -80 -40])
% Label explicitly
set(ah,'Xtick',[0.1 1 10])

set(ah,'box','off')
   
% Shrink the axes
shrink(ah,1,2)

% Plot the period axes on top
[axx,xl2,yl2]=xtraxis(ah,[0.1 1 10 floor(1/psd.freq(2))],[0.1 1 10 floor(1/psd.freq(2))],'period (s)');
set(axx,'Xdir','rev','xlim',[0.1 floor(1/psd.freq(2))])

longticks([ah axx])
% Print the plot
if xver==1
    figdisp(mfilename,zname,[],2)
end

% Optional output
varns={xl1,yl1,axx};
varargout=varns(1:nargout);
