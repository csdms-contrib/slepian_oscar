function mcms2mat(yyyy,mm,dd,HH,MM,SS,qp,pdf)
% MCMS2MAT(yyyy,mm,dd,HH,,MM,SS,qp,pdf)
%
% Quick look at the Meridian Compact PH instrument on PU Campus
% Assumes a directory structure with MINISEED data, will combine
% components, perform instrument correction, and save as MAT files. 
%
% INPUT:
%
% yyyy     Single year, e.g. 2015 [default]
% mm       Single month, e.g. 10 [default]
% dd       Single day, e.g. 13 [default]
% HH       Hour[s], e.g. 0 or 00 or [1 2] [default: 0:23]
% MM       Minute [default: 00]
% SS       Second [default: 00]
% qp       Quick plots as we go along [default: 1 for yes]
% pdf      Quick pdf print as we go along [default: 1 for yes]
%
% USAGE:
%
% Input could be very detailed about a single specific yyyymmddHHMMSS
% or leave the minutes and seconds, or even hours, out of it altogether
% and it will apply to all available files, assuming hourly chunks.
%
% Last modified by fjsimons-at-alum.mit.edu, 05/15/2016

% If future-timing problem perhaps "touch" all the files before going in?

% FIXED STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Data directory under which the yyyy/mm/dd directories are kept
diro='/u/fjsimons/CLASSES/FRS-Spain/SensorData/MeridianCompactPH/';

% Default directory where the EPS files will go, best to set your own 'EPS'
setenv('EPS',getenv('EPS'))

% Hard things such as our station, channel, instrument name etc
STA='S0001';
CHA='HH%s';
DEV='MC-PH1_0248';
% Set of components we should be expecting for our miniseed files
cmp={'X' 'Y' 'Z'};

% Generic format of the MINISEED and MAT file names in those directories
msfmt=sprintf('%s.%s_%s_%s.%s',STA,CHA,DEV,'%s','%s');
% Generic SAC pre-format expected, might have to do it to find out
scfmt=sprintf('.%s..%s.%s.%s.%s.%s.SAC',STA,CHA,'D','%i','%i','%s');
    
% INPUT STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Defaults for the dates for which we have a data directory
defval('yyyy',2015)
defval('mm',10)
defval('dd',13)
% Set of hours we should be expecting for our miniseed files
defval('HH',0:23)
% Minutes and seconds that we expect these to start at
defval('MM',0)
defval('SS',0)
% Make plots perhaps
defval('qp',1)
defval('pdf',1)

% Collect the Julian date already as it will be needed later
juld=ceil(datenum(yyyy,mm,dd)-datenum(yyyy,00,00));
% SAC file pre-format expected by the conversion via MSEED2SAC
sacfmt=sprintf(scfmt,'%s',yyyy,juld,'%s');

% Input reply default
defval('reply','y')

% GENERIC STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Detailed-level data directory where we should be looking for data
dirx=fullfile(diro,datestr(datenum(yyyy,mm,dd),'yyyy/mm/dd'));

% For all hours requested, or all hours available if none too specific
for index=1:length(HH)
  % What does the calendar say in numeric date format?
  dnum=datenum(yyyy,mm,dd,HH(index),MM,SS);
  % Appendages of the file format
  dst1=datestr(dnum,'yyyymmdd_HHMMSS');
  dst2=datestr(dnum,'HHMMSS');
  % Make the MAT FILENAME that will collect ALL of the components
  mtx=fullfile(dirx,sprintf(msfmt,'A',dst1,'mat'));
  
  % Make a plot if requested, in the current figure window
  if qp==1
    clf; [ah,ha,H]=krijetem(subnum(3,1));
    fig2print(gcf,'landscape')
  end
  % For all components available
  for ondex=1:length(cmp)
    % Make the MINISEED FILENAME with the precise time in it now also
    msx=fullfile(dirx,sprintf(msfmt,cmp{ondex},dst1,'miniseed'));
    % Used for titles and plot names
    mss=nounder(suf(msx,'/'),'\_');
    epsname=sprintf('%seps',pref(suf(msx,'/'),'miniseed'));
    pdfname=sprintf('%spdf',pref(suf(msx,'/'),'miniseed'));
    % Better test that the MINISEED exists as a filename
    if exist(msx,'file')==2
      % How about we convert this to SAC even temporarily
      system(sprintf('mseed2sac %s',msx));
      % Now to the SAC FILENAME that we expect to have been created
      sax=fullfile(pwd,sprintf(sacfmt,cmp{ondex},dst2));
      if exist(sax,'file')~=2
	disp(sprintf('%s not found',sax)); 
        % What did it create last? Start timing could have been updated
        % in the title. But note that 'last' means all other times are past
	d=dir(pwd); [ds,n]=sort([d(:).datenum]);
	sax=d(n(length(n))).name;
	% We most likely want to go along with the file that it did create
	reply=input(sprintf('%s found, continue with that [Y/N] or skip? ',sax),'s');
	if strcmp(lower(reply),'n'); continue; end
      end
      % Instrument response deconvolution? Header update in that case;
      % filename update also above, to do!
      % If plotting, get ready
      if qp==1; axes(ah(ondex)); end
      % Redefine sax again then READSAC and collect components
      [s{ondex},h{ondex},t{ondex},p{ondex}]=readsac(sax,qp);
      % If plotting, finish up with underscores in the title as needed
      if qp==1
	set(t{ondex},'string',mss);
	p{ondex}(3)=ylabel(cmp{ondex});
      end
      % Remove the temporary SAC files
      system(sprintf('rm %s',sax));
      % Preserve the ability to make the plot
      nix=1;
    else
      disp(sprintf('%s not created thus no further action',msx));
      % In that case you won't be making a plot either
      nix=0;
    end
  end
  % If plotting clean up; will need provision if only one component found
  if qp*nix==1
    delete(kindeks(cat(1,p{1:2}),2)); 
    longticks(ah,2);
    xels=get(ah,'xlim'); xels=cat(1,xels{:});
    set(ah,'xlim',minmax(xels))
    nolabels(ah(1:2))
    for ondex=1:length(ah)
      axes(ah(ondex))
      movev(t{ondex},range(get(ah(ondex),'ylim'))/20)
    end
    if pdf==1
      % Actually print to file, or at least give a filename suggestion
      atmp=figdisp(epsname,[],[],pdf);
      system(sprintf('ps2raster -Tf %s',atmp));
      system(sprintf('rm -f %s',atmp));
      % Better move that plot to the working directory 
      system(sprintf('mv -f %s %s',fullfile(getenv('EPS'),pdfname),dirx));
    end
  end
  % If you've been having success
  if exist('s')==1 && exist('h')==1
    % Any components we have, save them together in a MAT file
    save(mtx,'s','h')
    % Start the loop afresh
    clear s h
  end
end

