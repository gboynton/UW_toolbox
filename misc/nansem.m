function m=nansem(y)
%NANSEM std value, ignoring NaNs.
%   M = NANSEM(X) returns the standard deviation of X, treating NaNs as
%   missing values.  For vector input, M is the standard deviation value of the non-NaN
%   elements in X.  For matrix input, M is a row vector containing the
%   median value of non-NaN elements in each column.  For N-D arrays,
%   NANMEDIAN operates along the first non-singleton dimension.
%
%   NANMEDIAN(X,DIM) takes the median along the dimension DIM of X.
%
%   See also MEDIAN, NANMEAN, NANSTD, NANVAR, NANMIN, NANMAX, NANSUM.

%   Written GMB 2000, edited Kelly Chang Ione Fine. 


for i=1:size(y,2)
	m(i)=std(y(~isnan(y(:,i)),i));
	numreals = length(y(:,i))-sum(isnan(y(:,i)));
	m(i)=m(i)/sqrt(numreals);
end
