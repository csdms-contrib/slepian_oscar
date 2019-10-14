function [xf,co,npol,npas,tipe,HABS2,F,EPB]=...
    bandpass(x,Fs,colo,cohi,npol,npas,tipe,trending)
% [xf,HABS2,F,EPB]=BANDPASS(x,Fs,colo,cohi,npol,npas,tipe,trending)
%
% Filters signal 'x' with filter 'tipe' and corner
% frequencies 'cohi' and 'cohi' in Hz with 'npol' the 
% number of poles and in 'npas' passes. 
%
% INPUT:
%
% x         The signal
% Fs        Its sampling frequency [Hz]
% colo      The lower corner frequency [Hz]
% cohi      The higher corner frequency [Hz]
% npol      The number of poles [default: 2]
% npas      The number of passes [default: 1]
% tipe      The filter name [default: 'butter']
% trending  'linear' or 'constant' [default: 'linear']
%
% OUTPUT:
%
% xf      The filtered signal
%
% NOTE: 
%
% Since writing this function, MATLAB came up with its own BANDPASS
%
% Compare in SAC bp butter co 0.05 5 n 2 p 1
%
% Returns the npas frequency response and the effective pass band for
% one or two passes (3 dB level)
%
% You'll see that plot(F,decibel(HABS2)) (this is what freqz plots)
% shows how' you concentrate between cohi and colo at the 
% 3 dB-level
%
% Last modified by fjsimons-at-alum.mit.edu, 10/14/2019

defval('npol',2)
defval('npas',1)
defval('colo',0.05)
defval('cohi',0.50)
defval('Fs',110)
defval('tipe','butter')
defval('trending','linear')

disp(sprintf('BANDPASS %3.3f-%3.3f Hz %i pass %i poles %s',...
	     colo,cohi,npas,npol,tipe))
						
% Corner frequency is in Hertz, now it is as a fraction of
% half the sampling rate.
Wn=2*[colo cohi]/Fs;

if Wn(2)>=1
  Wn(2)=0.99;
  warning('Frequencies adjusted to keep within the Nyquist rate')
end

if diff(Wn)<0.01
  warning(sprintf('%s\n%s\n%s\n%s',...
  ['Situations that seem to require an exceptionally narrow band'],...
  ['filter can be handled more reliably by decimation, filtering'],...
  ['with a filter of more  moderate band width, and interpolation'],...
  ['to the original sampling rate. (SAC manual)']))
end

[B,A]=feval(tipe,npol,Wn);

if nargout>5
  [H,F]=freqz(B,A,512,Fs);
  HABS2=abs(H).^2;
end

xf=filter(B,A,detrend(x(:),trending));

if npas==2
  xf=flipud(filter(B,A,detrend(flipud(xf(:)),trending)));  
  if nargout>5
    HABS2=HABS2.^2;
  end
end

if nargout>5
  warning off
  EPB=bpmin(decibel(HABS2),F,3);
  warning on
end

co=[colo cohi];
