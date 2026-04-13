function [SX,SY,SXY,COH2,vCOH2,ADM,E,W,nfftr,nfftc,K]=mtm(X,Y,NW,K,nfftrc,sq)
% [SX,SY,SXY,COH2,vCOH2,ADM,E,W,nfftr,nfftc,K]=MTM(X,Y,NW,K,nfftrc,sq)
%
% Calculates power spectral densities, coherence and admittance between
% two time series or two-dimensional data sets using a Slepian multitaper
% method.
%
% INPUT:
%
% X        The first data set
% Y        The second data set - could be empty
% NW       The time-bandwidth product [default: 3]
% K        The number of tapers used [default: max(2*NW-1,1)]
% nfftrc   Number of frequencies in the [row column] dimension
% sq       1 Indeed calculates the squared coherence
%          0 Calculates the phase angle
%
% OUTPUT:
%
% SX       The power spectral density of the first data set
% SY       The power spectral density of the second data set
% SXY      The cross-power spectral density of the two data set
% COH2     The coherence between the two data sets
% vCOH2    The estimated variance of the coherence 
% ADM      The admittance where the X field is in the denominator
% E        The tapers used for the multitapered analysis
% W        The weights used in the multitapered analysis
% nfftr    Number of frequencies in the row dimension
% nfftc    Number of frequencies in the column dimension
% K        Number of Slepian windows actually used
%
% Last modified by fjsimons-alum-mit.edu, 04/13/2026

% Supply default values
defval('Y',[])
defval('NW',3)
defval('K',max(2*NW-1,1));
defval('wintype','dpss');
defval('sq',2);

% Error checks
if ~all(size(X)==size(Y)) 
  if prod(size(X).*size(Y))
    error('Unless one is empty, both data sets must be equal in size')
  end
end

% See if the second data set is empty
if isempty(Y)
  nvar=1;
  disp('Univariate analysis')
else
  nvar=2;
  disp('Bivariate analysis')
end
  
% In case time series, keep only one dimension - make it a column vector
if ~any(size(X)==[1 1])
  % Thus the data are two-dimensional
  ndim=2;
  disp('Two-dimensional analysis')
  % Remove planar trend from data
  [~,~,~,~,~,Xfit]=planefit(X);
  X=X-Xfit;
  if nvar>1
    [~,~,~,~,~,Yfit]=planefit(Y);
    Y=Y-Yfit;
  end
else
  disp('One-dimensional analysis')
  % Time series are now row vectors
  %  X=detrend(X(:)');
  X=X(:)';
  if nvar>1
      Y=detrend(Y(:)');
      Y=Y(:)';
  end
  ndim=1;
end
%disp('Data sets detrended')

% Check data mean just to be sure
disp(sprintf('Mean of the X data = %3.1e',mean(X(:))))
if nvar>1; disp(sprintf('Mean of the Y data = %3.1e',mean(Y(:)))); end

% Spit out some more multitaper diagnostics
disp(sprintf('Duration x half bandwidth product = %i',NW))
disp(sprintf('Shannon number = %i',2*NW))
disp(sprintf('Number of tapers used = %i',K))

% Resolution of the FFT-routine is determined by the size of the data
[irow,icol]=size(X);
defval('nfftrc',[irow icol])
if length(nfftrc)==1
    nfftrc=[1 nfftrc];
end
nfftr=nfftrc(1);
nfftc=nfftrc(2);

% Calculate the first k data windows in the column dimension
[Ecol,Vcol]=feval(wintype,icol,NW,K);
% If there are two dimensions, it'll be in the row dimension
if ndim>1
  [Erow,Vrow]=feval(wintype,irow,NW,K);
end

% Make the windows two-dimensional if you must
if ndim>1
  % Need all combinations of row and column windows.
  [i,j]=ind2sub([K K],1:K^2); 
  indises=[i ; j]';
  % The weights will be the eigenvalues
  W=Vcol(indises);
  % And now this is the new maximum number of tapers
  K=length(indises);
else
  % The weights remain the eigenvalues
  W=Vcol;
end 

% Initializing arrays makes it sooo much faster
fX=repmat(NaN,[nfftr nfftc K]);
if nvar>1; fY=fX; end

if ndim>1
  % Create an 3-dimensional matrix containing the K 2-dimensional data
  % windows. Calculate 2-dimensional FFTs and fill fX and fY with this.
  for k=1:K  
    fX(:,:,k)=fft(repmat(Erow(:,indises(k,1)),1,nfftc).*...
		  fft(repmat(Ecol(:,indises(k,2)),1,irow)'.*X,nfftc,2),...
		  nfftr,1);
    if nvar>1
      fY(:,:,k)=fft(repmat(Erow(:,indises(k,1)),1,nfftc).*...
		    fft(repmat(Ecol(:,indises(k,2)),1,irow)'.*Y,nfftc,2),...
		    nfftr,1);
    end
  end
  
  % Calculate Power Spectral Density--------------------------------
  SX=fX.*conj(fX);
  if nvar>1 ;  SY=fY.*conj(fY); end
  % Sum everything up along third dimension in weighted fashion
  for k=1:K
    SX(:,:,k)=SX(:,:,k)*W(k,1)*W(k,2);
    if nvar>1 ; SY(:,:,k)=SY(:,:,k)*W(k,1)*W(k,2); end
  end
  SX=fftshift(sum(SX,3)/sum(prod(W,2)));
  if nvar>1 ; SY=fftshift(sum(SY,3)/sum(prod(W,2))); end 
  
  % Calculate Cross Spectral Density---------------------------------
  if nvar>1
    SXY=fX.*conj(fY);
    for k=1:K
      SXY(:,:,k)=SXY(:,:,k)*W(k,1)*W(k,2);
    end
    SXY=fftshift(sum(SXY,3)/sum(prod(W,2)));
  end
else
  % For one-dimensional signals
  % Only half of the returns will be meaningful
  % include DC AND Nyquist
  select = [1:floor(nfftc/2)+1];   
  
  Xwigs=fft(Ecol.*repmat(X,K,1)',nfftc);

  SX=(Xwigs.*conj(Xwigs))*W;

  SX=SX(select);
  
  if nvar>1
    Ywigs=fft(Ecol.*repmat(Y,K,1)',nfftc);
    SY=(Ywigs.*conj(Ywigs))*W;
    SXY=(Xwigs.*conj(Ywigs))*W;

    SY=SY(select);
    SXY=SXY(select);
  end
end
  
% Calculate Coherence-Squared and Admittance-----------------------------
if nvar>1
    if sq==1
        COH2=abs(SXY).^2./SX./SY;
        % Calculate the CRAMER-RAO bound of the variance of coherence-squared 
        % Which seems somewhat optimistic, but then again, it should be close
        vCOH2=2*COH2.*(1-COH2).^2/K;
    else
        % Calculate the phase angle
        keyboard
        COH2=SXY./sqrt(SX)./sqrt(SY);
    end
  ADM=SXY./SX;
end

% Provide blank outputs for completeness
if isempty(Y) ; FY=[] ; SY=[] ; COH2=[]; vCOH2=[]; SXY=[] ; end

% Some more output
if ndim>1
  E=squeeze(Ecol(:,1,:));
else
 E=Ecol;
end

W=W;
