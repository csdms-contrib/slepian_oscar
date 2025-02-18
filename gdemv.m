function varargout=gdemv(lat1,lon1,dep1,Mmm,xver,T,S,DT,DS)
% [T,S,DT,DS]=GDEMV(lat,lon,dep,Mmm,xver,T,S,DT,DS)
%
% Temperature, salinity and their standard deviations at a particular
% place and time from OAML's GDEM-V model.
%
% INPUT:
%
% lat,lon      Arrays of longitude and latitude (degrees)
% dep          Arrays of depth (m)
% Mmm          'Jan','Feb', etc, to 'Dec'
% xver         0 Proceed along with the extraction
%              1 Excessive verification
%              2 Database load only, no values extracted
%              3 Input coordinates are a line, not a grid  
% T,S,DT,DS    Database input
%
% OUTPUT:
%
% T,S,DT,DS    The specific values requested, in latxlonxdepth
%              or the whole database, which is in depthxlatxlon
%
% TESTING: (OAML-DBD-72E_Oct_2003_U example 2 on page 24)
%
% gdemv('demo1')
%
% EXAMPLE:
%
% tic; [T,S,DT,DS]=gdemv([],[],[],'Jan',2); toc % database loading
% tic; [Ti,Si,DTi,DSi]=gdemv([],[],[],'Jan',0,T,S,DT,DS); toc % database passed
% tic; [Ti,Si,DTi,DSi]=gdemv([],[],[],'Jan',0); toc % database not passed
%
% % It will be common to feed it an entire GRID at one depth, e.g.
%
% gdemv('demo2')
%
% % Or you could want a data CUBE, i.e. a grid at many depths
%
% gdemv('demo3')
%
% % Or you could want a LINE like a great-circle path at many depths
%
% gdemv('demo4')
%
% SEE ALSO:
%
% OAML for the preprocessing, GEBCO for a better bathymetry grid
%
% LAST TESTED VERSION: 9.7.0.1190202 (R2019b)
%
% Last modified by fjsimons-at-alum.mit.edu, 02/18/2024

% Where are the data being kept?
defval('ddir','/data1/fjsimons/IFILES/GDEM-V/MONTHLY')
% Defaults
defval('lat1',15)
defval('lon1',-25)
defval('dep1',200)
defval('Mmm','Jul')
defval('xver',0)

if ~isstr(lat1)
    % If you don't supply the big database it will load it
    if nargin<=5
        % Make file name
        fname=fullfile(ddir,sprintf('%s_GDEMV.mat',Mmm));
        % Load data
        load(fname)
        % Takes a while so maybe pass variables around
        T=water_temp;
        S=salinity;
        DT=water_temp_stdev;
        DS=salinity_stdev;
    end
    
    if xver==2
        % Be done already, now you can pass the database around
        % exactly in the form that it came.
    else
        if xver==1
            % Also load bathymetry and grid information
            fname=fullfile(ddir,sprintf('%s_GDEMV.mat','geomap'));
            load(fname)
            add_offset=double(add_offset);
            scale_factor=double(scale_factor);
        else
            % Check documentation or the case above
            dlola=0.25;
            lon=0:dlola:359.75;
            lat=-82:dlola:90;
            depth=[0:2:10 15:5:100 110:10:200 220:20:300 350 400:100:1600 1800:200:6600];
            add_offset=15;
            scale_factor=0.001;
        end

        % Now pick out what you need
        lon1=lon1+[lon1<0]*360; lon1=lon1.*[lon1<=(360-dlola)];
        loni=round(lon1/dlola)+1;
        % Latitudes are reversed
        lati=round((lat1-min(lat))/dlola)+1;
        % Depth are weirdly spaced
        depi=interp1(depth,1:length(depth),dep1,'nearest');
        if xver==1
            % Must keep close!
            diferm(abs(lon(loni)-lon1)>=dlola);
            diferm(abs(lat(lati)-lat1)>=dlola);
        end

        % Hold on, is it a line object?
        if xver==3
            if any(size(lon1)~=size(lat1))
                error('For LINE object must have pairs of coordinates')
            end
            % Get the points individually
            % Transform to linear coordinates
            diferm(size(squeeze(T(1,:,:))),[length(lat) length(lon)])
            %A=repmat(sub2ind([length(lat) length(lon)],lati(:)',loni(:)'),...
            %       length(depi),1)+repmat((depi(:)-1)*length(lat)*length(lon),...
            %                              1,length(lati));
            % Easier these days with an outer sum... 
            B=sub2ind([length(lat) length(lon)],lati(:)',loni(:)')...
              +(depi(:)-1)*length(lat)*length(lon);
            % Pick up the right stuff
            T=nsdsol(T,B,scale_factor,add_offset);
            if nargout>1
                S=nsdsol(S,B,scale_factor,add_offset);
                if nargout>2
                    DT=nsdsol(DT,B,scale_factor,add_offset);
                    if nargout>3
                        DS=nsdsol(DS,B,scale_factor,add_offset);
                    else
                        DS=[];
                    end
                else
                    DT=[]; DS=[];
                end
            else
                S=[]; DS=[]; DT=[];
            end
        else
            % But then you have it all, don't forget to reorder
            T=nsdso(T(depi,lati,loni),scale_factor,add_offset);
            if nargout>1
                S=nsdso(S(depi,lati,loni),scale_factor,add_offset);
                if nargout>2
                    DT=nsdso(DT(depi,lati,loni),scale_factor,add_offset);
                    if nargout>3
                        DS=nsdso(DS(depi,lati,loni),scale_factor,add_offset);
                    else
                        DS=[];
                    end
                else
                    DT=[]; DS=[];
                end
            else
                S=[]; DS=[]; DT=[];
            end
        end
    end
    % Output if necessary
    varns={T,S,DT,DS};
    varargout=varns(1:nargout);
