function OAML(bla,xver)
% OAML(bla,xver)
%
% Turns the OAML Generalized Digital Environmental Model –
% Variable Resolution (GDEM-V) NETCDF files into MATLAB format
%
% INPUT:
%
% bla     1 Simple resaving and compression
%         2 Further processing
% xver    1 Extra verificatin
%         0 Don't 
%
% 
% Written for 8.3.0.532 (R2014a)
% Option 2 revised for 9.7.0.1190202 (R2019b)
%
% Last modified by fjsimons-at-alum.mit.edu, 05/08/2023

% imagefnan([0 90],[360 -90],flipud(double(squeeze(water_temp(33,:,:)))))

    defval('xver',0)
    defval('bla',1)

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

        % Finds all the files
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
            T=netcdf(sprintf('%s.nc',pref(Tfile)));
            S=netcdf(sprintf('%s.nc',pref(Sfile)));
            
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
        dirname=fullfile(getenv('IFILES'),'GDEM-V','MATLAB');

        % The temperature file identifier
        T='*tgdemv*';
        TT='*tstdgdemv*';
        
        % The salinity file identifier
        S='*sgdemv*';
        SS='*sstdgdemv*';
        
        % Finds all the files
        Tf=ls2cell(fullfile(dirname,T));
        Sf=ls2cell(fullfile(dirname,S));
        TTf=ls2cell(fullfile(dirname,TT));
        SSf=ls2cell(fullfile(dirname,SS));

        % List of months
        theyear={'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' ... 
	         'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'};

        % Loop over all the files 
        for index=1:length(Tf)
            % Load the real variable files
            Tfile=fullfile(dirname,Tf{index});
            Sfile=fullfile(dirname,Sf{index});
            % Load the standard deviation of the variable files
            TTfile=fullfile(dirname,TTf{index});
            SSfile=fullfile(dirname,SSf{index});
            % Both used the simple variable names T and S internally...
            % Now the standard deviations are TT and SS
            load(TTfile); TT=T;
            load(SSfile); SS=S;
            % Now the regular data are T and S
            load(Tfile)
            load(Sfile)


            % Loops over, essentially, 'lat', 'lon', 'depth', 'time'
            for ondex=1:4
                % The regular files
                eval(sprintf('%s=T.VarArray(%i).Data;',...
		             deblank(T.VarArray(ondex).Str),ondex))
                eval(sprintf('%s2=S.VarArray(%i).Data;',...
		             deblank(S.VarArray(ondex).Str),ondex))
                % The stdev files
                eval(sprintf('%s3=TT.VarArray(%i).Data;',...
		             deblank(TT.VarArray(ondex).Str),ondex))
                eval(sprintf('%s4=SS.VarArray(%i).Data;',...
		             deblank(SS.VarArray(ondex).Str),ondex))
                if xver==1
                    % Check that between T and S, and T and TT, and T and SS it's all the same
                    eval(sprintf('difer(%s-%s2,[],[],NaN)',...
		                 deblank(T.VarArray(ondex).Str),deblank(S.VarArray(ondex).Str)))
                    eval(sprintf('difer(%s-%s3,[],[],NaN)',...
		                 deblank(T.VarArray(ondex).Str),deblank(TT.VarArray(ondex).Str)))
                    eval(sprintf('difer(%s-%s4,[],[],NaN)',...
		                 deblank(T.VarArray(ondex).Str),deblank(SS.VarArray(ondex).Str)))
                    eval(sprintf('difer(%s2-%s4,[],[],NaN)',...
		                 deblank(S.VarArray(ondex).Str),deblank(SS.VarArray(ondex).Str)))
                end
            end
            
            % Get the actual data... deblank takes out the nulls AND the spaces! 
            ondex=5;
            eval(sprintf('%s=T.VarArray(%i).Data;',...
		         deblank(T.VarArray(ondex).Str),ondex))
            eval(sprintf('%s=S.VarArray(%i).Data;',...
		         deblank(S.VarArray(ondex).Str),ondex))
            eval(sprintf('%s=TT.VarArray(%i).Data;',...
		         deblank(TT.VarArray(ondex).Str),ondex))
            eval(sprintf('%s=SS.VarArray(%i).Data;',...
		         deblank(SS.VarArray(ondex).Str),ondex))
            
            % Convert the time variable (in hours... to the mid month) to a
            % calendar month and check with the file name
            mindex=ceil(time/24/366*12);
            difer(mindex-str2num(suf(pref(Tfile),'s')),[],[],NaN)
            
            % Save the data in one big file, assuming you've taken a look and you
            % know the variable names... but never mind
            save(sprintf('%s_GDEMV.mat',fullfile(dirname,theyear{index})),...
	         'water_temp','salinity','water_temp_stdev','salinity_stdev')
        end
        % Save the scale_factor and add_offset
        eval(sprintf('%s=%s;',...
	             deblank(T.VarArray(5).AttArray(8).Str),...
	             'T.VarArray(5).AttArray(8).Val'))
        eval(sprintf('%s=%s;',...
	             deblank(T.VarArray(5).AttArray(7).Str),...
	             'T.VarArray(5).AttArray(7).Val'))
        % Also save the bathymetry
        % Where the data are kept
        dirname=fullfile(getenv('IFILES'),'GDEM-V','NETCDF');
        % This needs a fix for subsequent versions
        D=netcdf(fullfile(dirname,'dbdbvgdemv3s.nc'));
        eval(sprintf('%s=%s;',...
	             D.VarArray(3).Str,...
	             'D.VarArray(3).Data'))
        % Save the geographical information at the very end
        save(sprintf('%s_GDEMV.mat',fullfile(dirname,'geomap')),...
             'lat','lon','depth','botdep','add_offset','scale_factor')
    end

end
