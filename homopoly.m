function varargout=homopoly(d,q,bs,xver)
% [abc,bbc]=homopoly(d,q,bs,xver)
%
% Returns a matrix that lists all the possibilities (indexed by row)
% of powers to which a factor (indexed by column) can be raised such
% that the result, when sorted, can be sorted as homogeneous
% polynomials in the factors UP to a certain degree d, but
% whose individual factors are raised to no more of a power than q
%
% INPUT:
%
% d       The maximum degree of the homogenenous polynomials that can be formed
% q       The maximum power of any of the factors in any of the polynomials
% bs      The base of the encoding system
% xver    Verifies the dimension, which can be slower
%
% OUTPUT:
%
% abc   The powers matrix, sorted in order of homogeneous polynomial degree
% bbc   A running index/unique code that uniquely maps
%
% Last modified by fjsimons-at-alum.mit.edu, 06/03/2023

% Play it super safe but slower?
defval('xver',1);

% How high a power in play at most per variable individually
defval('q',3);
% If homogenous polynomial how high a degree do you allow?
defval('d',4);
% Just a trial, really, on a hunch
defval('bs',d);
% Will be doing dimensional verification later
if xver==1
    % If you stick to q but d>q the counting comparison will fail
    qu=max(q,d);
else
    % If you do not update just don't do the comparison
    qu=q;
end
% Up to 3, order difference from NDGRID
% [a,b,c]=meshgrid(0:qu,0:qu,0:qu); 
% More variables? keep adding inputs and get more outputs
[a,b,c]=ndgrid(0:qu,0:qu,0:qu);
% All the power combinations in all variables:
abc=[a(:) b(:) c(:)];
% These are all the power combinations below homogenous degree d
abc=abc(sum(abc,2)<=d,:);
% These now are all the actual homogeneous degrees d
d=sum(abc,2);
% These now are all sorted by homogeneous degrees d
abc_s=kindeks(sortrows([abc d],size(abc,2)+1),1:size(abc,2));
d_s=sort(d);
% This is the extra verification again!
if d<qu
    % Verify the multiplicity 1/2*(d+1)*(d+2)
    diferm(histcounts(d_s,max(d)+1),1/2*([0:max(d)]+1).*([0:max(d)]+2))
end
% You could limit to maximum INDIVIDUAL degree from the top
abc_l=abc_s(~any(abc_s>q,2),:);

% A decent b-based code should be close to a linear mapping
bcode=@(Z,b) Z*b.^[size(Z,2)-1:-1:0]';
% Take the homogeneous degree to be the base?
bbc=bcode(abc_l,bs);
% Make sure there are enough numbers and no duplicates
if length(unique(bbc))<length(abc_l)
    error('Up the base for the bcode...')
end

% Output
varns={abc_l,bbc};
varargout=varns(1:nargout);

% Stuff that PUZZLE made me think of but  that we end up not needing

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % OPTION 2
% % How many variables are in play
% q=3;
% % Now you have all the sets of variables (singles, pairs, triplets)
% % whose indices can range over all possibilities. Not so useful?
% for e=1:q
%     n{e}=nchoosek(1:q,e)
% end
% % Abandon

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % OPTION 3
% % How many powers are in play (counting zero)
% q=4;
% % UP to how many independent variables are in play
% e=3;
% % Build all the possibilities and cyclically perturn this?  Not so useful.
% for index=1:e
%     n=nchoosek(0:q,index)
% end
% % Abandon
