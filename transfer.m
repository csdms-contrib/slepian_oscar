function varargout=transfer(saxin,freqlimits,to,meth)
% [s,h,freqlimits]=transfer(saxin,freqlimits,to,meth)
% 
% INPUT:
%
% saxin        A SAC filename, e.g., PP.S0001.00.HHZ.D.2024.096.142022.SAC
% freqlimits   Prior filter requested, highpass lowpass [f1 f2 f3 f4]
%              (A suggested rule-of-thumb is f1 <= f2/2 and f4 >= 2*f3.)
% to           'none' -> displacement (nm), IDEP 6, IDISP
%              'vel'  -> velocity (nm/s), IDEP 7, IVEL
%              'acc'  -> acceleration (nm/s/s), IDEP 8, IACC
% meth         1 Calls SAC's own TRANSFER function (see there)
%              2 Homegrown - see Alex Burky (to be continued)
%
% OUTPUT:
%
% s,h         Header and seisimc data after instrument deconvolution
% freqlimits  Prior filter applied [f1 f2 f3 f4]
% saxout      A SAC output filename automatically generated   
%
% See also: MCMS2MAT
%
% Last modified by fjsimons-at-alum.mit.edu, 04/17/2024

% Defaults
defval('meth',1)
defval('to','none')
% You'll want this
if strcmp('to','disp'); to='none'; end
defval('freqlimits',[0.1 0.2 10.00 20.00]);
% Where do you keep your version of SAC
defval('sac','/usr/local/sac/bin/sac')
% Where are the response files kept?
defval('dirr','/u/fjsimons/IFILES/RESPONSES/PP/');

% Read the header data to identify the correct response
[~,HdrData]=readsac(saxin);

% Header variables and their defaults for our instruments
NTW=deblank(HdrData.KNETWK);
defval('NTW','PP')
STA=deblank(HdrData.KSTNM);
defval('STA','S0001');
HOL=deblank(HdrData.KHOLE);
defval('HOL','00');
CHA=deblank(HdrData.KCMPNM);
defval('CHA','HHZ');
% Locate the response appropriate file
respfile=fullfile(dirr,sprintf('%s.%s.%s.%s.%s',NTW,STA,HOL,CHA,'resp'));

% Tag the conversion with a hash
ext=hash([freqlimits to meth],'SHA-1');
% Try this new name, a bit fickle, the directory better not contain SAC since the filename does
% and also there is a filename LENGTH limit in SAC so don't get cut off
saxout=sprintf('%s%s.%s',rindeks(parse(saxin,suf(saxin)),1),ext,suf(saxin));

% Don't redo it if you've already done it but rather read the hashed version
if exist(saxout)~=2
    % Instrument response deconvolution!
    switch meth
      case 1
        % Make the call
        tcom=sprintf(...
            'transfer from evalresp fname %s to %s freqlimits %g %g %g %g prewhitening on',...
            respfile,to,freqlimits(1),freqlimits(2),freqlimits(3),freqlimits(4));
        % Execute the call to SAC, you can suppress screen output by asking for it here
        system(sprintf(...
            'echo "r %s ; rtr ; rmean ; taper type ; %s ; w %s ; q" | %s',...
            saxin,tcom,saxout,sac));
      case 2
        error('Not ready yet, check with Alex Burky''s program suite rflexa')
    end
end

if nargout
    % Read the output
    [s,h]=readsac(saxout);
end

% Optional outputs
varns={s,h,freqlimits,saxout};
varargout=varns(1:nargout);
