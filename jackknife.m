function J=jackknife(N)
% J=jackknife(N)
%
% Returns delete-one sampling matrix for a 
% set of N values.
%
% Written by fjsimons-at-alum.mit.edu, Jan 14th, 2003

l=repmat(1:N,N,1);
J=reshape(l(~diag(ones(1,N))),N,N-1);
