function [w,wl,wr]=shanning(n,r,sac)
% [w,wl,wr]=shanning(n,r,sac)
%
% Calculates Hanning windows of a certain length and a certain width
% fraction the exact way SAC says it is doing it...
%
% INPUT:
%
% n       The required length of the window
% r       The fraction of the window that is tapered [default 0.5]
% sac     0 Use MATLAB [default]
%         1 Use actual SAC
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
% for i=1:100; plot(shanning(i,r,1)-shanning(i,r,0)); ylim([-1 1]*1e-7); pause(0.25) ; end
%
% i=randi(100); r=randi(50)/100; difer(shanning(i,r,1)-shanning(i,r,0),6); r
% i=randi(100); r=randi(50)/100; plot(shanning(i,r,1)-shanning(i,r,0)); ylim([-1 1]*1e-7); r
%
% UNRESOLVED ISSUES:
%
% Sometimes when ROUND gives a mismatch - on L48, FLOOR fixes it... on
% short Sections... There may be a minimum
%
% Last modified by fjsimons-at-alum.mit.edu, 05/27/2021

defval('r',0.5)
defval('sac',0)

if r<0 || r>0.5 || r==0
  error('r must be between 0.0 and 0.5')
end

if sac==0
  % The length of the taper on each end; rounding could slightly differ
  if r==0.5
    t=round(r*n);
  else
    % Sometimes FLOOR needs to happen. There is weirdness with short sections.
    t=round(r*n);
  end

  % The left bit
  wl = .5*(1-cos(pi*([0:t-1]/t)))';

  % Now you know there are no insertions
  if r==0.5
    % Adapt for oddness by squaring the endpoint
    wl(end)=wl(end)^[1+rem(n,2)];
    % The right bit adapted for oddness by not taking the endpoint again
    wr=flipud(wl(1:end-rem(n,2)));
  else
    % Now you need to make sure you combine it to the right dimension
    wr=flipud(wl);
    % Always symmetric, just add the right amount of zeroes
    wl=[wl ; ones(n-2*t,1)];
  end

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


