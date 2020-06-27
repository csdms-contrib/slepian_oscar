function varargout=parseval(NFFT) 
% tms=PARSEVAL(NFFT)
% PARSEVAL(NFFT)
%
% Verifies the form of Parseval's theorem in PW p 134
%
% For this to work in Matlab, need to demean the data and
% apply a normalized boxcar window to the data, because
% 
% [1]  p(1)=fft(y) returns p(1)=sum(y)
% [2]  no window at all amounts to a unity window, see p 208
%
% See also BRACEWELL

for index=1:length(NFFT)
  y=rand(NFFT(index),1);
  t=var(y);
  s=mean(abs(fft((y-mean(y))/sqrt(length(y)))).^2);
  tms(index)=abs(t-s)/t;
  if length(NFFT)==1 | nargout==0
    disp(sprintf(...
	'Parseval check: %8.3e (time) vs %8.3e (frequency)',...
	t,s))
  end
end

if nargout==1
  varargout{1}=tms;
end



