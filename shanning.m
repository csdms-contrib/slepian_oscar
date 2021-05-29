function [w,wl,wr]=shanning(n,r,sac)
% [w,wl,wr]=fhanning(n,r,sac)
%
% Calculates Hanning windows of a certain length and a certain width
% fraction the exact way SAC says it is doing it...
%
% INPUT:
%
% n       The required length of the window
% r       The fraction of the window that is tapered [default 0.5]
% sac     1 Use actual SAC
%         0 Use MATLAB [default]
%
% OUTPUT:
%
% w       The Hanning window 
% wl      The left half of the window
% wr      The right half of the window
%
% EXAMPLE:
% 
% r=0.5;
% for i=1:100; difer(shanning(i,r,1)-shanning(i,r,0),6); end
% for i=1:100; plot(shanning(i,r,1)-shanning(i,r,0)); ylim([-1 1]*1e-7); pause ; end
%
% This function works for r=0.5
%
% Last modified by fjsimons-at-alum.mit.edu, 05/26/2021

defval('r',0.5)
defval('sac',0)

if sac==0
  % The length of the taper on each end
  t=ceil(r*n);
  % The left bit
  wl = .5*(1-cos(pi*([0:t-1]/t)))';
  % Adapt for oddness by squaring the endpoint
  wl(end)=wl(end)^[1+rem(n,2)];
  % The right bit adapted for oddness by not taking the endpoint again
  wr = flipud(wl(1:end-rem(n,2)));
  % And then the full thing put together
  w=[wl ; wr];
elseif sac==1
  % Make the SAC command sequence
  tcom=sprintf(...
      'funcgen line 0 1 npts %i ; taper type hanning width %f ; w h.sac',n,r);
  % Execute the SAC command sequence
  system(sprintf(...
      'echo "%s ; q" | /usr/local/sac/bin/sac',tcom));
  % Read the file that SAC just wrote
  w=readsac('h.sac');
  % And clean it up
  system('rm -f h.sac');
end


