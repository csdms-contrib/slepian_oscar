function OAML(bla)
% OAML(bla)
%
% Turns the OAML Generalized Digital Environmental Model –
% Variable Resolution (GDEM-V) NETCDF files into MATLAB format
%
% INPUT:
%
% bla     1 Simple resaving and compression
%         2 Further processing    
%
% Last modified by fjsimons-at-alum.mit.edu, 05/08/2023

% imagefnan([0 90],[360 -90],flipud(double(squeeze(water_temp(33,:,:)))))

clear 

defval('bla',2)

switch bla 
  case 1
    % Where the data are kept
   dirname=fullfile(getenv('IFILES'),'GDEM-V','NETCDF');
   
   % The temperature file identifier
   T='*tgdemv*';
   T='*tstdgdemv*';
   
   % The salinity file identifier
   S='*sgdemv*';
   S='*sstdgdemv*';

   % Load all the files
   Tf=ls2cell(fullfile(dirname,T));
   Sf=ls2cell(fullfile(dirname,S));

   % For all files
   for index=1:length(Tf)
     Tfile=fullfile(dirname,Tf{index});
     Sfile=fullfile(dirname,Sf{index});
     
     % Uncompress
     unix(sprintf('gunzip %s',Tfile));
     unix(sprintf('gunzip %s',Sfile));
     
     % Read in
     T=netcdf(pref(Tfile));
     S=netcdf(pref(Sfile));
     
     % Get rid of the metdata as much as possible
     T=rmfield(T,'NumRecs');
     T=rmfield(T,'DimArray');
     T=rmfield(T,'AttArray');
     S=rmfield(S,'NumRecs');
     S=rmfield(S,'DimArray');
     S=rmfield(S,'AttArray');
     
     % Write out for the time being
     save(sprintf('%s.mat',pref(pref(Tfile))),'T')
     save(sprintf('%s.mat',pref(pref(Sfile))),'S')
     
     % Recompress
     unix(sprintf('gzip %s',pref(fullfile(dirname,Tf{index}))));
     unix(sprintf('gzip %s',pref(fullfile(dirname,Sf{index}))));
   end
 case 2
  
  % Now take a look at compressing this even further, i.e. first compare if
  % the longitudes and latitudes are unique and unversal
  
  dirname='/u/fjsimons/MERMAID/OAML/MATLAB';
  
  % The temperature file identifier
  T='*tgdemv*';
  TT='*tstdgdemv*';
  
  % The salinity file identifier
  S='*sgdemv*';
  SS='*sstdgdemv*';
  
  Tf=ls2cell(fullfile(dirname,T));
  Sf=ls2cell(fullfile(dirname,S));
  TTf=ls2cell(fullfile(dirname,TT));
  SSf=ls2cell(fullfile(dirname,SS));
  
  theyear={'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' ... 
	   'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'};
  
  for index=1:length(Tf)
    Tfile=fullfile(dirname,Tf{index});
    Sfile=fullfile(dirname,Sf{index});
    TTfile=fullfile(dirname,TTf{index});
    SSfile=fullfile(dirname,SSf{index});
    
    load(TTfile); TT=T;
    load(SSfile); SS=S;
    
    load(Tfile)
    load(Sfile)
    
    % Check the difference of the headers, and save only one
    for ondex=1:4
      % The regular files
      eval(sprintf('%s=T.VarArray(%i).Data;',...
		   T.VarArray(ondex).Str,ondex))
      eval(sprintf('%s2=S.VarArray(%i).Data;',...
		   S.VarArray(ondex).Str,ondex))
      % The stdev files
      eval(sprintf('%s3=TT.VarArray(%i).Data;',...
		   TT.VarArray(ondex).Str,ondex))
      eval(sprintf('%s4=SS.VarArray(%i).Data;',...
		   SS.VarArray(ondex).Str,ondex))
      
      eval(sprintf('difer(%s-%s2,[],[],NaN)',...
		   T.VarArray(ondex).Str,S.VarArray(ondex).Str))
      eval(sprintf('difer(%s-%s3,[],[],NaN)',...
		   T.VarArray(ondex).Str,TT.VarArray(ondex).Str))
      eval(sprintf('difer(%s-%s4,[],[],NaN)',...
		   T.VarArray(ondex).Str,SS.VarArray(ondex).Str))
    end
    
    % Get the actual data
    ondex=5;
    eval(sprintf('%s=T.VarArray(%i).Data;',...
		 T.VarArray(ondex).Str,ondex))
    eval(sprintf('%s=S.VarArray(%i).Data;',...
		 S.VarArray(ondex).Str,ondex))
    eval(sprintf('%s=TT.VarArray(%i).Data;',...
		 TT.VarArray(ondex).Str,ondex))
    eval(sprintf('%s=SS.VarArray(%i).Data;',...
		 SS.VarArray(ondex).Str,ondex))
    
    % Convert the time variable to a calendar month and check
    mindex=ceil(time/24/366*12);
    difer(mindex-str2num(suf(pref(Tfile),'s')),[],[],NaN)
    
    % Save the data in one big file, assuming you've taken a look and you
    % know the variable names
    save(sprintf('%s_GDEMV.mat',fullfile(dirname,theyear{index})),...
	 'water_temp','salinity','water_temp_stdev','salinity_stdev')
  end
  % Save the scale factor and offset
  eval(sprintf('%s=%s',...
	       T.VarArray(5).AttArray(8).Str,...
	       'T.VarArray(5).AttArray(8).Val'))
  eval(sprintf('%s=%s',...
	       T.VarArray(5).AttArray(7).Str,...
	       'T.VarArray(5).AttArray(7).Val'))
  % Also save the bathymetry
  dirname='/u/fjsimons/MERMAID/OAML/';
  D=netcdf(fullfile(dirname,'dbdbvgdemv3s.nc'));
  eval(sprintf('%s=%s;',...
	       D.VarArray(3).Str,...
	       'D.VarArray(3).Data'))
  % Save the geographical information at the very end
  save(sprintf('%s_GDEMV.mat',fullfile(dirname,'geomap')),...
       'lat','lon','depth','botdep','add_offset','scale_factor')
end
