function m=nonanmean(y)
%m=nonanmean(y)
%Calculates mean of matrix m, ignoring nans.

for i=1:size(y,2)
	m(i)=mean(y(~isnan(y(:,i)),i));
end
