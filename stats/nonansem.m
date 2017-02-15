function Y=nansem(varargin)
%m=nonansem(y)
%Calculates sem of matrix m, ignoring nans.

function Y = nanstd(varargin)

Y = sqrt(nanvar(varargin{:}));

end % function


for i=1:size(y,2)
	m(i)=std(y(~isnan(y(:,i)),i));
	numreals = length(y(:,i))-sum(isnan(y(:,i)));
	m(i)=m(i)/sqrt(numreals);
end