elseif strcmp(lat1,'demo1')
    deps=[0:2:10 15:5:85]; lon=29.6; lat=-88.1;
    [T,S,DT,DS]=gdemv(lon,lat,deps,'Dec');
    P=swpressure(deps,lat,1); clear c
    for i=1:length(deps); c(i)=swspeed(P(i),T(i),S(i),1); end
    disp(sprintf('%5.2f %6.3f %6.3f %7.2f\n',[deps(:) T(:) S(:) c(:)]'))
    for i=1:length(deps); c(i)=swspeed(P(i),T(i),S(i),3); end
    disp(sprintf('%5.2f %6.3f %6.3f %7.2f %5.3f %5.3f\n',[deps(:) T(:) S(:) c(:) DT(:) DS(:)]'))
elseif strcmp(lat1,'demo2')
     lats=-80:0.25:80; lons=0:0.25:360;
     T=gdemv([],[],[],'Jan',2);
     figure(1); clf ; imagesc(lons,lats,gdemv(lats,lons,100,'Jan',[],T));
     axis xy image; caxis([-5 30]); longticks(gca,2); title('January')
     xlabel('longitude'); ylabel('latitude'); cb=colorbar('horizontal');
     xlabel(cb,sprintf('temperature [%sC]',176))
elseif strcmp(lat1,'demo3')
    deps=[0:2:10 15:5:100 110:10:200 220:20:300 350 400:100:1600 1800:200:6600];
    lats=[-70:1:72]; lons=[200:1:210]-40; [LAT,LON]=ndgrid(lats,lons);
    [T,S]=gdemv([],[],[],'Jan',2);
    [Ti,Si]=gdemv(lats,lons,deps,'Jan',[],T,S);
    hold on; plot([min(lons) max(lons) max(lons) min(lons) min(lons)],...
    [min(lats) min(lats) max(lats) max(lats) min(lats)],...
        'Color','k'); hold off
    figure(2); imagesc(lons,lats,Ti(:,:,24)); axis xy image; caxis([-5 30])
    axis([0 360 -80 80])
elseif strcmp(lat1,'demo4')
    [T,S]=gdemv([],[],[],'Jan',2);
    % Define the intervals where the sounds speeds will be read as being available
    deps=[0:2:10 15:5:100 110:10:200 220:20:300 350 400:100:1600 1800:200:6600];
    % Some random example
    lon1=180.225; lat1=-70.895;
    lon2=250.445; lat2=15.979;
    % Some random example
    lon1=216.159; lat1=52.106;
    lon2=350.0834; lat2=-62.437;
    % Hunga Tonga to somewhere 
    lon1=-175.39;
    lat1=-20.546;
    % H03S1
    H03S1=[-33.818199     -78.835297       837];
    lon2=H03S1(2);
    lat2=H03S1(1);
    % Maybe we actually want to overshoot it a little
    angl=truecourse([lon1 lat1],[lon2 lat2]);
    % Calculate source-receiver great-circle distance
    [gkm,gdeg]=grcdist([lon1 lat1],[lon2 lat2]);
    % Calculate points along the great-circle path
    [lolag,delta]=grcircle([lon1 lat1]*pi/180,[lon2 lat2]*pi/180,round(gdeg/0.25));
    % Calculate a few more points past the end point
    [lon3,lat3]=grcazim([lon1 lat1],gkm*1.05,angl,'Earth');
    [lon3,lat3]=grcazim([lon1 lat1],10000,angl,'Earth');
    [gkm3,gdeg3]=grcdist([lon1 lat1],[lon3 lat3]);
    [lolag,delta]=grcircle([lon1 lat1]*pi/180,[lon3 lat3]*pi/180,round(gdeg3/0.25));

    figure(1)
    gdemv('demo2')
    hold on
    pc=twoplot(lolag*180/pi); set(pc,'LineWidth',2,'Color','k'); hold off 
    lons=lolag(:,1)*180/pi;
    lats=lolag(:,2)*180/pi;
    dels=delta*180/pi*fralmanac('DegDis','Earth')/1000;
    [Ti,Si]=gdemv(lats,lons,deps,'Jan',3,T,S);
    % Now get the right pressure, which depends on depth and latitude
    [DEPS,LATS]=ndgrid(deps,lats);
    Pi=reshape(swpressure(DEPS,LATS,1),size(DEPS));
    % And feed it right into the sound speed calculation
    c=nan(size(DEPS)); % Maybe bake or avoid for loop in SWSPEED later
    for index=1:prod(size(c))
        c(index)=swspeed(Pi(index),Ti(index),Si(index),1);
    end
    % Interpolate in the down dimension with a 2 m spacing
    ci=interp2(dels,deps,c,dels,deps(1):2:deps(end));
    % Pull out the GEBCO depths
    z=gebco(lons-[lons>180]*360,lats); 

    % Make the actual figure
    figure(2)
    clf
    ah=gca;
    % Some vague land color
    sc=sergeicol; sc=sc(86,:);
    % The actual color
    cm=colormap('parula');
    % imagesc(dels,deps,ci)
    imagefnan([dels(1) deps(1)],[dels(end) deps(end)],ci,cm,...
        [round(min(ci(:))) round(max(ci(:)))],sc)
    axis normal ij
    xlabel('incremental great-circle distance [km]'); ylabel('depth [m]')
    shrink(ah,1,3.375);
    longticks(ah,2)
    hold on
    pg=plot(dels,-z,'k'); hold off
    ylim(minmax(deps))
    % Now plot the various other MERMAIDS
    % Calculate source-receiver great-circle distance
    mh=[45 41 53 23 40 999];
    mhlatlondep=[-25.295368    -165.846100      1500;
                 -27.382092    -161.752670      1500;
                 -29.972130    -157.877655      1500;
                 -27.977253    -156.394760      1500;
                 -29.231997    -154.042633      1500;
                 H03S1];
    hold on
    co=colororder;
    for index=1:length(mh)
        gkm=grcdist([lon1 lat1],mhlatlondep(index,[2 1]));
        p(index)=plot(gkm,mhlatlondep(index,3),'o');
        p(index).MarkerSize=3;
        p(index).MarkerFaceColor=co(index,:);
        p(index).MarkerEdgeColor='k';
    end
    hold off
    % Now take care of various cosmetics
    cb=colorbar('vertical');
    cbt=[round(min(ci(:))) round(max(ci(:)))];
    cbarticks(cb,cbt,linspace(cbt(1),cbt(end),5),'vert')
    cb.YDir='reverse';
    % Workarounds
    ahp=get(ah,'Position');
    cbp=get(cb,'Position');
    shrink(cb,1.5,1)
    set(ah,'Position',ahp)
    xlabel(cb,sprintf('sound speed [%s]','m/s'))
    longticks(cb)

    ah.FontSize=6;
    % Print figure
    figdisp('HTHH_1',[],[],2)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s=nsdso(stuff,sf,ao)
s=shiftdim(double(stuff)*sf+ao,1);
s(s==-17)=NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s=nsdsol(stuff,stuffi,sf,ao)
stuff=shiftdim(stuff,1);
s=double(stuff(stuffi))*sf+ao;
s(s==-17)=NaN;
