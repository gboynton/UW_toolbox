function out = rmspaces(in)
%   OUT = RMSPACES(IN)
%   Removes spaces in a str or cell array
%   Example:
%   out=rmSpaces({'4 6  34 cat'})
%
%   Written Geoffrey M. Boynton
%   Edited Ione Fine 2/24/2017

if iscell(in)
    for i=1:length(in)
        [a,b]  =regexpi(in{i},'[0-z]','match');
        out{i} = in{i}(b);
    end
    out = reshape(out,size(in)); 
else
    [a,b]  =regexpi(in,'[0-z]','match');
    out = in(b);
end

