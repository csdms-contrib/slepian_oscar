function mcms2mat(yyyy,mm,dd,HH,MM,SS,qp,pdf,of)
% MCMS2MAT(yyyy,mm,dd,HH,MM,SS,qp,pdf,of)
%
% MeridianCompact-MiniSeed-to-MAT conversion of data files.
% 
% Queries a directory structure organized as $MC/YYYY/MM/DD/
% within which, e.g. S0001.HHY_MC-PH1_0248_20160627_040000.miniseed 
% data files as written by the Nanometrics instrument MC-PH1_0248. 
% Unpacks using MSEED2SAC Version 2.0, a program available from 
% https://seiscode.iris.washington.edu/projects/mseed2sac
% [Performs instrument correction using SAC available from etc...]
% Makes some plots, and saves as MAT files.
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
% of       1 Components saved in MAT file as separate variables [default] 
%          2 Components saved in MAT files as cell entries
%
% USAGE:
%
% Input could be very detailed about a single specific yyyymmddHHMMSS
% or leave the minutes and seconds, or even hours, out of it altogether
% and it will apply to all available files, assuming hourly chunks.
%
% SEE ALSO:
%
% MCGET (a tcsh shell script)
%
% Tested on 8.3.0.532 (R2014a) and 9.0.0.341360 (R2016a)
% Last modified by abrummen-at-princeton.edu, 07/01/2016
% Last modified by fjsimons-at-alum.mit.edu, 07/01/2016

% FIXED STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Default data directory with the YYYY/MM/DD directories, set your own 'MC'
setenv('MC',getenv('MC'))
dirx=getenv('MC');

% Default directory where the EPS files will go, best to set your own 'EPS'
setenv('EPS',getenv('EPS'))

% Hard things such as our station, channel, device name etc
STA='S0001';
CHA='HH%s';
DEV='MC-PH1_0248';
% Set of components we should be expecting for our miniseed files
cmp={'X' 'Y' 'Z'};

% Format of the MINISEED and MAT file names in those directories
msfmt=sprintf('%s.%s_%s_%s.%s',STA,CHA,DEV,'%s','%s');
% SAC format expected out of MSEED2SAC, had to run it to find out
scfmt=sprintf('.%s..%s.%s.%s.%s.%s.SAC',STA,CHA,'D','%i','%i','%s');
      
% We may change our minds on this
defval('of',1)
    
% INPUT STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Defaults for the dates for which we have a data directory... today!
defval('yyyy',datestr(date,'yyyy'))
defval('mm',datestr(date,'mm'))
defval('dd',datestr(date,'dd'))
% Set of hours we should be expecting for our miniseed files [all!]
defval('HH',0:23)
% Minutes and seconds that we expect these to start at [zero!]
defval('MM',0)
defval('SS',0)
% Make a plot on the screen?
defval('qp',1)
% Save the plot as a pdf?
defval('pdf',1)

% Collect the Julian date already as it will be needed later
juld=ceil(datenum(yyyy,mm,dd)-datenum(yyyy,00,00));
% SAC file pre-format expected by the conversion via MSEED2SAC
sacfmt=sprintf(scfmt,'%s',yyyy,juld,'%s');

% Input reply default
defval('reply','y')

% GENERIC STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Detailed-level data directory where we should be looking for data
dirx=fullfile(dirx,datestr(datenum(yyyy,mm,dd),'yyyy/mm/dd'));

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
    % Full figure name... but notice the trouble with periods in
    % the filenames, which is very annoying and gets fixed down below
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
        % in the title. But note that 'last' means all other times are PAST
	% If "future-timing" encountered, "touch" all the files before going in
	d=dir(pwd); [ds,n]=sort([d(:).datenum]);
	sax=d(n(length(n))).name;
	% We most likely want to go along with the file that it did create
	reply=input(sprintf('%s found, continue with that [Y/N] or skip? ',sax),'s');
	if strcmp(lower(reply),'n'); continue; end
      end
      % Instrument response deconvolution? Header update in that case;
      % filename update also above, to do!
      
      % [INSTRUMENT CORRECTION]
      
      % If plotting, get ready
      if qp==1; axes(ah(ondex)); end
      % Redefine sax again then READSAC and collect components
      [s{ondex},h{ondex},t{ondex},p{ondex}]=readsac(sax,qp);
      % If plotting, finish up with underscores in the title as needed
      if qp==1
	% Used for titles and plot names... watch the underscore... options
	if verLessThan('matlab','8.4')
	  mss=nounder(suf(msx,'/'),'\_');
	else      
	  mss=nounder(suf(msx,'/'),'\_');
	end
	set(t{ondex},'string',mss);
	p{ondex}(3)=ylabel(cmp{ondex});
      end
      % Remove the temporary SAC files
      system(sprintf('rm -f %s',sax));
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
    nolabels(ah(1:2),1)
    for ondex=1:length(ah)
      axes(ah(ondex))
      movev(t{ondex},range(get(ah(ondex),'ylim'))/20)
    end
    % Actually print to file? At least give a print suggestion! Force PDF
    atmp=figdisp(pdfname,[],[],~~pdf*2);
    % Better move that plot to the working directory, fix extension
    if pdf==1
      system(sprintf('mv -f %s %s',fullfile(getenv('EPS'),pdfname),dirx));
    end
  end
  % If you've been having success
  if exist('s')==1 && exist('h')==1
    switch of
      case 1
       % Any components we have, save them SEPARATELY in a MAT file
       % The seismograms
       sx=s{1}; sy=s{2}; sz=s{3};
       % Their headers
       hx=h{1}; hy=h{2}; hz=h{3};
       % ...easier to subsequently direct-LOAD in, component by component 
       save(mtx,'sx','sy','sz','hx','hy','hz')
     case 2
      % Any components we have, save them TOGETHER in a MAT file
      save(mtx,'s','h')
    end
    % Start the loop afresh
    clear s h
  end
end
