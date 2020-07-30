function mcms2mat(yyyy,mm,dd,HH,MM,SS,qp,pdf,of,xls,icor)
% MCMS2MAT(yyyy,mm,dd,HH,MM,SS,qp,pdf,of,xls,icor)
%
% MeridianCompact-miniSEED-to-MAT conversion of data files.
% 
% Queries a directory structure organized as $MC/YYYY/MM/DD/
% within which, e.g. S0001.HHY_MC-PH1_0248_20170127_040000.miniseed 
% or recently  PP.S0001.00.HHZ_MC-PH1_0248_20170627_030000.miniseed 
% data files as written by the Nanometrics instrument MC-PH1_0248. 
%
% Unpacks using MSEED2SAC Version 2.0, a program available from 
% https://seiscode.iris.washington.edu/projects/mseed2sac
%
% Performs instrument correction using available RESP files.
%
% Makes some plots, and saves the data as MAT files.
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
% xls      X-axis limits for the plot [defaulted]
% icor     1 Corrects for instrument response
%          0 Doesn't correct for instrument response
%
% USAGE:
%
% Input could be very detailed about a single specific yyyymmddHHMMSS
% or leave the minutes and seconds, or even hours, out of it altogether
% and it will apply to all available files, assuming hourly chunks.
%
% EXAMPLE:
%
% mcms2mat(2020,02,18,16,[],[],1,1,[],[1800 1815])
% mcms2mat(2020,02,21,16,[],[],1,1,[],[2555 2570])
%
% SEE ALSO:
%
% MCGETMS, MCMS2SAC (a tcsh shell script)
%
% Tested on 8.3.0.532 (R2014a) and 9.0.0.341360 (R2016a)
% Last modified by abrummen-at-princeton.edu, 07/14/2016
% Last modified by fjsimons-at-alum.mit.edu, 07/29/2020

% FIXED STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Default data directory with the YYYY/MM/DD directories, set your own 'MC'
setenv('MC',getenv('MC'))
dirx=getenv('MC');

% Where are the response files kept?
defval('icor',1)
dirr='/u/fjsimons/IFILES/RESPONSES/PP/';

% Default directory where the EPS files will go, best to set your own 'EPS'
setenv('EPS',getenv('EPS'))

% Hard things such as our station, channel, device name etc
NTW='PP';
STA='S0001';
HOL='00';
CHA='HH%s';
DEV='MC-PH1_0248';
INS='MC120PH';
% Set of components we should be expecting for our miniSEED files
cmp={'X' 'Y' 'Z'};

% Format of the miniSEED and MAT file names in those directories
msfmt=sprintf('%s.%s.%s.%s_%s_%s.%s',NTW,STA,HOL,CHA,DEV,'%s','%s');
rffmt=sprintf('%s.%s.%s.%s.%s',      NTW,STA,HOL,CHA,    '%s');
% SAC format expected out of MSEED2SAC, had to run it to find out
scfmt=sprintf('%s.%s.%s.%s.%s.%s.%s.%s.SAC',NTW,STA,HOL,CHA,'D','%i','%3.3i','%s');
% One could put in the "old" format (... see MCMS2SAC) and failsafe below
  
% We may change our minds on this
defval('of',1)
    
% INPUT STUFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Defaults for the dates for which we have a data directory... today!
defval('yyyy',str2num(datestr(date,'yyyy')))
defval('mm',str2num(datestr(date,'mm')))
defval('dd',str2num(datestr(date,'dd')))
% Set of hours we should be expecting for our miniSEED files [all!]
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
    % Make the miniSEED FILENAME with the precise time in it now also
    msx=fullfile(dirx,sprintf(msfmt,cmp{ondex},dst1,'miniseed'));
    % Response file
    respfile=fullfile(dirr,sprintf(rffmt,cmp{ondex},'resp'))
    % Full figure name... but notice the trouble with periods in
    % the filenames, which is very annoying and gets fixed down below
    pdfname=sprintf('%spdf',pref(suf(msx,'/'),'miniseed'));
    % Better test that the miniSEED exists as a filename
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

      if icor==1
	% Make it smaller by cutting?

	% Instrument response deconvolution?
	% [INSTRUMENT CORRECTION to "none" is "displacement"]
	freqlimits=[0.1 0.2 10.00 20.00];
	tcom=sprintf(...
	    'transfer from evalresp fname %s to none freqlimits %g %g %g %g prewhitening on',...
	    respfile,freqlimits(1),freqlimits(2),freqlimits(3),freqlimits(4));
	
	system(sprintf(...
	    'echo "r %s ; rtr ; rmean ; taper type ; %s ; w h.sac ; q" | /usr/local/sac/bin/sac',...
	    sax,tcom));

	% Substitute the temporary variable name
	system(sprintf('rm -f %s',sax));
	sax='h.sac';
      else
	freqlimits=nan(1,4);
      end
	 
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
	% Short version
	if strfind(h{ondex}.IDEP,'DISPLACEMENT')~=0
	  h{ondex}.IDEP='disp (nm)';
	end
	p{ondex}(3)=ylabel(sprintf('%s %s',cmp{ondex},h{ondex}.IDEP));
	
	% For the blasting...
	defval('xls',[1800 1815])
	xlim(xls)
	
	if verLessThan('matlab','9.0.0')
	else
	  % After R2016a the behavior changed
	  tlpos=t{ondex}.Position; 
	  % Need to recenter the title after xls change
	  t{ondex}.Position=tlpos+[-tlpos(1)+mean(xls) 0 0];
	  t{ondex}.FontWeight='normal';
	  t{ondex}.FontSize=8;
	end
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
    % Now it gets the PDF name of the last component loaded... not ideal
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
       % Any components we have, save them SEPARATELY in a single MAT file
       % The seismograms
       sx=s{1}; sy=s{2}; sz=s{3};
       % Their headers
       hx=h{1}; hy=h{2}; hz=h{3};
       % ...easier to subsequently direct-LOAD in, component by component 
       save(mtx,'sx','sy','sz','hx','hy','hz','freqlimits')
     case 2
      % Any components we have, save them TOGETHER in a single MAT file
      save(mtx,'s','h','freqlimits')
    end
    % Start the loop afresh
    clear s h
  end
end

% NOTES ON SAC TRANSFER
%
% FREQLIMITS f1 f2 f3 f4 : All seismometers have zero response at zero
% frequency. When deconvolving and not convolving with another response
% (e.g. "TO NONE"), it is therefore necessary to modify the response at
% very low frequencies. At high frequencies, the signal-to-noise ratio
% is often low, so it may be desirable to dampen the
% response. FREQLIMITS serves this purpose within SAC. FREQLIMITS has
% both a low-pass and a high-pass taper. It is necessary that f1 < f2 <
% f3 < f4. The taper is unity between f2 and f3 and zero below f1 and
% above f4. Frequencies f1 and f2 specify the high-pass filter at low
% frequencies, while frequencies f3 and f4 specify the low-pass filter
% at high frequencies. Both f3 and f4 should be less than the Nyquist
% frequency: 0.5/DELTA. The filters applied between f1 and f2 and
% between f3 and f4 are quarter cycles of a cosine wave. To avoid
% ringing in the output time series, a suggested rule-of-thumb is f1 ,=
% f2/2 and f4 >= 2*f3.
%
% NOTES FROM Qinya Liu
% caec056 version of
% https://github.com/liuqinya/specfem3d_globe/blob/master/utils/seis_process/process_data.pl
% freqlimits
% $f1=$f2*0.8;
% $f4=$f3*1.2;
